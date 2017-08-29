# CollectionKit

#### Note: CollectionKit is still being developed. Majority of the components are there but API might change in the future.

A modern swift framework for building data-driven reusable collection view components.

* Declaritive API for constructing collection view content.
* Automatic diff and update
* Composible sections
* Composible layout
* Powerful animations API
* Built in pure Swift with generics
* Reuse everything!

Unlink the traditional UICollectionVIew `datasource`/`delegate` methods, CollectionKit uses a single Provider object that tells CollectionView exactly how to display and handle a collection.

* These Providers are composible. meaning that you can easily combine multiple Providers into a single Provider.
* Providers are also reusable. meaning that if you assign the Provider object to another CollectionView, it will display the same content.
* Providers also has its own layout information. Meaning that you can now have different sections each with its own layout.
Whats more exciting is that Providers can be combined with any layout as well!
* As an extra bonus, Providers can include an animation object called Presenter that handles animations and presentation of your view. 

CollectionKit already provides many of the commonly used Providers out of the box. But you can still easily create reuseable Provider classes that generalizes on different types on data and reuse them through out your app. Building collection view has never been this simple and flexible!

## Getting Started

To build a basic provider here is what you need:

```swift
let provider = CollectionProvider(
	data: [5, 4, 3, 2, 1] // provide an array of data
	viewUpdater: { (label: UILabel, index: Int, data: Int) in
		// update your view according to your data
		label.backgroundColor = .pink
		label.layer.cornerRadius = 8
		label.text = "\(data)"
    },
    sizeProvider: { (index: Int, data: Int, collectionSize: CGSize) -> CGSize in
    	return CGSize(width: 100, height: 50) // return your view size
	}
)
```

To display the content, just assign this provider to any instance of CollectionView.
```swift
collectionView.provider = provider
```

This provider display the following content:


