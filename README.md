# CollectionKit

A modern Swift framework for building reusable data-driven collection components.

[![Carthage compatible](https://img.shields.io/badge/Carthage-Compatible-brightgreen.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Version](https://img.shields.io/cocoapods/v/CollectionKit.svg?style=flat)](http://cocoapods.org/pods/CollectionKit)
[![License](https://img.shields.io/cocoapods/l/CollectionKit.svg?style=flat)](https://github.com/SoySauceLab/CollectionKit/blob/master/LICENSE?raw=true)
[![Build Status](https://travis-ci.org/SoySauceLab/CollectionKit.svg?branch=master)](https://travis-ci.org/SoySauceLab/CollectionKit)
[![codecov](https://codecov.io/gh/SoySauceLab/CollectionKit/branch/master/graph/badge.svg)](https://codecov.io/gh/SoySauceLab/CollectionKit)
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/180876d603bf4b47a32cce5384526395)](https://www.codacy.com/app/lkzhao/CollectionKit?utm_source=github.com&utm_medium=referral&utm_content=SoySauceLab/CollectionKit&utm_campaign=badger)
![Xcode 8.2+](https://img.shields.io/badge/Xcode-8.2%2B-blue.svg)
![iOS 8.0+](https://img.shields.io/badge/iOS-8.0%2B-blue.svg)
![Swift 3.0+](https://img.shields.io/badge/Swift-3.0%2B-orange.svg)

#### Note: CollectionKit is still being developed. Majority of the components are there, but API might change in the future.

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
provider1.layout = FlowLayout(padding: 10)

let provider2 = CollectionProvider(
    data: ["A", "B"],
    viewUpdater: { (label: UILabel, index: Int, data: String) in
        label.backgroundColor = .blue
        label.layer.cornerRadius = 8
        label.textAlignment = .center
        label.text = data
    },
    layout: FlowLayout(padding: 10),
    sizeProvider: { (index: Int, data: String, collectionSize: CGSize) -> CGSize in
        return CGSize(width: 230, height: 50)
    }
)

collectionView.provider = CollectionComposer(
    layout: FlexLayout(padding: 20, justifyContent: .center, alignItems: .center),
    provider1,
    provider2
)
```

<img src="https://cdn.rawgit.com/SoySauceLab/CollectionKit/c36d783/Resources/example2.svg" />


See the [Getting Started Guide]() for a in-depth tutorial on how to use CollectionKit.


## Questions? Want to contribute?

Join our public [Discord](https://discord.gg/e8VSaw4)!
