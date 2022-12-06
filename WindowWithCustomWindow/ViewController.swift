import UIKit

final class OverlayView: UIView {
    private var button: UIButton!

    override init(frame: CGRect) {
        super.init(frame: frame)

        // Explicity need to set this in order for AutoLayout to function properly.
        translatesAutoresizingMaskIntoConstraints = false

        // Set the zPosition to the highest possible value to ensure it is on top of all other views.
        layer.zPosition = CGFloat.greatestFiniteMagnitude

        // A solid color helps to illustrate that this view is displayed on top of all others.
        backgroundColor = .systemYellow

        // Add button on top of view which should receive interaction events.
        button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Perform Some Action", for: .normal)
        button.addTarget(
            self,
            action: #selector(didTapButton),
            for: .touchUpInside
        )
        addSubview(button)

        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: button.superview!.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: button.superview!.centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func didTapButton(sender: UIButton) {
        debugPrint(#function)
    }
}

final class ModalViewController: UIViewController {
    init() {
        super.init(nibName: nil, bundle: nil)

        title = "Modal VC"
        view.backgroundColor = .systemOrange.withAlphaComponent(0.8)
        modalTransitionStyle = .coverVertical
        modalPresentationStyle = .overFullScreen
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class ViewController: UIViewController {
    private var maybeMyCustomView: UIView? = nil

    // Displaying a modal window is included because I want to confirm that if a new window is displayed, that it can be displayed on top of all view controllers, even those that are presented modally on top of another.
    @IBAction func didTapNewModal(_ sender: UIButton) {
        debugPrint(#function)

        let vc = ModalViewController()
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true, completion: nil)
    }

    @IBAction func didTapShowWindow(_ sender: UIButton) {
        debugPrint(#function)

        // If the new view has already been created, simply make sure it is visible.
        if let myCustomView = maybeMyCustomView {
            myCustomView.isHidden = false
            return
        }

        // Create custom UIView to be the overlay view. AutoLayout will determine the
        //      position and size.
        maybeMyCustomView = OverlayView(frame: .zero)

        if
            let firstWindowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let firstWindow = firstWindowScene.windows.first(where: { $0.isKeyWindow })
        {
            // Add the view directly to the key window as a subview
            firstWindow.addSubview(maybeMyCustomView!)

            NSLayoutConstraint.activate([
                maybeMyCustomView!.topAnchor.constraint(equalTo: maybeMyCustomView!.superview!.safeAreaLayoutGuide.topAnchor, constant: 0.0),
                maybeMyCustomView!.leadingAnchor.constraint(equalTo: maybeMyCustomView!.superview!.leadingAnchor, constant: 0.0),
                maybeMyCustomView!.trailingAnchor.constraint(equalTo: maybeMyCustomView!.superview!.trailingAnchor, constant: 0.0),
                maybeMyCustomView!.heightAnchor.constraint(equalToConstant: 100.0)
            ])
        }
    }

    @IBAction func didTapHideWindow(_ sender: UIButton) {
        debugPrint(#function)

        maybeMyCustomView?.isHidden = true
    }
}
