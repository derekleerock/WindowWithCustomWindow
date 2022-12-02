import UIKit

class ViewController: UIViewController {

    // UIWindow needs to be a strong reference:
    private var maybeOverlayWindow: UIWindow? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


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

        // Tried and didn't work
//        let vc = UIViewController()
//        vc.title = "New Window VC"
//        vc.view.backgroundColor = .blue

//        let newWindow = UIWindow(frame: CGRect(x: 0.0, y: 0.0, width: 200.0, height: 100.0))
//        newWindow.rootViewController = vc
//        newWindow.windowLevel = .alert


        // .......


//        UIApplication.shared.windows.append(newWindow)


        // .......


        // "To create a scene programmatically, call the requestSceneSessionActivation(_:userActivity:options:errorHandler:) method of UIApplication."
//        let newScene = UIApplication.shared.requestSceneSessionActivation(nil, userActivity: nil, options: nil)
//        newScene


        // .......


        // The following approach seems to be working for me:

        if let overlayWindow = maybeOverlayWindow {
            overlayWindow.isHidden = false
            return
        }

        // Create custom UIView:
        let myCustomView = UIView(frame: CGRect(x: 50.0, y: 50.0, width: UIScreen.main.bounds.width - 100.0, height: 100.0))
        myCustomView.backgroundColor = .blue

        // Get the current window scene to create a new UIWindow using it:
        if let currentWindowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            maybeOverlayWindow = UIWindow(windowScene: currentWindowScene)
        }

        // Important! Need to set both the bounds and the frame of the UIWindow:
        maybeOverlayWindow?.bounds = CGRect(
            x: 0.0,
            y: 0.0,
            width: UIScreen.main.bounds.width,
            height: 100.0
        )
        maybeOverlayWindow?.frame = maybeOverlayWindow?.bounds ?? .zero

        // WindowLevel determines where the window is placed in the hierarchy; alert should be on top of all other windows
        maybeOverlayWindow?.windowLevel = UIWindow.Level.alert

        // UIWindow configuration....
        maybeOverlayWindow?.backgroundColor = UIColor(white: 0, alpha: 0.5)

        // Add the custom subview (or root view controller) to the new window
        maybeOverlayWindow?.addSubview(myCustomView)
        //overlayWindow.rootViewController = UIViewController()//your controller or navController

        // Seems like I don't have to make it key - I can hust make it visible and it is displayed.
        maybeOverlayWindow?.isHidden = false

        // Not sure why this needs to be key. Does this make the other window not key? Setting 'isHidden = false' seems to be sufficient for this.
//        overlayWindow.makeKeyAndVisible()

    }

    @IBAction func didTapHideWindow(_ sender: UIButton) {
        debugPrint(#function)

        maybeOverlayWindow?.isHidden = true
    }
}
