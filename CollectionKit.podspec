Pod::Spec.new do |s|
  s.name             = "CollectionKit"
  s.version          = "0.0.5"
  s.summary          = "A modern swift framework for building data-driven reusable collection view components."

  s.description      = <<-DESC
                        A modern swift framework for building data-driven reusable collection view components.
                       DESC

  s.homepage         = "https://github.com/lkzhao/CollectionKit"
  s.screenshots     = "https://github.com/lkzhao/CollectionKit/blob/master/imgs/demo.gif?raw=true"
  s.license          = 'MIT'
  s.author           = { "Luke" => "lzhaoyilun@gmail.com" }
  s.source           = { :git => "https://github.com/lkzhao/CollectionKit.git", :tag => s.version.to_s }

  s.ios.deployment_target  = '8.0'
  s.ios.frameworks         = 'UIKit', 'Foundation'

  s.requires_arc = true

  s.source_files = 'Sources/**/*.swift'

  s.dependency 'YetAnotherAnimationLibrary', '~> 1.1.0'
  s.dependency 'Diff', '~> 0.5.3'
end
