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

        // Tag this view to allow us to find it more easily when we need to perform a hit test.
        tag = Int.max

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

        // Purposely pin the button to the top of the overlay view to confirm that touch events are received.
        // NOTE: If the modal view controller is not presented using "full screen", then the top-most part of that presented view controller will not receive these touch events.
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: button.superview!.topAnchor),
            button.centerXAnchor.constraint(equalTo: button.superview!.centerXAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func didTapButton(sender: UIButton) {
        debugPrint(#function)
    }
}

final class CustomNavigationBar: UINavigationBar {
    private weak var maybeOverlayView: OverlayView? = nil

    // This method fires both when tapping inside the navigation bar, as well as tapping inside the main view (which I think is unexpected, but this appears to be how this is functioning)
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        debugPrint("CustomNavigationBar.hitTest(_ point: \(point), with event: \(String(describing: event))")

        // Get a (weak) reference to the overlay view and hold onto it to allow us to perform a hit test against this view.
        if maybeOverlayView == nil {
            if
                let firstWindowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                let firstWindow = firstWindowScene.windows.first(where: { $0.isKeyWindow })
            {
                maybeOverlayView = firstWindow.viewWithTag(Int.max) as? OverlayView
            }
        }

        if
            let overlayView = maybeOverlayView,
            overlayView.isHidden == false
        {
            let pointLocationInOverlayView = convert(point, to: overlayView)
            let pointIsInsideOverlayView = overlayView.point(inside: pointLocationInOverlayView, with: event)

            debugPrint(" >>> pointLocationInOverlayView: \(pointLocationInOverlayView)")
            debugPrint(" >>>   pointIsInsideOverlayView: \(pointIsInsideOverlayView)")

            if pointIsInsideOverlayView {
                return overlayView.hitTest(pointLocationInOverlayView, with: event)
            }
        }

        return super.hitTest(point, with: event)
    }
}

final class CustomNavigationController: UINavigationController {
    override init(rootViewController: UIViewController) {
        super.init(navigationBarClass: CustomNavigationBar.self, toolbarClass: nil)

        modalPresentationStyle = .fullScreen
        viewControllers = [rootViewController]
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class ModalViewController: UIViewController {
    init() {
        super.init(nibName: nil, bundle: nil)

        title = "Modal VC"
        view.backgroundColor = .systemOrange
        modalTransitionStyle = .coverVertical
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
        let nav = CustomNavigationController(rootViewController: vc)

        let closeBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(didTapCloseBarButtonItem)
        )
        closeBarButtonItem.tintColor = UIColor.black
        vc.navigationItem.setRightBarButton(closeBarButtonItem, animated: true)

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
                maybeMyCustomView!.leadingAnchor.constraint(equalTo: maybeMyCustomView!.superview!.safeAreaLayoutGuide.leadingAnchor, constant: 60.0),
                maybeMyCustomView!.trailingAnchor.constraint(equalTo: maybeMyCustomView!.superview!.safeAreaLayoutGuide.trailingAnchor, constant: -60.0),
                maybeMyCustomView!.heightAnchor.constraint(equalToConstant: 100.0)
            ])
        }
    }

    @IBAction func didTapHideWindow(_ sender: UIButton) {
        debugPrint(#function)

        maybeMyCustomView?.isHidden = true
    }

    @objc func didTapCloseBarButtonItem(sender: UIBarButtonItem) {
        presentedViewController?.dismiss(animated: true)
    }
}
