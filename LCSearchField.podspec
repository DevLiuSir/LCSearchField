Pod::Spec.new do |spec|

  spec.name         = "LCSearchField"

  spec.version      = "1.0.0"
  
  spec.summary      = "LCSearchField is a search box control customized for the macOS Cocoa platform!"
  
  spec.description  = <<-DESC
  LCSearchField is a search box control customized for the macOS Cocoa platform, providing custom appearance and style！
                   DESC
  
  spec.homepage     = "https://github.com/DevLiuSir/LCSearchField"
  
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  
  spec.author                = { "Marvin" => "93428739@qq.com" }
  
  spec.swift_versions        = ['5.0']
  
  spec.platform              = :osx
  
  spec.osx.deployment_target = "10.14"
  
  spec.source       = { :git => "https://github.com/DevLiuSir/LCSearchField.git", :tag => "#{spec.version}" }

  spec.source_files = "Sources/LCSearchField/**/*.{h,m,swift}"

end
