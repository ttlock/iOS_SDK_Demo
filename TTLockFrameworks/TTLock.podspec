Pod::Spec.new do |s|
s.name          = "TTLock"
s.version       = "3.3.6"
s.summary       = "TTLock SDK for iOS."
s.homepage      = "https://github.com/ttlock/iOS_SDK_Demo"
s.license       = { :type => "MIT", :file => "LICENSE" }
s.author        = { "ttlock" => "chensg@sciener.cn" }
s.platform      = :ios, "9.0"
s.source        = { :git => "https://github.com/ttlock/iOS_SDK_Demo.git", :tag => "#{s.version}" }
s.vendored_frameworks = "TTLockFrameworks/TTLock.xcframework"
s.preserve_paths      = "TTLockFrameworks/TTLock.xcframework"
s.framework     = "CoreBluetooth"
s.requires_arc  = true 
s.ios.deployment_target = "9.0"
s.xcconfig     = { "OTHER_LDFLAGS" => "-ObjC" }
end
