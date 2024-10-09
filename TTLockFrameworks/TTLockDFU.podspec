Pod::Spec.new do |s|
s.name          = "TTLockDFU"
s.version       = "3.4.5"
s.summary       = "TTLockDFU SDK for iOS."
s.homepage      = "https://github.com/ttlock/iOS_SDK_Demo"
s.license       = { :type => "MIT", :file => "LICENSE" }
s.author        = { "ttlock" => "chensg@sciener.cn" }
s.platform      = :ios, "9.0"
s.source        = { :git => "https://github.com/ttlock/iOS_SDK_Demo.git", :tag => "#{s.version}" }
s.vendored_frameworks = "TTLockFrameworks/TTLockDFU.xcframework"
s.preserve_paths      = "TTLockFrameworks/TTLockDFU.xcframework"
s.framework     = "CoreBluetooth"
s.library       = "z"
s.requires_arc  = true
s.swift_version   =  "4.0"
s.ios.deployment_target = "9.0"
s.dependency "iOSDFULibrary", '~> 4.11.0'
s.dependency "TTLock"
s.xcconfig     = { "OTHER_LDFLAGS" => "-ObjC" }
end
