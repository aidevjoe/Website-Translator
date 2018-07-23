import UIKit
import MessageUI

class HomeViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func sendEmailAction(_ sender: UIBarButtonItem) {
        sendEmail()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = UIApplication.appDisplayName()
    }
}



// MARK: - MFMailComposeViewControllerDelegate
extension HomeViewController: MFMailComposeViewControllerDelegate {
    
    private func sendEmail() {
        
        guard MFMailComposeViewController.canSendMail() else {
            let alert = UIAlertController(title: nil, message: "Operation failed.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancle", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        let mailVC = MFMailComposeViewController()
        mailVC.setSubject("\(UIApplication.appDisplayName()) iOS Feedback")
        mailVC.setToRecipients([Constants.Config.receiverEmail])
        mailVC.setMessageBody("\n\n\n\n[Operating environment] \(UIDevice.phoneModel)(\(UIDevice.current.systemVersion))-\(UIApplication.appVersion())(\(UIApplication.appBuild()))", isHTML: false)
        mailVC.mailComposeDelegate = self
        present(mailVC, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
        
        switch result {
        case .sent:
            let alert = UIAlertController(title: nil, message: "Thanks for your feedback.", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "Cancle", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        case .failed:
            let alert = UIAlertController(title: nil, message: "Failed to send mail\nError info: \(error?.localizedDescription ?? "Unkown")", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "Cancle", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        default:
            break
        }
        
    }
}



import UIKit

@IBDesignable extension UIView {
    @IBInspectable var borderColor:UIColor? {
        set {
            layer.borderColor = newValue?.cgColor
        }
        get {
            if let color = layer.borderColor {
                return UIColor.init(cgColor: color)
            }
            else {
                return nil
            }
        }
    }
    @IBInspectable var borderWidth:CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    @IBInspectable var cornerRadius:CGFloat {
        set {
            layer.cornerRadius = newValue
            clipsToBounds = newValue > 0
        }
        get {
            return layer.cornerRadius
        }
    }
}
