import UIKit

class TouchView: UIView {
    
    enum Appearance {
        static let unpressedBackgroundColor = UIColor.red
        static let pressedBackgroundColor = UIColor.yellow
        static let cornerRadius = CGFloat(30)
    }
    
    private(set) lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.font = .systemFont(ofSize: 50, weight: .semibold)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = true
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(viewWasLongPressed))
        recognizer.minimumPressDuration = 0.01
        self.addGestureRecognizer(recognizer)
        self.layer.cornerRadius = Appearance.cornerRadius
        self.backgroundColor = Appearance.unpressedBackgroundColor
        
        self.addSubview(self.label)
        NSLayoutConstraint.activate([
            self.label.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.label.topAnchor.constraint(equalTo: self.topAnchor),
            self.label.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.label.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    @objc private func viewWasLongPressed(_ sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began, .changed:
            sender.view?.backgroundColor = Appearance.pressedBackgroundColor
        default:
            sender.view?.backgroundColor = Appearance.unpressedBackgroundColor
        }
    }
}
