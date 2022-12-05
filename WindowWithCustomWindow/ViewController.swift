import UIKit

class ViewController: UIViewController {
    // UIWindow needs to be a strong reference
    private var maybeOverlayWindow: UIWindow? = nil

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

        // If the new window has already been created, simply make sure it is displayed.
        if let overlayWindow = maybeOverlayWindow {
            overlayWindow.isHidden = false
            return
        }

        // Create custom UIView (I suppose this could be a new UIViewController as well)
        let myCustomView = UIView(frame: CGRect(x: 50.0, y: 50.0, width: UIScreen.main.bounds.width - 100.0, height: 100.0))
        myCustomView.backgroundColor = .blue

        // Get the current window scene to create a new UIWindow using it:
        if let currentWindowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            maybeOverlayWindow = UIWindow(windowScene: currentWindowScene)
        }

        // Important! Need to set both the bounds and the frame of the UIWindow:
        let newWindowPosition = CGRect(
            x: 0.0,
            y: 0.0,
            width: UIScreen.main.bounds.width,
            height: 100.0
        )
        maybeOverlayWindow?.bounds = newWindowPosition
        maybeOverlayWindow?.frame = newWindowPosition

        // WindowLevel determines where the window is placed in the hierarchy; alert is expected to be displayed on top of all other windows
        maybeOverlayWindow?.windowLevel = UIWindow.Level.alert

        // Setting the background color of the window helps to confirm the position of exactly where it is being displayed.
        maybeOverlayWindow?.backgroundColor = UIColor(white: 0, alpha: 0.5)

        // Add the custom subview (or root view controller) to the new window:
        maybeOverlayWindow?.addSubview(myCustomView)

        // Simply making the new window visible appears to display it.
        // (Some information online indicated that it was necessary to call .makeKeyAndVisible(), but this does not appear to be necessary.
        maybeOverlayWindow?.isHidden = false
    }

    @IBAction func didTapHideWindow(_ sender: UIButton) {
        debugPrint(#function)

        maybeOverlayWindow?.isHidden = true
    }
}
