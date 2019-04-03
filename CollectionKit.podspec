Pod::Spec.new do |s|
  s.name             = "CollectionKit"
  s.version          = "2.4.0"
  s.summary          = "A modern swift framework for building data-driven reusable collection view components."

  s.description      = <<-DESC
                        ### Features

                        * Declaritive API for building collection view components
                        * Automatically update UI when data changes
                        * Composable & hot swappable sections, layouts, & animations
                        * Strong type checking powered by Swift Generics
                        * Reuse everything!

                        We think that populating collection view content should be as simple as building custom UIViews. Sections should be reusable and composable into one another. They should define their own layout be easily animatable as well. CollectionKit is our attempt in solving these problems. UICollectionView has been around for 10 years. It is time that we come up with something better **with Swift**.

                        Unlike traditional UICollectionView's `datasource`/`delegate` methods, CollectionKit uses a single **Provider** object that tells `CollectionView` exactly how to display & handle a collection.

                        These Providers are easy to construct, and infinitely composable. Providers also have their own animation and layout objects. You can have sections that layouts and behave differently with in a single `CollectionView`.

                        CollectionKit already provides many of the commonly used Providers out of the box. But you can still easily create reuseable Provider classes that generalizes on different types on data. Checkout examples down below!
                       DESC

  s.homepage         = "https://github.com/SoySauceLab/CollectionKit"
  s.license          = 'MIT'
  s.author           = { "Luke" => "lzhaoyilun@gmail.com" }
  s.source           = { :git => "https://github.com/SoySauceLab/CollectionKit.git", :tag => s.version.to_s }

  s.ios.deployment_target  = '8.0'
  s.ios.frameworks         = 'UIKit', 'Foundation'

  s.requires_arc = true

  s.default_subspecs = 'Core'

  s.subspec 'Core' do |cs|
    cs.source_files = 'Sources/**/*.swift'
  end

  s.subspec 'WobbleAnimator' do |cs|
    cs.dependency 'CollectionKit/Core'
    cs.dependency 'YetAnotherAnimationLibrary', "~> 1.4.0"
    cs.source_files = 'WobbleAnimator/**/*.swift'
  end
end
