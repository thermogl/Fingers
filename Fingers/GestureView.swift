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
            print(sender.recognizedTouchesToViews.count)
            if sender.recognizedTouchesToViews.count >= 10 {
                sender.recognizedTouchesToViews.forEach { pair in
                    let view = TouchView(frame: pair.value.frame)
                    self.addSubview(view)
                }
            }
        case .cancelled:
            print("cancelled")
        case .failed:
            print("failed")
        @unknown default:
            print("unknown")
        }
    }
}
