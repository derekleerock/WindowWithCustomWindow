import UIKit

final class OverlayView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)

        // Explicity need to set this in order for AutoLayout to function properly.
        translatesAutoresizingMaskIntoConstraints = false

        // Set the zPosition to the highest possible value to ensure it is on top of all other views.
        layer.zPosition = CGFloat.greatestFiniteMagnitude

        // A solid color helps to illustrate that this view is displayed on top of all others.
        backgroundColor = .systemCyan
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ViewController: UIViewController {
    private var maybeMyCustomView: UIView? = nil

    // Displaying a modal window is included because I want to confirm that if a new window is displayed, that it can be displayed on top of all view controllers, even those that are presented modally on top of another.
    @IBAction func didTapNewModal(_ sender: UIButton) {
        debugPrint(#function)

        let vc = UIViewController()
        vc.title = "Modal VC"
        vc.view.backgroundColor = .systemOrange.withAlphaComponent(0.8)
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .overFullScreen

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
