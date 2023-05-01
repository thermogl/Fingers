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
        
        Hand.make(elements: self.touchToView.values.map { $0 }) { view in
            return view.center
        }.forEach { hand in
            hand.fingers.enumerated().forEach { index, finger in
                finger.label.text = String(index)
                finger.isHidden = touchViewCount < 8
                print(touchViewCount)
            }
        }
    }
}

struct Hand<Element> {
    let side: Side
    enum Side {
        case left
        case right
    }
    let fingers: [Element]
    
    static func make(elements: [Element], pointProvider: (Element) -> CGPoint) -> [Hand] {
        guard elements.count > 1 else { return [.init(side: .left, fingers: elements)] }
        
        let midCenterPoint = elements.map { pointProvider($0) }.getMidPoint()
        
        let leftElements = elements.filter { pointProvider($0).x < midCenterPoint.x }
        let rightElements = elements.filter { pointProvider($0).x > midCenterPoint.x }
        
        let leftCenterPoint = leftElements.map { pointProvider($0) }.getMidPoint()
        let rightCenterPoint = rightElements.map { pointProvider($0) }.getMidPoint()
        
        let sortedLeftElements = leftElements.sorted { element1, element2 in
            return pointProvider(element1)
                .angleForLeftHand(using: leftCenterPoint) >
            pointProvider(element2)
                .angleForLeftHand(using: leftCenterPoint)
        }
        let sortedRightElements = rightElements.sorted { element1, element2 in
            return pointProvider(element1)
                .angleForLeftHand(using: rightCenterPoint) <
                    pointProvider(element2)
                .angleForLeftHand(using: rightCenterPoint)
        }
        return [
            .init(side: .left, fingers: sortedLeftElements),
            .init(side: .right, fingers: sortedRightElements)
        ]
    }
}

extension UITouch {
    func visibleLocation(in view: UIView?) -> CGPoint {
        var location = self.location(in: view)
        location.y -= 50
        return location
    }
}

extension Collection where Element == CGPoint {
    func getMidPoint() -> CGPoint {
        let totalCenterPoint = self.reduce(into: CGPoint.zero) { partialResult, point in
            partialResult.x += point.x
            partialResult.y += point.y
        }
        let numPoints = CGFloat(self.count)
        let midCenterPoint = CGPoint(
            x: totalCenterPoint.x / numPoints,
            y: totalCenterPoint.y / numPoints
        )
        return midCenterPoint
    }
}

extension CGPoint {
    
    func angleForLeftHand(using: CGPoint) -> CGFloat {
        let deltaX = using.x - self.x
        let deltaY = using.y - self.y
        return atan2(deltaX, deltaY)
    }
}
