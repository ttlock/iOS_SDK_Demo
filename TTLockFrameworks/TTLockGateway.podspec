Pod::Spec.new do |s|
s.name          = "TTLockGateway"
s.version       = "3.0.0"
s.summary       = "G1 SDK for iOS."
s.homepage      = "https://github.com/ttlock/iOS_SDK_Demo"
s.license       = { :type => "MIT", :file => "LICENSE" }
s.author        = { "ttlock" => "chensg@sciener.cn" }
s.platform      = :ios, "9.0"
s.source        = { :git => "https://github.com/ttlock/iOS_SDK_Demo.git", :tag => "#{s.version}" }
s.vendored_frameworks = "TTLockFrameworks/TTLockGateway.framework"
s.preserve_paths      = "TTLockFrameworks/TTLockGateway.framework"
s.library       = "z"
s.requires_arc  = true
end

