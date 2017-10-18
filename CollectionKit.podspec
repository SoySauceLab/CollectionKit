Pod::Spec.new do |s|
  s.name             = "CollectionKit"
  s.version          = "1.0.2"
  s.summary          = "A modern swift framework for building data-driven reusable collection view components."

  s.description      = <<-DESC
                        A modern swift framework for building data-driven reusable collection view components.
                       DESC

  s.homepage         = "https://github.com/SoySauceLab/CollectionKit"
  s.license          = 'MIT'
  s.author           = { "Luke" => "lzhaoyilun@gmail.com" }
  s.source           = { :git => "https://github.com/SoySauceLab/CollectionKit.git", :tag => s.version.to_s }

  s.ios.deployment_target  = '8.0'
  s.ios.frameworks         = 'UIKit', 'Foundation'

  s.requires_arc = true

  s.source_files = 'Sources/**/*.swift'
end
