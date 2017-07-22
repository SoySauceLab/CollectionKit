Pod::Spec.new do |s|
  s.name             = "CollectionKit"
  s.version          = "0.0.1"
  s.summary          = "Modern UICollectionView alternative. Provides data-driven reusable components for building collections."

  s.description      = <<-DESC
                        Modern UICollectionView alternative. Provides data-driven reusable components for building collections.
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
end
