# Uncomment the next line to define a global platform for your project
platform :ios, '11.3'

#plugin 'cocoapods-jiffy'

use_frameworks!

pre_install do |installer|
    def installer.verify_no_static_framework_transitive_dependencies; end
end


target 'Test1' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks

  # Pods for Test1
  pod 'SwiftWebSocket'
#  pod 'SKYLINK'
  #pod 'AppRTC'
  #pod "libjingle_peerconnection"
  pod "WebRTC"


end
