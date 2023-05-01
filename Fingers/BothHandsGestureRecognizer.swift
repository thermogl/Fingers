import UIKit

class BothHandsGestureRecognizer: UIGestureRecognizer {
    
    private var touchToView = [UITouch: TouchView]()
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        guard self.state != .began else { return }
        
        touches.forEach { touch in
            let view = TouchView(frame: .init(origin: .zero, size: .init(width: 100, height: 100)))
            view.center = touch.visibleLocation(in: self.view)
            self.view?.addSubview(view)
            self.touchToView[touch] = view
        }
        if self.touchToView.count >= 10 {
            self.state = .began
        }
        self.updateLabels()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        touches.forEach { touch in
            self.touchToView[touch]?.center = touch.visibleLocation(in: self.view)
        }
        if self.touchToView.count >= 10 {
            self.state = .changed
        }
        self.updateLabels()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        self.handleRemoved(touches: touches)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        self.handleRemoved(touches: touches)
    }
    
    private(set) var recognizedTouchesToViews = [UITouch: TouchView]()
    private func handleRemoved(touches: Set<UITouch>) {
        touches.forEach { touch in
            self.recognizedTouchesToViews[touch] = self.touchToView[touch]
            self.touchToView[touch]?.removeFromSuperview()
            self.touchToView[touch] = nil
        }
        self.updateLabels()
        self.checkEnded()
    }
    
    private func checkEnded() {
        if self.touchToView.count < 10 {
            self.touchToView.forEach { self.recognizedTouchesToViews[$0.0] = $0.1 }
            if self.recognizedTouchesToViews.count >= 10 {
                self.state = .ended
            } else {
                self.state = .failed
            }
        }
    }
    
    override func reset() {
        self.touchToView.forEach {
            $0.value.removeFromSuperview()
        }
        self.touchToView.removeAll()
        self.recognizedTouchesToViews.removeAll()
    }
    
    private func updateLabels() {
        let touchViewCount = self.touchToView.count
        let sortedViews = self.touchToView.values.sorted(by: { $0.frame.minX < $1.frame.minX })
        sortedViews.enumerated().forEach { (index, view) in
            view.label.text = .init(index)
            view.isHidden = touchViewCount < 8
        }
    }
}

extension UITouch {
    func visibleLocation(in view: UIView?) -> CGPoint {
        var location = self.location(in: view)
        location.y -= 50
        return location
    }
}
