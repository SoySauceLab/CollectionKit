import UIKit
import YetAnotherAnimationLibrary

extension CGPoint {
    var magnitude: CGFloat {
        return hypot(x, y)
    }
}
func + (l: CGPoint, r: CGPoint) -> CGPoint {
    return CGPoint(x: l.x + r.x, y: l.y + r.y)
}

extension CGFloat {
    func clamp(_ a: CGFloat, b: CGFloat) -> CGFloat {
        return CGFloat.minimum(CGFloat.maximum(self, a), b)
    }
}

class GestureViewController: UIViewController {

    let red = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))

    override func viewDidLoad() {
        super.viewDidLoad()

        red.center = view.center
        red.layer.cornerRadius = 7
        red.backgroundColor = UIColor(colorLiteralRed: 1.0, green: 0.5, blue: 0.5, alpha: 1.0)
        view.addSubview(red)

        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap(gr:))))
        red.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(pan(gr:))))

        red.layer.yaal.perspective.setTo(-1/500)

        let limit = CGFloat.pi / 3
        red.yaal.center.velocity => { 1 - $0.magnitude / 3000 } => red.yaal.alpha

        // 2d rotation
        red.yaal.center.velocity => { ($0.x / 1000).clamp(-limit, b: limit) } => red.yaal.rotation

        // 3d rotation
        red.yaal.center.velocity => { ($0.x / 1000).clamp(-limit, b: limit) } => red.yaal.rotationY
        red.yaal.center.velocity => { (-$0.y / 1000).clamp(-limit, b: limit) } => red.yaal.rotationX
    }

    func tap(gr: UITapGestureRecognizer) {
        red.yaal.center.animateTo(gr.location(in: view))
    }

    var beginPosition: CGPoint?
    func pan(gr: UIPanGestureRecognizer) {
        switch gr.state {
        case .began:
            beginPosition = red.center
            fallthrough
        case .changed:
            red.yaal.center.setTo(gr.translation(in: view) + beginPosition!)
        default:
            red.yaal.center.decay(initialVelocity:gr.velocity(in: nil), damping: 5)
        }
    }
}
