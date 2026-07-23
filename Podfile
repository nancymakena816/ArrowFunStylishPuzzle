platform :ios, '17.0'

use_frameworks!

target 'Arrow Fun' do
  pod 'Skillz', '2026.0.14'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '17.0'
      config.build_settings['EXCLUDED_ARCHS'] = 'x86_64'
    end
  end
end
