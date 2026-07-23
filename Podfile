platform :ios, '17.0'

use_frameworks!

target 'Arrow Fun' do
  pod 'Skillz', '2026.0.14'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '17.0'
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end

  # -----------------------------
  # Удаление bitcode из бинарников
  # -----------------------------
  frameworks = Dir.glob("Pods/**/*.{framework,xcframework}")

  frameworks.each do |framework|
    if framework.end_with?(".xcframework")
      # Проходим по всем платформам внутри xcframework
      Dir.glob("#{framework}/**/*.{framework,framework.dSYM}").each do |inner|
        next unless File.directory?(inner)

        # Бинарник обычно в: Foo.framework/Foo
        binary = Dir.glob("#{inner}/*").find { |f| File.basename(f) == File.basename(inner, ".framework") }
        next unless binary && File.file?(binary)

        system("#{bitcode_strip_path} -r #{binary} -o #{binary}")
      end
    else
      # Обычный .framework
      binary = Dir.glob("#{framework}/*").find { |f| File.basename(f) == File.basename(framework, ".framework") }
      next unless binary && File.file?(binary)

      system("#{bitcode_strip_path} -r #{binary} -o #{binary}")
    end
  end
end