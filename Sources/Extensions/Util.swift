import UIKit

extension Array {
  func get(_ index: Int) -> Element? {
    if (0..<count).contains(index) {
      return self[index]
    }
    return nil
  }
}

extension CGFloat {
  func clamp(_ minValue: CGFloat, _ maxValue: CGFloat) -> CGFloat {
    return self < minValue ? minValue : (self > maxValue ? maxValue : self)
  }
}

extension CGPoint {
  func translate(_ dx: CGFloat, dy: CGFloat) -> CGPoint {
    return CGPoint(x: self.x+dx, y: self.y+dy)
  }

  func transform(_ trans: CGAffineTransform) -> CGPoint {
    return self.applying(trans)
  }

  func distance(_ point: CGPoint) -> CGFloat {
    return sqrt(pow(self.x - point.x, 2)+pow(self.y - point.y, 2))
  }

  var inverted: CGPoint {
    return CGPoint(x: y, y: x)
  }
}

extension CGSize {
  func insets(by insets: UIEdgeInsets) -> CGSize {
    return CGSize(width: width - insets.left - insets.right, height: height - insets.top - insets.bottom)
  }
  var inverted: CGSize {
    return CGSize(width: height, height: width)
  }
}

func abs(_ left: CGPoint) -> CGPoint {
  return CGPoint(x: abs(left.x), y: abs(left.y))
}
func min(_ left: CGPoint, _ right: CGPoint) -> CGPoint {
  return CGPoint(x: min(left.x, right.x), y: min(left.y, right.y))
}
func + (left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x + right.x, y: left.y + right.y)
}
func += (left: inout CGPoint, right: CGPoint) {
  left.x += right.x
  left.y += right.y
}
func + (left: CGRect, right: CGPoint) -> CGRect {
  return CGRect(origin: left.origin + right, size: left.size)
}
func - (left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x - right.x, y: left.y - right.y)
}
func - (left: CGRect, right: CGPoint) -> CGRect {
  return CGRect(origin: left.origin - right, size: left.size)
}
func / (left: CGPoint, right: CGFloat) -> CGPoint {
  return CGPoint(x: left.x/right, y: left.y/right)
}
func * (left: CGPoint, right: CGFloat) -> CGPoint {
  return CGPoint(x: left.x*right, y: left.y*right)
}
func * (left: CGFloat, right: CGPoint) -> CGPoint {
  return right * left
}
func * (left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x*right.x, y: left.y*right.y)
}
prefix func - (point: CGPoint) -> CGPoint {
  return CGPoint.zero - point
}
func / (left: CGSize, right: CGFloat) -> CGSize {
  return CGSize(width: left.width/right, height: left.height/right)
}
func - (left: CGPoint, right: CGSize) -> CGPoint {
  return CGPoint(x: left.x - right.width, y: left.y - right.height)
}

prefix func - (inset: UIEdgeInsets) -> UIEdgeInsets {
  return UIEdgeInsets(top: -inset.top, left: -inset.left, bottom: -inset.bottom, right: -inset.right)
}

extension CGRect {
  var center: CGPoint {
    return CGPoint(x: midX, y: midY)
  }
  var bounds: CGRect {
    return CGRect(origin: .zero, size: size)
  }
  init(center: CGPoint, size: CGSize) {
    self.origin = center - size / 2
    self.size = size
  }
  var inverted: CGRect {
    return CGRect(origin: origin.inverted, size: size.inverted)
  }
}

func delay(_ delay: Double, closure:@escaping () -> Void) {
  DispatchQueue.main.asyncAfter(
    deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}
