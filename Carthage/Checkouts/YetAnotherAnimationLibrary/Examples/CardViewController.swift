import UIKit
import YetAnotherAnimationLibrary

class CardViewController: UIViewController {

    let gr = UIPanGestureRecognizer()
    var card: UIView!
    var backCard: UIView?

    func generateCard() -> UIView {
        let frame = UIEdgeInsetsInsetRect(view.bounds, UIEdgeInsets(top:120, left: 50, bottom: 120, right: 50))
        let card = UIView(frame: frame)

        card.layer.cornerRadius = 7
        card.backgroundColor = .white
        view.insertSubview(card, at: 0)

        card.yaal.center.value => { [weak view] newCenter in
            if let view = view {
                return (newCenter.x - view.center.x) / view.bounds.width
            }
            return nil
        } => card.yaal.rotation

        card.yaal.scale.value => { $0 * $0 } => card.yaal.alpha

        return card
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(colorLiteralRed: 1.0, green: 0.5, blue: 0.5, alpha: 1.0)
        gr.addTarget(self, action: #selector(pan(gr:)))
        view.addGestureRecognizer(gr)

        card = generateCard()
    }

    func pan(gr: UIPanGestureRecognizer) {
        let translation = gr.translation(in: view)
        switch gr.state {
        case .began:
            backCard = generateCard()
            backCard!.yaal.scale.setTo(0.7)
            fallthrough
        case .changed:
            card.yaal.center.setTo(CGPoint(x:translation.x + view.center.x, y:translation.y / 10 + view.center.y))
            backCard!.yaal.scale.setTo(abs(translation.x)/view.bounds.width * 0.3 + 0.7)
        default:
            if let backCard = backCard, abs(translation.x) > view.bounds.width / 4 {
                let finalX = translation.x < 0 ? -view.bounds.width : view.bounds.width*2
                card.yaal.center.animateTo(CGPoint(x:finalX, y:view.center.y)) { [card] _ in
                    card?.removeFromSuperview()
                }
                card = backCard
                card.yaal.scale.animateTo(1)
            } else {
                backCard?.yaal.scale.animateTo(0) { [backCard] _ in
                    backCard?.removeFromSuperview()
                }
                card.yaal.center.animateTo(view.center)
            }
            backCard = nil
        }
    }
}
