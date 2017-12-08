//
//  TestUils.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-08-30.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit
import CollectionKit
import UIKit.UIGestureRecognizerSubclass

extension CollectionLayout where Data == CGSize {

  func mockLayout(parentSize: (CGFloat, CGFloat) = (300, 300), _ childSizes: (CGFloat, CGFloat)...) {
    layout(collectionSize: CGSize(width: parentSize.0, height: parentSize.1),
           dataProvider: ArrayDataProvider(data: sizes(childSizes)),
           sizeProvider: { (index, data, collectionSize) -> CGSize in
              return data
    })
  }

}

class SimpleTestProvider<Data>: CollectionProvider<Data, UILabel> {

  var data: [Data] {
    get { return (dataProvider as! ArrayDataProvider<Data>).data }
    set { (dataProvider as! ArrayDataProvider<Data>).data = newValue }
  }

  convenience init(data: [Data]) {
    self.init(
      dataProvider: ArrayDataProvider(data: data, identifierMapper: { _, data in "\(data)" }),
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
  }

}

func sizes(_ s: [(CGFloat, CGFloat)]) -> [CGSize] {
  return s.map { CGSize(width: $0.0, height: $0.1) }
}

func sizes(_ s: (CGFloat, CGFloat)...) -> [CGSize] {
  return sizes(s)
}

func frames(_ f: [(CGFloat, CGFloat, CGFloat, CGFloat)]) -> [CGRect] {
  return f.map { CGRect(x: $0.0, y: $0.1, width: $0.2, height: $0.3) }
}

func frames(_ f: (CGFloat, CGFloat, CGFloat, CGFloat)...) -> [CGRect] {
  return frames(f)
}


extension UITapGestureRecognizer {
  static var testLocation: CGPoint? = {
    let swizzling: (AnyClass, Selector, Selector) -> Void = { forClass, originalSelector, swizzledSelector in
      let originalMethod = class_getInstanceMethod(forClass, originalSelector)
      let swizzledMethod = class_getInstanceMethod(forClass, swizzledSelector)
      method_exchangeImplementations(originalMethod!, swizzledMethod!)
    }
    let originalSelector = #selector(location(in:))
    let swizzledSelector = #selector(test_location(in:))
    swizzling(UITapGestureRecognizer.self, originalSelector, swizzledSelector)
    return nil
  }()


  @objc dynamic func test_location(in view: UIView?) -> CGPoint {
    guard let testLocation = UITapGestureRecognizer.testLocation, let parent = self.view else { return test_location(in: view) }
    return (view ?? parent).convert(testLocation, from: parent)
  }
}
