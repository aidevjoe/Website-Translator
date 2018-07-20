import UIKit
import SnapKit

// UI 参考
// https://play.google.com/store/apps/details?id=mark.via.gp

// 截图
// https://www.imore.com/how-quickly-translate-webpages-safari-iphone-and-ipad
class HomeViewController: BaseViewController {
    
    private struct Metric {
        static let topMargin = UIScreen.main.bounds.height * 0.25
        static let textFieldWidth = UIScreen.main.bounds.width * 0.87
    }
    
    private struct Tinct {
        static let textFieldBorderColor = UIColor.groupTableViewBackground
    }
    
    private lazy var linkTextField: UITextField = {
        let view = UITextField()
        view.placeholder = "输入网址"
        let marginV = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        view.leftView = marginV
        view.leftViewMode = .always
        view.delegate = self
        view.backgroundColor = .white
        
        view.layer.borderColor = Tinct.textFieldBorderColor.cgColor
        view.layer.borderWidth = 0.6
        
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 4
        
        // 阴影向下偏移 6
        view.layer.shadowOffset = CGSize(width: 0, height: 6)
        view.clipsToBounds = true
        view.returnKeyType = .search
        self.view.addSubview(view)
        return view
    }()
    
    private var linkTextFieldTopConstraint: Constraint?
    private var linkTextFieldWidthConstraint: Constraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setupConstraints()
        
        linkTextField.text = "www.github.com"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        //        navigationController?.navigationBar.isTranslucent = true
        //        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        //        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    private func setupConstraints() {
        linkTextField.snp.makeConstraints{
            linkTextFieldTopConstraint = $0.top.equalToSuperview().offset(Metric.topMargin).constraint
            linkTextFieldWidthConstraint = $0.width.equalTo(Metric.textFieldWidth).constraint
            $0.height.equalTo(50)
            $0.centerX.equalToSuperview()
        }
    }
}

extension HomeViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let margin = UIApplication.shared.statusBarFrame.maxY
        
        linkTextFieldTopConstraint?.update(offset: margin)
        linkTextFieldWidthConstraint?.update(offset: view.frame.width)
        linkTextField.clipsToBounds = false
        
        UIView.animate(withDuration: 0.25) {
            self.linkTextField.layer.borderColor = UIColor.clear.cgColor
            self.view.layoutIfNeeded()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        linkTextFieldTopConstraint?.update(offset: Metric.topMargin)
        linkTextFieldWidthConstraint?.update(offset: Metric.textFieldWidth)
        linkTextField.clipsToBounds = true
        
        UIView.animate(withDuration: 0.25) {
            self.linkTextField.layer.borderColor = Tinct.textFieldBorderColor.cgColor
            self.view.layoutIfNeeded()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        linkTextField.resignFirstResponder()
        let webView = WebTranslationViewController()
        webView.urlString = textField.text
        navigationController?.pushViewController(webView, animated: true)
        return true
    }
}

