platform :ios,'13.0'
use_frameworks!
inhibit_all_warnings!

target 'iOS_SDK_Demo'  do
pod 'Masonry', '1.1.0'
pod 'MJExtension', '~>3.0.17'
pod 'IQKeyboardManager', '6.5.19'
pod 'iOSDFULibrary','4.14.0'
pod 'MBProgressHUD'
end

post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      end
    end
  end
end
