//
//  ViewController.swift
//  Test1
//
//  Created by Al Brown on 4/3/18.
//  Copyright © 2018 Al Brown. All rights reserved.
//

import UIKit
import SwiftWebSocket
import Reachability

//import Kurento

class ViewController: UIViewController {
    //MARK: Properties
    @IBOutlet weak var buttonDoWork: UIButton!
    var jsonRpcClient: NBMJSONRPCClient?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Actions
    @IBAction func buttonDoWorkDown(_ sender: Any) {
        //let device = UIDevice.string(for: UIDevice.deviceType())
        
        //print(device ?? "DeviceID")
        //print(RTCInitializeSSL())
        
        print("------ Calling WebSockets ------")
        //test1()
        setupRpcClient("test1")
    }
    
    func test1(){
        var messageNum = 0
        //let url = "wss://push-media2.aws-dev-rt.veritone.com/magicmirror"
        let url = "ws://localhost:8889/magicmirror"
        
        print("url = " + url)
        let msg = "{ \"id\": \"start\", \"adapterId\": \"123\", \"sourceId\": \"456\", \"sdpOffer\": \"\"}"
        
        let ws = WebSocket(url)
        let send : ()->() = {
            messageNum += 1
            print("send: \(msg)")
            ws.send(msg)
        }
        ws.event.open = {
            print("opened")
            send()
            print("send2: \(msg)")
            ws.send(msg)
        }
        ws.event.close = { code, reason, clean in
            print("close")
        }
        ws.event.error = { error in
            print("error \(error)")
        }
        ws.event.message = { message in
            if let text = message as? String {
                print("recv: \(text)")
                if messageNum == 10 {
                    ws.close()
                } else {
                    send()
                }
            }
        }
    }
    
    func setupRpcClient(_ offerSdp: String) {
        /*
         Default client configuration:
         
         Request timeout: 5 sec.
         Timeout request retries: 1
         Connect after initialization: YES
         */
        print("------ Starting setupRpcClient ------")
        let jsonRpcClientConfig = NBMJSONRPCClientConfiguration.default()
        //WebSocket URI
        //let wsURI = URL(string: "wss://push-media2.aws-dev-rt.veritone.com/magicmirror")
        let wsURI = URL(string: "ws://localhost:8889/magicmirror")
        //        let wsURI = URL(string: "https://dev-kurento-tmp-alb-1613733818.us-east-1.elb.amazonaws.com/magicmirror")
        //        let wsURI = URL(string: "http://54.157.192.19:8889")
        
        //If necessary modify client configuration, 'nil' configuration means default values
        print("#1 - Before Init")
        jsonRpcClient = NBMJSONRPCClient.init(url: wsURI,
                                            configuration: jsonRpcClientConfig, delegate: self)
        
        let params = ["id": "start", "sdpOffer": offerSdp, "adapterId": "123", "sourceId": "456"] as [String : Any]
        
        print("#2 - Before SEND")
        jsonRpcClient?.sendRequest(withMethod: "test", parameters: params, completion: { (response) in
            if (!(response != nil)) {
                print("Request with method publishVideo is gone on timeout!");
            }
        })
        
        
        print("------ Done setupRpcClient ------")
    }
}

extension ViewController: NBMWebRTCPeerDelegate, NBMJSONRPCClientDelegate, NBMRendererDelegate {
    
    /*****
     NBMRendererDelegate
     ******/
    
    func renderer(_ renderer: NBMRenderer!, streamDimensionsDidChange dimensions: CGSize) {
        print("streamDimensionsDidChange")
    }
    
    func rendererDidReceiveVideoData(_ renderer: NBMRenderer!) {
        print("rendererDidReceiveVideoData")
    }
    
    
    /*****
     NBMJSONRPCClientDelegate
     ******/
    
    func clientDidConnect(_ client: NBMJSONRPCClient!) {
        print("clientDidConnect")
    }
    
    func clientDidDisconnect(_ client: NBMJSONRPCClient!) {
        print("clientDidDisconnect")
        //        let isReachable = self.reachability?.isReachable()
        //        let retryAllowed = retryCount < 3
        //        if retryAllowed && isReachable! {
        //            retryCount += 1
        //            jsonRpcClient?.connect()
        //        } else if !retryAllowed || !isReachable! {
        //            print("Impossible to establish connection")
        //        }
    }
    
    func client(_ client: NBMJSONRPCClient!, didReceive request: NBMRequest!) {
        print("didReceive")
    }
    
    func client(_ client: NBMJSONRPCClient!, didFailWithError error: Error!) {
        print("didFailWithError: \(error.localizedDescription)")
    }
    
    /*****
     NBMWebRTCPeerDelegate
     ******/
    
    //Handle SDP offer generation
    func webRTCPeer(_ peer: NBMWebRTCPeer!, didGenerateOffer sdpOffer: RTCSessionDescription!, for connection: NBMPeerConnection!) {
        //TODO: Signal SDP offer for connection
        
        let params = ["id": "start", "sdpOffer": sdpOffer.sdp, "adapterId": "AAAAA", "sourceId": "BBBBBB"] as [String : Any]
        _ = jsonRpcClient?.sendRequest(withMethod: "publishVideo", parameters: params, completion: { (response) in
            
            print("Response: \(String(describing: response))")
            //If no response is returned, request is gone on timeout
            if (!(response != nil)) {
                print("Request with method publishVideo is gone on timeout!");
            }
            //Evaluate the response
            
            
            //If has a response error
            let responseError = response?.error;
            if ((responseError) != nil) {
                print("Response error: \(String(describing: responseError))");
            } else {
                //Response has a result
                print("Response result: \(String(describing: response?.result))");
            }
        })
        
    }
    
    func webRTCPeer(_ peer: NBMWebRTCPeer!, didGenerateAnswer sdpAnswer: RTCSessionDescription!, for connection: NBMPeerConnection!) {
        print("didGenerateAnswer sdpAnswer")
    }
    //Handle the gathering of ICE candidate for connection with specified identifier
    func webRTCPeer(_ peer: NBMWebRTCPeer!, hasICECandidate candidate: RTCIceCandidate!, for connection: NBMPeerConnection!) {
        //TODO: Signal ICE candidate for connection
        print("hasICECandidate candidate")
    }
    
    func webrtcPeer(_ peer: NBMWebRTCPeer!, iceStatusChanged state: RTCIceConnectionState, of connection: NBMPeerConnection!) {
        print("iceStatusChanged")
    }
    
    func webRTCPeer(_ peer: NBMWebRTCPeer!, didAdd remoteStream: RTCMediaStream!, of connection: NBMPeerConnection!) {
        print("didAdd remoteStream")
    }
    
    func webRTCPeer(_ peer: NBMWebRTCPeer!, didRemove remoteStream: RTCMediaStream!, of connection: NBMPeerConnection!) {
        print("didRemove")
    }
    
    func webRTCPeer(_ peer: NBMWebRTCPeer!, didAdd dataChannel: RTCDataChannel!) {
        print("didAdd")
    }
    
}

