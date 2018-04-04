//
//  ViewController.swift
//  Test1
//
//  Created by Al Brown on 4/3/18.
//  Copyright © 2018 Al Brown. All rights reserved.
//

import UIKit
import SwiftWebSocket
import WebRTC


class ViewController: UIViewController {
    //MARK: Properties
    @IBOutlet weak var buttonDoWork: UIButton!
    
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
        let device = UIDevice.string(for: UIDevice.deviceType())
        
        print(device ?? "DeviceID")
        print(RTCInitializeSSL())
        
        print("------ Calling WebSockets ------")
        test1()
    }
    
    func test1(){
        var messageNum = 0
        let url = "wss://push-media2.aws-dev-rt.veritone.com/magicmirror"
        
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
}

