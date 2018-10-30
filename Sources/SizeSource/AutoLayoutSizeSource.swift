import UIKit

public typealias ClosureViewUpdateFn<Data, View> = (View, Data, Int) -> Void

open class AutoLayoutSizeSource<Data, View: UIView>: SizeSource<Data> {
  private let dummyView: View
  private let dummyViewUpdater: ClosureViewUpdateFn<Data, View>
  private let horizontalFittingPriority: UILayoutPriority
  private let verticalFittingPriority: UILayoutPriority
   public init(dummyView: View.Type, 
              horizontalFittingPriority: UILayoutPriority = .defaultHigh, 
              verticalFittingPriority: UILayoutPriority = .defaultLow, 
              viewUpdater: @escaping ClosureViewUpdateFn<Data, View>) {
    
    self.dummyView = View()
    self.dummyViewUpdater = viewUpdater
    self.horizontalFittingPriority = horizontalFittingPriority
    self.verticalFittingPriority = verticalFittingPriority
  }
   open override func size(at index: Int, data: Data, collectionSize: CGSize) -> CGSize {
    self.dummyViewUpdater(self.dummyView, data, index)
    
    return self.dummyView.systemLayoutSizeFitting(
      collectionSize, 
      withHorizontalFittingPriority: self.horizontalFittingPriority, 
      verticalFittingPriority: self.verticalFittingPriority)
  }
}
