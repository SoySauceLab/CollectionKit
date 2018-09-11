# CollectionKit

**Reimagining `UICollectionView`**

A modern Swift framework for building composable data-driven collection view.

[![Carthage compatible](https://img.shields.io/badge/Carthage-Compatible-brightgreen.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Version](https://img.shields.io/cocoapods/v/CollectionKit.svg?style=flat)](http://cocoapods.org/pods/CollectionKit)
[![License](https://img.shields.io/cocoapods/l/CollectionKit.svg?style=flat)](https://github.com/SoySauceLab/CollectionKit/blob/master/LICENSE?raw=true)
[![Build Status](https://travis-ci.org/SoySauceLab/CollectionKit.svg?branch=master)](https://travis-ci.org/SoySauceLab/CollectionKit)
[![codecov](https://codecov.io/gh/SoySauceLab/CollectionKit/branch/master/graph/badge.svg)](https://codecov.io/gh/SoySauceLab/CollectionKit)
![Xcode 8.2+](https://img.shields.io/badge/Xcode-8.2%2B-blue.svg)
![iOS 8.0+](https://img.shields.io/badge/iOS-8.0%2B-blue.svg)
![Swift 3.0+](https://img.shields.io/badge/Swift-3.0%2B-orange.svg)
[![Slack](https://slackin-axnycthvks.now.sh/badge.svg)](https://slackin-axnycthvks.now.sh)

### Migration Guide

[v2.0](/Resources/v2_migration.md)

### Features

* Rewritten `UICollectionView` on top of `UIScrollView`.
* Automatically diff data changes and update UI.
* Superb performance through cell reuse, batched reload, visible-only diff, & the use of swift value types.
* Builtin layout & animation systems specifically built for collections.
* Composable sections with independent layout.
* Strong type checking powered by Swift Generics.

## Install

```ruby
# CocoaPods
pod "CollectionKit"

# Carthage
github "SoySauceLab/CollectionKit"
```

## Getting Started

To start using CollectionKit, use `CollectionView` in place of `UICollectionView`. `CollectionView` is CollectionKit's alternative to `UICollectionView`. You give it a `Provider` object that tells `CollectionView` how to display a collection.

The simpliest way to construct a provider is by using `BasicProvider` class.

### BasicProvider

To build a `BasicProvider`, here is what you need:

* **DataSource**
  * an object that supplies data to the BasicProvider.
* **ViewSource**
  * an object that maps each data into a view, and update the view accordingly
* **SizeSource**
  * an function that gives the size for each cell.

It sounds complicated, but it really isn't. Here is a short example demostrating
how it all works.

```swift
let dataSource = ArrayDataSource(data: [1, 2, 3, 4])
let viewSource = ClosureViewSource(viewUpdater: { (view: UILabel, data: Int, index: Int) in
  view.backgroundColor = .red
  view.text = "\(data)"
})
let sizeSource = { (index: Int, data: Int, collectionSize: CGSize) -> CGSize in
  return CGSize(width: 50, height: 50)
}
let provider = BasicProvider(
  dataSource: dataSource,
  viewSource: viewSource,
  sizeSource: sizeSource
)

//lastly assign this provider to the collectionView to display the content
collectionView.provider = provider
```

<img src="https://cdn.rawgit.com/SoySauceLab/CollectionKit/4045170/Resources/example1.svg" />

Note that we used `ArrayDataSource` & `ClosureViewSource` here. These two classes are built-in to CollectionKit, and should be able to serve most jobs. You can implement other `dataSource` and `viewSource` as well. Imagine implementing a `NetworkDataSource` in your project, that retrives json data and parse into swift objects.


### Reload

It is easy to update the CollectionView with new data.

```swift
dataSource.data = [7, 8, 9]
```

This will trigger an update of the CollectionView that is served by this dataSource.

<img src="https://cdn.rawgit.com/SoySauceLab/CollectionKit/4045170/Resources/example2.svg" />

Note that `append` and other array mutating methods will also work.

```swift
dataSource.data.append(10)
dataSource.data.append(11)
dataSource.data.append(12)
```

<img src="https://cdn.rawgit.com/SoySauceLab/CollectionKit/4045170/Resources/example3.svg" />

We updated the array three times in this example. Each update is triggering a reload. You might be thinking that this is very computational intensive, but it isn't. CollectionKit is smart enough to only update once per layout cycle. It will wait until the next layout cycle to actually reload.

After executing the 3 lines above, CollectionView will still show `[7, 8, 9]`. But once the current run loop cycle is completed, CollectionView will update immediately. Your user won't notice any lag from this process.

To trigger an update immediately, you can call `collectionView.reloadData()` or `provider.reloadData()` or `dataSource.reloadData()`. 

To make collectionView reload on the next layout cycle, you can call `collectionView.setNeedsReload()` or `provider.setNeedsReload()` or `dataSource.setNeedsReload()`. You might already noticed, once you update the array inside `ArrayDataSource`, it is basically calling `setNeedsReload()` for you.

Note that if you assign an array to the dataSource and later update that array instead. It won't actually update the `CollectionView`

```swift
var a = [1, 2 ,3]
dataSource.data = a
a.append(5) // won't trigger an update be cause dataSource.data & a is now two different array.
a = [4 ,5 ,6] // also won't trigger an update
```

### Layout

Up to this point, the collection is still a bit ugly to look at. Every cell is left aligned and doesn't have space in between. You might want the views to be evenly spaced out, or you might want to add some spacing in between items or lines.

These can be achieved with Layout objects. Here is an example.

```swift
provider.layout = FlowLayout(spacing: 10, justifyContent: .center)
```

<img src="https://cdn.rawgit.com/SoySauceLab/CollectionKit/4045170/Resources/example4.svg" />

`FlowLayout` is a `Layout` class that it built-in to CollectionKit. There are many more built-in layouts including `WaterfallLayout` & `RowLayout`. You can also easily create your own layout.

`FlowLayout` is basically a better `UICollectionViewFlowLayout` that aligns items in row by row fashion. It supports `lineSpacing`, `interitemSpacing`, `alignContent`, `alignItems`, & `justifyContent`.

Every layout also supports `inset(by:)` and `transposed()` methods. 

`inset(by:)` adds an outer padding to the layout and return the result layout as `InsetLayout`. 

```swift
let inset = UIEdgeInset(top: 10, left: 10, bottom: 10, right: 10)
provider.layout = FlowLayout(spacing: 10).inset(by: inset)
```

<img src="https://cdn.rawgit.com/SoySauceLab/CollectionKit/4045170/Resources/example5.svg" />

`transposed()` converts a vertical layout into a horizontal layout or vice-versa. It returns the original layout wrapped inside a `TransposedLayout`

```swift
provider.layout = FlowLayout(spacing: 10).transposed()
```

<img src="https://cdn.rawgit.com/SoySauceLab/CollectionKit/4045170/Resources/example6.svg" />

You can also use them together like

```swift
let inset = UIEdgeInset(top: 10, left: 10, bottom: 10, right: 10)
provider.layout = FlowLayout(spacing: 10).transposed().inset(by: inset)
```

<img src="https://cdn.rawgit.com/SoySauceLab/CollectionKit/4045170/Resources/example7.svg" />


There can be a lot to talk about with Layouts. We will create more tutorial later to teach you how to create your own layout and show you some advance usages. In the mean time, feel free to dive in the source code. I promise you it is not complecated at all.

### Composing (ComposedProvider)

The best feature of CollectionKit, is that you can freely combine providers together into multiple sections within one CollectionView. And it is **REALLY EASY** to do so.

```swift
let finalProvider = ComposedProvider(sections: [provider1, provider2, provider3])

collectionView.provider = finalProvider
```

<img src="https://cdn.rawgit.com/SoySauceLab/CollectionKit/4045170/Resources/example8.svg" />

To update individual sections, just update its own `dataSource`.

```swift
provider2DataSource.data = [2]
```

<img src="https://cdn.rawgit.com/SoySauceLab/CollectionKit/4045170/Resources/example9.svg" />

You can also live update sections around.

```swift
finalProvider.sections = [provider2, provider3, provider1]
```

<img src="https://cdn.rawgit.com/SoySauceLab/CollectionKit/4045170/Resources/example10.svg" />

Or add more to it.

```swift
finalProvider.sections.append(provider4)
```

<img src="https://cdn.rawgit.com/SoySauceLab/CollectionKit/4045170/Resources/example11.svg" />

You can even put `ComposedProvider` into another `ComposedProvider` no problem.

```swift
let trulyFinalProvider = ComposedProvider(sections: [finalProvider, provider5])

collectionView.provider = trulyFinalProvider
```

#### How cool is that!

### Animation

CollectionKit offers a animation system which allows you to create fancy animations and adjust how cells are displayed. 

Here are some examples of custom animators that is included in the example project. They can be used in combination with any layout. Here we are using a transposed waterfall layout.

| Wobble  | Edge Shrink | Zoom |
| ------------- | ------------- | ------------- |
| <img width="200" src="http://lkzhao.com/public/posts/collectionKit/wobble.gif" />  | <img width="200" src="http://lkzhao.com/public/posts/collectionKit/edgeShrink.gif" /> | <img width="200" src="http://lkzhao.com/public/posts/collectionKit/zoom.gif" /> |

Animator can also perform animations when a cell is added/moved/deleted. Here is an example showing a 3d scale animation with a cascading effect.

<img width="200" src="http://lkzhao.com/public/posts/collectionKit/reloadAnimation.gif" />

It is easy to use an `Animator`. You can assign it to providers, cells, or to entire `CollectionView`.

```swift
// apply to the entire CollectionView
collectionView.animator = ScaleAnimator()

// apply to a single section, will override CollectionView's animator
provider.animator = FadeAnimator()

// apply to a single view, will take priority over all other animators
view.collectionAnimator = WobbleAnimator()
```

Note: that in order to use  `WobbleAnimator`, you have to include `pod "CollectionKit/WobbleAnimator"` subspec to your podfile.

#### Please checkout the example project to see many of these examples in action.

## Questions? Want to contribute?

Join our public [Slack](https://slackin-axnycthvks.now.sh)!
