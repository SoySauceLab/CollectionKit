# CollectionKit

**Kill `UICollectionView`**

A modern Swift framework for building reusable data-driven collection components.

[![Carthage compatible](https://img.shields.io/badge/Carthage-Compatible-brightgreen.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Version](https://img.shields.io/cocoapods/v/CollectionKit.svg?style=flat)](http://cocoapods.org/pods/CollectionKit)
[![License](https://img.shields.io/cocoapods/l/CollectionKit.svg?style=flat)](https://github.com/SoySauceLab/CollectionKit/blob/master/LICENSE?raw=true)
[![Build Status](https://travis-ci.org/SoySauceLab/CollectionKit.svg?branch=master)](https://travis-ci.org/SoySauceLab/CollectionKit)
[![codecov](https://codecov.io/gh/SoySauceLab/CollectionKit/branch/master/graph/badge.svg)](https://codecov.io/gh/SoySauceLab/CollectionKit)
![Xcode 8.2+](https://img.shields.io/badge/Xcode-8.2%2B-blue.svg)
![iOS 8.0+](https://img.shields.io/badge/iOS-8.0%2B-blue.svg)
![Swift 3.0+](https://img.shields.io/badge/Swift-3.0%2B-orange.svg)
[![Slack](https://slackin-axnycthvks.now.sh/badge.svg)](https://slackin-axnycthvks.now.sh)

### Features

* Provide a custom `CollectionView` class built on top of `UIScrollView` that is far more customizable than `UICollectionView`.
* Automatically diff data changes and update UI.
* Superb performance through cell reuse, batched reload, visible-only diff, & the use of swift value types.
* Extendable animation layer specifically built for collections.
* Composable & hot swappable sections with independent layout.
* Strong type checking powered by Swift Generics.
* Builtin layouts and animators that you can use out of the box.

We think that populating collection view content should be as simple as building custom UIViews. Sections should be reusable and composable into one another. They should define their own layout be easily animatable as well. CollectionKit is our attempt in solving these problems. UICollectionView has been around for 10 years. It is time that we come up with something better **with Swift**.

Unlike traditional `UICollectionView`'s `datasource`/`delegate` methods, CollectionKit uses a single **Provider** object that tells `CollectionView` exactly how to display & handle a collection.

These Providers are easy to construct, and composable as well. Providers can also provider their own animation and layout objects. It is easy to create sections with different layout and behaviour within a single `CollectionView`.

### Layout System

CollectionKit implements its own powerful layout system. Each section can have its own layout. You can also specify a layout when combining multiple section together. CollectionKit provides some of the common layouts out of the box:

* **FlowLayout** - better `UICollectionFlowLayout` - supports `alignItems`, `justifyContent`, & `alignContent`
* **WaterfallLayout** - a pinterest like waterfall layout
* **RowLayout** - a single row flowlayout that allows cell to fill up empty spaces.
* **InsetLayout** - adds extra padding around a existing layout
* **TransposeLayout** - rotate an existing layout. (vertical to horizontal or vice versa)
* **OverlayLayout** - overlay items on top of each other.

### Presenter System

CollectionKit offers a presenter system which allows you to create fancy animations and adjust how cells are displayed. 

Presenters are easy to write. Here are some examples of custom presenters that is included in the example project. They can be used with any layout. Here we are using a transposed waterfall layout.

| Wobble  | Edge Shrink | Zoom |
| ------------- | ------------- | ------------- |
| <img width="200" src="http://lkzhao.com/public/posts/collectionKit/wobble.gif" />  | <img width="200" src="http://lkzhao.com/public/posts/collectionKit/edgeShrink.gif" /> | <img width="200" src="http://lkzhao.com/public/posts/collectionKit/zoom.gif" /> |

Presenter can also perform animations when a cell is added/moved/deleted. Here is an example showing a 3d scale animation with a cascading effect.

<img width="200" src="http://lkzhao.com/public/posts/collectionKit/reloadAnimation.gif" />

Using a presenter is very simple. Just assign your presenter to a `CollectionView`, a `CollectionProvider`, or even any `UIView`.

```swift
// apply to the entire collection view
collectionView.presenter = WobblePresenter()

// apply to a single section, will override collection view presenter
provider1.presenter = WobblePresenter()

// apply to a single view, will override collection view or section presenter
view.collectionPresenter = WobblePresenter()
```

#### Please checkout the example project to see many of these examples in action.

## Install

via **CocoaPods** or **Carthage**.

## Usage

To build a basic provider, here is what you need:

```swift
let provider1 = CollectionProvider(
    data: [1，2，3, 4], // provide an array of data, data can be any type
    viewUpdater: { (label: UILabel, index: Int, data: Int) in
        // update your view according to your data, view can be any subclass of UIView
        label.backgroundColor = .red
        label.layer.cornerRadius = 8
        label.textAlignment = .center
        label.text = "\(data)"
    },
    sizeProvider: { (index: Int, data: Int, collectionSize: CGSize) -> CGSize in
        return CGSize(width: 50, height: 50) // return your cell size
    }
)
```

To display the content, just assign this provider to any instance of `CollectionView`.

```swift
collectionView.provider = provider1
```

<img src="https://cdn.rawgit.com/SoySauceLab/CollectionKit/c36d783/Resources/example1.svg" />

### Composing

Use `CollectionComposer` to combine multiple providers into one. You can also supply layout objects to Provider & Composer.

```swift
provider1.layout = FlowLayout(spacing: 10)

let provider2 = CollectionProvider(
    data: ["A", "B"],
    viewUpdater: { (label: UILabel, index: Int, data: String) in
        label.backgroundColor = .blue
        label.layer.cornerRadius = 8
        label.textAlignment = .center
        label.text = data
    },
    layout: FlowLayout(spacing: 10),
    sizeProvider: { (index: Int, data: String, collectionSize: CGSize) -> CGSize in
        return CGSize(width: 230, height: 50)
    }
)

collectionView.provider = CollectionComposer(
    layout: FlowLayout(spacing: 20, justifyContent: .center, alignItems: .center),
    provider1,
    provider2
)
```

<img src="https://cdn.rawgit.com/SoySauceLab/CollectionKit/c36d783/Resources/example2.svg" />


See the [Getting Started Guide](https://soysaucelab.gitbooks.io/collectionkit-documentation/content/) for a in-depth tutorial on how to use CollectionKit.


## Questions? Want to contribute?

Join our public [Slack](https://slackin-axnycthvks.now.sh)!
