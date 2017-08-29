# CollectionKit

A modern swift framework for building data-driven reusable collection view components.

[![Carthage compatible](https://img.shields.io/badge/Carthage-Compatible-brightgreen.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Version](https://img.shields.io/cocoapods/v/CollectionKit.svg?style=flat)](http://cocoapods.org/pods/CollectionKit)
[![License](https://img.shields.io/cocoapods/l/CollectionKit.svg?style=flat)](https://github.com/SoySauceLab/CollectionKit/blob/master/LICENSE?raw=true)
![Xcode 8.2+](https://img.shields.io/badge/Xcode-8.2%2B-blue.svg)
![iOS 8.0+](https://img.shields.io/badge/iOS-8.0%2B-blue.svg)
![Swift 3.0+](https://img.shields.io/badge/Swift-3.0%2B-orange.svg)

#### Note: CollectionKit is still being developed. Majority of the components are there, but API might change in the future.

* Declaritive API for constructing collection view content.
* Automatic diff and update
* Composable sections
* Composable layout
* Powerful animation API
* Built in pure Swift with generics
* Reuse everything!

Unlike traditional UICollectionView's `datasource`/`delegate` methods, CollectionKit uses a single **Provider** object that tells CollectionView exactly how to display a collection.

These Providers are composable, meaning that you can easily combine multiple Providers into a single Provider.
Providers are also reusable, if you assign the Provider object to another CollectionView, it will display the same content.
Providers also has its own layout information. Meaning that you can now have different sections each with its own layout.
Whats more exciting is that Providers can be combined with any layout as well!
As an extra bonus, Providers can include an animation object called **Presenter** that handles animations and presentation of your view. 

CollectionKit already provides many of the commonly used Providers out of the box. But you can still easily create reuseable Provider classes that generalizes on different types on data and reuse them through out your app. Building collection view has never been this simple and flexible!

## Install

via **CocoaPods** or **Carthage**.

## Usage

To build a basic provider, here is what you need:

```swift
let provider1 = CollectionProvider(
    data: [1，2，3, 4], // provide an array of data
    viewUpdater: { (label: UILabel, index: Int, data: Int) in
        // update your view according to your data
        label.backgroundColor = .pink
        label.layer.cornerRadius = 8
        label.textAlignment = .center
        label.text = "\(data)"
    },
    sizeProvider: { (index: Int, data: Int, collectionSize: CGSize) -> CGSize in
        return CGSize(width: 50, height: 50) // return your view size
    }
)
```

To display the content, just assign this provider to any instance of CollectionView.

```swift
collectionView.provider = provider1
```

<img src="https://cdn.rawgit.com/SoySauceLab/CollectionKit/478c049/Resources/example1.svg" />

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

<img src="https://cdn.rawgit.com/SoySauceLab/CollectionKit/478c049/Resources/example2.svg" />


See the [Getting Started Guide]() for a in-depth tutorial on how to use CollectionKit.


## Questions? Want to contribute?

Join our public [Discord](https://discord.gg/e8VSaw4)!
