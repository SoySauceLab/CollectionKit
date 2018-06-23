#  v2.0 Migration Guide

Focus of v2.0 will be towards API cleanliness & solves pain points with v1.0+

Main feature of v2.0:
1. Complete renaming of classes
    * With v1.0, naming of the classes weren't given enough thoughts. Names like `CollectionProvider`, `ViewCollectionProvider`, `ViewProvider`, `DataProvider`, etc.. are all quite confusing to use.
1. Removing confusing initializer
1. Sticky Header Support
1. Initial support for mixed data type
1. Layout cleanup
1. Internal architectural & performance improvement

## Breaking API Changes

### Name changes

These won't be blocking your from compiling your app since we included a typealias bridge from 1.3 to 2.0. Old names will be shown as deprecated. Checkout `Deprecated.swift` for more info.

```swift
AnyCollectionProvider -> Provider
CollectionDataProvider -> DataSource
CollectionViewProvider -> ViewSource
CollectionSizeProvider -> SizeSource
CollectionLayout -> Layout
CollectionPresenter -> Animator
CollectionProvider -> BasicProvider
CollectionComposer -> ComposedProvider
ViewCollectionProvider -> SimpleViewProvider
EmptyStateCollectionProvider -> EmptyStateProvider
SpaceCollectionProvider -> SpaceProvider
ClosureDataProvider -> ClosureDataSource
ClosureViewProvider -> ClosureViewSource
ArrayDataProvider -> ArrayDataSource
```

### BasicProvider (CollectionProvider in v1.3)

* variable name changes
```swift
dataProvider -> dataSource
viewProvider -> viewSource
sizeProvider -> sizeSource
presenter -> animator
```

* willReloadHandler & didReloadHandler is removed

* designated init is now changed to the following. while other initializer has been removed.
```swift
public init(identifier: String? = nil,
            dataSource: DataSource<Data>,
            viewSource: ViewSource<Data, View>,
            sizeSource: @escaping SizeSource<Data> = defaultSizeSource,
            layout: Layout = FlowLayout(),
            animator: Animator? = nil,
            tapHandler: TapHandler? = nil) {}
```

If you are using any of the convenient init, please change to the following:

```swift
CollectionProvider(
  data: data,
  viewUpdater: { (label: UILabel, data: Data, index: Int) in
    label.backgroundColor = .red
    label.layer.cornerRadius = 8
    label.textAlignment = .center
    label.text = "\(data)"
  },
  sizeProvider: { (index: Int, data: Data, collectionSize: CGSize) -> CGSize in
    return CGSize(width: 50, height: 50)
  }
)
->
BasicProvider(
  dataSource: ArrayDataSource(data: data),
  viewSource: ClosureViewSource(viewUpdater: { (label: UILabel, data: Data, index: Int) in
    label.backgroundColor = .red
    label.layer.cornerRadius = 8
    label.textAlignment = .center
    label.text = "\(data)"
  }),
  sizeSource: { (index: Int, data: Data, collectionSize: CGSize) -> CGSize in
    return CGSize(width: 50, height: 50)
  }
)
```

* TapHandler type is changed from

```swift
typealias TapHandler = (View, Int, DataSource<Data>) -> Void
```

to

```swift
typealias TapHandler = (TapContext) -> Void

protocol TapContext {
  var view: View { get }
  var index: Int { get }
  var dataSource: DataSource<Data> { get }
  var data: Data { get }
  func setNeedsReload() {}
}
```

### ComposedProvider (CollectionComposer in v1.3)

* following convenience init has been removed

```swift
public convenience init(identifier: String? = nil,
                        layout: CollectionLayout<AnyCollectionProvider> = FlowLayout(),
                        presenter: CollectionPresenter? = nil,
                        _ sections: AnyCollectionProvider...) {}
```

Please change the following:
```swift
 CollectionComposer(provider1, provider2, provider3)
 ->
 ComposedProvider(sections: [provider1, provider2, provider3])
```

### SimpleViewProvider (ViewCollectionProvider in v1.3)

* following convenience init has been removed

```swift
public convenience init(identifier: String? = nil,
                        _ views: UIView...,
                        sizeStrategy: (ViewSizeStrategy, ViewSizeStrategy) = (.fit, .fit),
                        insets: UIEdgeInsets = .zero) {}
```

Please change the following:
```swift
ViewCollectionProvider(view1, view2)
->
SimpleViewProvider(views: [view1, view2])
```

### Layout

**Layout** becomes data independent.

```swift
FlowLayout<Int> -> FlowLayout
```

**Layout** only receives an abstract object **LayoutContent** during layout, instead of receiving `dataProvider` & `sizeProvider`.

previously:
```swift
func layout(collectionSize: CGSize,
            dataProvider: CollectionDataProvider<Data>,
            sizeProvider: @escaping CollectionSizeProvider<Data>)
```

is now:
```swift
public protocol LayoutContext {
  var collectionSize: CGSize { get }
  var numberOfItems: Int { get }
  func data(at: Int) -> Any
  func identifier(at: Int) -> String
  func size(at: Int, collectionSize: CGSize) -> CGSize
}


func layout(context: LayoutContext) {}
```

## Animator (CollectionPresenter in v1.3)

The following has been removed. Base class `Animator` now doesn't do animation.

```swift
insertAnimation
deleteAnimation
updateAnimation
```

The following hass been added:

```
ScaleAnimator
FadeAnimator
```

The following has been moved from `CollectionKit` to `CollectionKitExample`

```swift
ZoomAnimator
```

### Other

`LabelCollectionProvider` & `CollectionViewCollectionProvider` has been removed.

They don't provide enough value to the core function of CollectionKit and makes the library bit more confusing.

