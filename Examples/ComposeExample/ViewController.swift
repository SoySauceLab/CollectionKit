//
//  ViewController.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-07-23.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit
import CollectionKit

let bodyInset = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
let headerInset = UIEdgeInsets(top: 20, left: 16, bottom: 0, right: 16)

func section(title: String, subtitle: String? = nil, content: AnyCollectionProvider? = nil) -> AnyCollectionProvider {
  let titleSection = LabelCollectionProvider(text: title, font: .boldSystemFont(ofSize: 30), insets: headerInset)
  var sections: [AnyCollectionProvider] = [titleSection]
  if let subtitle = subtitle {
    let subtitleSection = LabelCollectionProvider(text: subtitle, font: .systemFont(ofSize: 20), insets: bodyInset)
    sections.append(subtitleSection)
  }
  if let content = content {
    sections.append(content)
  }
  return CollectionComposer(sections)
}

func space(_ height: CGFloat) -> AnyCollectionProvider {
  return SpaceCollectionProvider((.fill, .absolute(height)))
}


let presenterSection: AnyCollectionProvider = {
  let presenters = [
    ("Default", CollectionPresenter()),
    ("Wobble", WobblePresenter()),
    ("Zoom", ZoomPresenter()),
    ("Edge Shrink", EdgeShrinkPresenter()),
    ]
  let providerCollectionView = CollectionView()
  let provider = CollectionProvider(
    dataProvider: ArrayDataProvider(data: testImages),
    viewProvider: ClosureViewProvider(viewUpdater: { (view: UIImageView, data: UIImage, at: Int) in
      view.image = data
      view.layer.cornerRadius = 5
      view.clipsToBounds = true
    }),
    layout: WaterfallLayout<UIImage>(columns:2, insets: bodyInset, axis: .horizontal),
    sizeProvider: ImageSizeProvider(),
    presenter: presenters[0].1
  )
  providerCollectionView.provider = provider
  
  let buttonsCollectionView = CollectionView()
  buttonsCollectionView.showsHorizontalScrollIndicator = false
  let buttonsProvider = CollectionProvider(
    dataProvider: ArrayDataProvider(data: presenters),
    viewProvider: ClosureViewProvider(viewUpdater: { (view: SelectionButton, data: (String, CollectionPresenter), at: Int) in
      view.text = data.0
      view.backgroundColor = provider.presenter === data.1 ? .lightGray : .white
    }),
    layout: WaterfallLayout(columns: 1, insets: bodyInset, axis: .horizontal),
    sizeProvider: ClosureSizeProvider(sizeProvider: { _, data, maxSize in
      return CGSize(width: data.0.width(withConstraintedHeight: maxSize.height, font: UIFont.systemFont(ofSize:18)) + 20, height: maxSize.height)
    }),
    responder: ClosureResponder(onTap: { _, index, dataProvider in
      provider.presenter = dataProvider.data(at: index).1
      dataProvider.reloadData()
    }),
    presenter: WobblePresenter()
  )

  buttonsCollectionView.provider = buttonsProvider
  
  let buttonsCollectionViewProvider = ViewCollectionProvider(buttonsCollectionView, sizeStrategy: (.fill, .absolute(64)))
  let providerCollectionViewProvider = ViewCollectionProvider(providerCollectionView, sizeStrategy: (.fill, .absolute(400)))

  return section(title: "Presenter",
                 subtitle: "Presenter can be used customize the presentation of the child views. It is independent of the layout and have direct access to the view object. It is the perfect place to add animations to an existing provider.",
                 content: CollectionComposer(buttonsCollectionViewProvider, providerCollectionViewProvider))
}()

class ViewController: UIViewController {
  
  @IBOutlet var collectionView: CollectionView!
  
  override func viewDidLoad() {
    super.viewDidLoad()

    let imageCollectionView = CollectionView()
    imageCollectionView.provider = CollectionProvider(
      dataProvider: ArrayDataProvider(data: testImages),
      viewProvider: ClosureViewProvider(viewUpdater: { (view: UIImageView, data: UIImage, at: Int) in
        view.image = data
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
      }),
      layout: WaterfallLayout<UIImage>(insets: bodyInset, axis: .horizontal),
      sizeProvider: ImageSizeProvider()
    )
    let image1Section = ViewCollectionProvider(imageCollectionView, sizeStrategy: (.fill, .absolute(400)))

    let image2Section = CollectionProvider(
      dataProvider: ArrayDataProvider(data: testImages),
      viewProvider: ClosureViewProvider(viewUpdater: { (view: UIImageView, data: UIImage, at: Int) in
        view.image = data
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
      }),
      layout: WaterfallLayout<UIImage>(columns:2, insets: bodyInset, axis: .vertical),
      sizeProvider: ImageSizeProvider(),
      presenter: WobblePresenter()
    )
    
    let coreConceptSection: AnyCollectionProvider = {
      let concepts: [(String, String)] = [
        ("Data Provider", "The data source for the collection. It provides a homogenious set of data. The data will be passed to view provider, layout provider, and responder."),
        ("View Provider", "Provides corresponding UIView object for each of the data provided by the data source."),
        ("Layout Provider", "Provides layout information for the collection view."),
        ("Size Provider", "Provides size information to the layout provider."),
        ("Responder", "Provides event handler to the collection view events like tap, drag, & reload."),
        ("Presenter", "Can be used to customize the presentation of the child views. It is independent of the layout and have direct access to the view object. It is the perfect place to add animations to an existing provider.")
      ]
      let collectionView = CollectionView()
      collectionView.clipsToBounds = false
      collectionView.provider = CollectionProvider(
        dataProvider: ArrayDataProvider(data: concepts),
        viewProvider: ClosureViewProvider(viewUpdater: { (view: CardView, data: (String, String), at: Int) in
          view.title = data.0
          view.subtitle = data.1
        }),
        layout: WaterfallLayout(columns:1, insets: bodyInset, axis: .horizontal),
        sizeProvider: ClosureSizeProvider(sizeProvider: { (_, _, size) -> CGSize in
          return size
        }),
        responder: ClosureResponder(onTap: { [weak self] _, index, dataProvider in
          self?.present(MessagesViewController(), animated: true, completion: nil)
        })
      )
      
      return section(title: "Core Concepts", content: ViewCollectionProvider(collectionView, sizeStrategy: (.fill, .absolute(200))))
    }()
    
    collectionView.provider = CollectionComposer(
      space(100),
      section(title: "CollectionKit", subtitle: "A modern swift framework for building reusable collection view components."),
      space(20),
      coreConceptSection,
      space(20),
      section(title: "Horizontal Waterfall Layout", content: image1Section),
      space(20),
      section(title: "Vertical Waterfall Layout", content: image2Section),
      space(20),
      presenterSection
    )
  }
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
}

