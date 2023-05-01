import UIKit

class GestureView: UIView {
    
    private let bothHandsRecognizer = BothHandsGestureRecognizer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewWasTapped))
        tapRecognizer.numberOfTapsRequired = 2
        self.addGestureRecognizer(tapRecognizer)
        
        let bothHandsRecognizer = BothHandsGestureRecognizer(target: self, action: #selector(bothHandsRecognizerDidChange))
        bothHandsRecognizer.require(toFail: tapRecognizer)
        self.addGestureRecognizer(bothHandsRecognizer)
        
        self.isUserInteractionEnabled = true
        self.isMultipleTouchEnabled = true
        self.isExclusiveTouch = false
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    @objc private func viewWasTapped(_ sender: UITapGestureRecognizer) {
        self.subviews.forEach { $0.removeFromSuperview() }
    }
    
    @objc private func bothHandsRecognizerDidChange(_ sender: BothHandsGestureRecognizer) {
        switch sender.state {
        case .possible:
            print("possible")
        case .began:
            print("began")
        case .changed:
            print("changed")
        case .ended:
            self.persist(views: sender.recognizedTouchesToViews.values.map { $0 })
        case .cancelled:
            print("cancelled")
        case .failed:
            print("failed")
        @unknown default:
            print("unknown")
        }
    }
    
    private func persist(views: [UIView]) {
        guard views.count >= 10 else { return }
        
        Hand.make(elements: views) { view in
            return view.center
        }.forEach { hand in
            hand.fingers.enumerated().forEach { index, finger in
                let view = TouchView(frame: .init(x: 0, y: 0, width: 100, height: 100))
                view.center = finger.center
                view.label.text = String(index)
                self.addSubview(view)
            }
        }
    }
}
