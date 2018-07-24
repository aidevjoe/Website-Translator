import UIKit
import MessageUI
import WebTranslationCore

class HomeViewController: BaseViewController {
    
    private var engine: Engine = currentEngine()
    
    
    @IBAction func sendEmailAction(_ sender: UIBarButtonItem) {
        sendEmail()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = ""
    }
    
    @IBAction func selectEngineAction() {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let allCases = Engine.allCases
        let action: ((UIAlertAction) -> Void) = { [weak self] alert in
            let selectedEngine = allCases.first { $0.description == alert.title }
            guard let engine = selectedEngine else { return }
            shareDefaults?.set(engine.rawValue, forKey: "engine")
            shareDefaults?.synchronize()
            self?.engine = engine
            print(engine)
        }

        allCases.forEach {
            let alertAction = UIAlertAction(title: $0.description, style: .default, handler: action)
            alertAction.setValue(Theme.Color.globalColor, forKey: "titleTextColor")
            alertController.addAction(alertAction)
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func selectTargetLanguageAction() {
        let langs = engine.supportLanguages.compactMap { Locale.current.localizedString(forLanguageCode: $0) }
        
        let lv = SelectLanguageViewController(languages: langs)
        navigationController?.pushViewController(lv, animated: true)
        
        lv.didSelectedCompleted = { [weak self] language in
            guard
                let `self` = self,
                let index = langs.index(of: language) else {
                return
            }
            
            var languageCode = self.engine.supportLanguages[index]
            if self.engine == .baidu {
                switch languageCode {
                case "ja":
                    languageCode = "ja"
                case "cn-TW":
                    languageCode = "cht"
                case "sl":
                    languageCode = "slo"
                default:
                    break
                }
            }
            shareDefaults?.set(languageCode, forKey: "languageCode")
            shareDefaults?.synchronize()
        }
    }
    
}

extension UIColor {
    convenience init(rgb: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        self.init(red: rgb/255.0, green: green/255.0, blue: blue/255.0, alpha: alpha)
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

