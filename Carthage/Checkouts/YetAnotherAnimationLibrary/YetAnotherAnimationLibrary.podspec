Pod::Spec.new do |s|
  s.name             = "YetAnotherAnimationLibrary"
  s.version          = "1.1.0"
  s.summary          = "Designed for gesture-driven animations. Simple, fast and extensible."

  s.description      = <<-DESC
                        Designed for gesture-driven animations. Simple, fast and extensible.

                        It is written in pure swift 3.1 with protocol oriented design and extensive use of generics.
                       DESC

  s.homepage         = "https://github.com/lkzhao/YetAnotherAnimationLibrary"
  s.license          = 'MIT'
  s.author           = { "Luke" => "lzhaoyilun@gmail.com" }
  s.source           = { :git => "https://github.com/lkzhao/YetAnotherAnimationLibrary.git", :tag => s.version.to_s }
  
  s.ios.deployment_target  = '8.0'
  s.tvos.deployment_target  = '9.0'

  s.ios.frameworks         = 'UIKit', 'Foundation'

  s.requires_arc = true

  s.source_files = 'Sources/**/*.swift'
end
