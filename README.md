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

### Features

* Rewritten `UICollectionView` on top of `UIScrollView`.
* Automatically diff data changes and update UI.
* Superb performance through cell reuse, batched reload, visible-only diff, & the use of swift value types.
* Builtin layout & animation systems specifically built for collections.
* Composable sections with independent layout.
* Strong type checking powered by Swift Generics.

### CollectionView

`CollectionView` is CollectionKit's alternative to `UICollectionView`. You give it a `CollectionProvider` object that tells `CollectionView` how to display & handle a collection.

Provider is easy to construct and composable as well. You can combine multiple providers together and easily create sections within a single `CollectionView`. Each provider can also have its own layout and presenter.

### Layout System

CollectionKit implements its own powerful layout system. Each provider can have its own layout. You can also specify a layout when combining multiple providers together. CollectionKit provides some of the common layouts out of the box, but you can also create your own layout.

* **FlowLayout** - better `UICollectionFlowLayout` - supports `alignItems`, `justifyContent`, & `alignContent`
* **WaterfallLayout** - a pinterest like waterfall layout
* **RowLayout** - a single row flowlayout that allows cell to fill up empty spaces.
* **InsetLayout** - adds extra padding around a existing layout
* **TransposeLayout** - rotate an existing layout. (vertical to horizontal or vice versa)
* **OverlayLayout** - overlay items on top of each other.

### Presenter System

CollectionKit offers a presenter system which allows you to create fancy animations and adjust how cells are displayed. Presenter can be applied to individual providers, cells, or to entire `CollectionView`.

Here are some examples of custom presenters that is included in the example project. Note that they can be used in combination with any layout. Here we are using a transposed waterfall layout.

| Wobble  | Edge Shrink | Zoom |
| ------------- | ------------- | ------------- |
| <img width="200" src="http://lkzhao.com/public/posts/collectionKit/wobble.gif" />  | <img width="200" src="http://lkzhao.com/public/posts/collectionKit/edgeShrink.gif" /> | <img width="200" src="http://lkzhao.com/public/posts/collectionKit/zoom.gif" /> |

Presenter can also perform animations when a cell is added/moved/deleted. Here is an example showing a 3d scale animation with a cascading effect.

<img width="200" src="http://lkzhao.com/public/posts/collectionKit/reloadAnimation.gif" />

#### Please checkout the example project to see many of these examples in action.

## Install

**CocoaPods**
```ruby
pod "CollectionKit"
```

**Carthage**
```
github "SoySauceLab/CollectionKit"
```

## Getting Started

[Getting Started Guide](https://soysaucelab.gitbooks.io/collectionkit-documentation/content/)

## Usage

To build a basic provider, here is what you need:

```swift
let provider1 = CollectionProvider(
    data: [1，2，3, 4], // provide an array of data, data can be any type
    viewUpdater: { (label: UILabel, data: Int, index: Int) in
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

### Composing & Layout

Use `CollectionComposer` to combine multiple providers into one. You can also supply layout objects to Provider & Composer.

```swift
provider1.layout = FlowLayout(spacing: 10)

let provider2 = CollectionProvider(
    data: ["A", "B"],
    viewUpdater: { (label: UILabel, data: String, index: Int) in
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

### Apply Presenter

```swift
// apply to the entire CollectionView
collectionView.presenter = WobblePresenter()

// apply to a single section, will override CollectionView's presenter
provider1.presenter = WobblePresenter()

// apply to a single view, will take priority over all other presenters
view.collectionPresenter = WobblePresenter()
```

See the [Getting Started Guide](https://soysaucelab.gitbooks.io/collectionkit-documentation/content/) for a in-depth tutorial on how to use CollectionKit.

## Questions? Want to contribute?

Join our public [Slack](https://slackin-axnycthvks.now.sh)!
