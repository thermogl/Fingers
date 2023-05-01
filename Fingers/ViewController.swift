import UIKit

class ViewController: UIViewController {

    private lazy var gestureView: GestureView = {
        let view = GestureView()
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(self.gestureView)
        NSLayoutConstraint.activate([
            self.gestureView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.gestureView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.gestureView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.gestureView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ])
    }
}
