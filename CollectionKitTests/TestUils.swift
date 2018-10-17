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

extension Layout {

  struct MockLayoutContext: LayoutContext {
    var parentSize: (CGFloat, CGFloat)
    var childSizes: [(CGFloat, CGFloat)]
    var collectionSize: CGSize {
      return CGSize(width: parentSize.0, height: parentSize.1)
    }
    var numberOfItems: Int {
      return childSizes.count
    }
    func data(at: Int) -> Any {
      return childSizes[at]
    }
    func identifier(at: Int) -> String {
      return "\(at)"
    }
    func size(at: Int, collectionSize: CGSize) -> CGSize {
      let size = childSizes[at]
      return CGSize(width: size.0, height: size.1)
    }
  }

  func mockLayout(parentSize: (CGFloat, CGFloat) = (300, 300), _ childSizes: (CGFloat, CGFloat)...) {
    layout(context: MockLayoutContext(parentSize: parentSize, childSizes: childSizes))
  }
}

class SimpleTestProvider<Data>: BasicProvider<Data, UILabel> {

  var data: [Data] {
    get { return (dataSource as! ArrayDataSource<Data>).data }
    set { (dataSource as! ArrayDataSource<Data>).data = newValue }
  }

  convenience init(data: [Data]) {
    self.init(
      dataSource: ArrayDataSource(data: data, identifierMapper: { _, data in "\(data)" }),
      viewSource: ClosureViewSource(viewUpdater: { (label: UILabel, data: Data, index: Int) in
        label.backgroundColor = .red
        label.layer.cornerRadius = 8
        label.textAlignment = .center
        label.text = "\(data)"
      }),
      sizeSource: ClosureSizeSource(sizeSource: { (index: Int, data: Data, collectionSize: CGSize) -> CGSize in
        return CGSize(width: 50, height: 50)
      })
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
