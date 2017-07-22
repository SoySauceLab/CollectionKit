//
//  DynamicView.swift
//  CollectionKitExample
//
//  Created by YiLun Zhao on 2016-02-21.
//  Copyright © 2016 lkzhao. All rights reserved.
//

import UIKit

let kTiltAnimationVelocityListenerIdentifier = "kTiltAnimationVelocityListenerIdentifier"

open class DynamicView: UIView {
  open var tapAnimation = true

  open var tiltAnimation = false {
    didSet {
      if tiltAnimation {
        yaal.center.velocity.changes.addListenerWith(identifier:kTiltAnimationVelocityListenerIdentifier) { [weak self] _, v in
          self?.velocityUpdated(v)
        }
      } else {
        yaal.center.velocity.changes.removeListenerWith(identifier: kTiltAnimationVelocityListenerIdentifier)
        yaal.rotationX.animateTo(0, stiffness: 150, damping: 7)
        yaal.rotationY.animateTo(0, stiffness: 150, damping: 7)
      }
    }
  }

  public override init(frame: CGRect) {
    super.init(frame: frame)
    layer.yaal.perspective.setTo(-1/500)
  }

  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    layer.yaal.perspective.setTo(-1/500)
  }

  func velocityUpdated(_ velocity: CGPoint) {
    let maxRotate = CGFloat.pi/6
    let rotateX = -(velocity.y / 3000).clamp(-maxRotate, maxRotate)
    let rotateY = (velocity.x / 3000).clamp(-maxRotate, maxRotate)
    yaal.rotationX.animateTo(rotateX, stiffness: 400, damping: 20)
    yaal.rotationY.animateTo(rotateY, stiffness: 400, damping: 20)
  }

  func touchAnim(touches:Set<UITouch>) {
    if let touch = touches.first, tapAnimation {
      var loc = touch.location(in: self)
      loc = CGPoint(x: loc.x.clamp(0, bounds.width), y: loc.y.clamp(0, bounds.height))
      loc = loc - bounds.center
      let rotation = CGPoint(x: -loc.y / bounds.height, y: loc.x / bounds.width)
      if #available(iOS 9.0, *) {
        let force = touch.maximumPossibleForce == 0 ? 1 : touch.force
        let rotation = rotation * (0.21 + force * 0.04)
        yaal.scale.animateTo(0.95 - force*0.01)
        yaal.rotationX.animateTo(rotation.x)
        yaal.rotationY.animateTo(rotation.y)
      } else {
        let rotation = rotation * 0.25
        yaal.scale.animateTo(0.94)
        yaal.rotationX.animateTo(rotation.x)
        yaal.rotationY.animateTo(rotation.y)
      }
    }
  }
  open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    touchAnim(touches: touches)
  }
  open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesMoved(touches, with: event)
    touchAnim(touches: touches)
  }
  open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    if tapAnimation {
      yaal.scale.animateTo(1.0, stiffness: 150, damping: 7)
      yaal.rotationX.animateTo(0, stiffness: 150, damping: 7)
      yaal.rotationY.animateTo(0, stiffness: 150, damping: 7)
    }
  }
  open override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
    super.touchesCancelled(touches!, with: event)
    if tapAnimation {
      yaal.scale.animateTo(1.0, stiffness: 150, damping: 7)
      yaal.rotationX.animateTo(0, stiffness: 150, damping: 7)
      yaal.rotationY.animateTo(0, stiffness: 150, damping: 7)
    }
  }
}
