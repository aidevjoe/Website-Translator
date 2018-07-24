import UIKit

class NavigationViewController: UINavigationController {
    
    
    override func viewDidLoad() {
        setAppearance()
    }
}


extension NavigationViewController {
    
    fileprivate func setAppearance() {
//        navigationBar.barTintColor = #colorLiteral(red: 0.2941176471, green: 0.5450980392, blue: 0.9607843137, alpha: 0.2005297518)
//        navigationBar.isTranslucent = false
        navigationBar.tintColor = .white
        navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationBar.shadowImage = UIImage()
        navigationBar.setBackgroundImage(#imageLiteral(resourceName: "navBg"), for: .default)
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden : Bool {
        return UIInterfaceOrientationIsLandscape(UIApplication.shared.statusBarOrientation) && UI_USER_INTERFACE_IDIOM() == .phone
    }
    
    override var preferredStatusBarUpdateAnimation : UIStatusBarAnimation {
        return .none
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return topViewController?.preferredStatusBarStyle ?? .lightContent
    }
    
}
