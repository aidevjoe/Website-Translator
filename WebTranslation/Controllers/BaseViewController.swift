import UIKit

class BaseViewController: UIViewController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let bgImage: UIImageView = UIImageView(frame: view.bounds)
        bgImage.image = #imageLiteral(resourceName: "xrb_bg_thumb").withRenderingMode(.alwaysOriginal)
        bgImage.contentMode = .scaleAspectFill
        
        view.backgroundColor = .clear
        let bgView = UIView(frame: view.bounds)
        bgView.backgroundColor = Theme.Color.globalColor
        view.insertSubview(bgView, at: 0)
        view.insertSubview(bgImage, at: 1)
        
        view.clipsToBounds = true
    }

}
