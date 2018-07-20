import UIKit
import WebKit
import SnapKit

// Google 翻译 工具条
// https://translate.google.com/translate_nv?depth=2&nv=1&rurl=translate.google.com&sl=auto&sp=nmt4&u=https://github.com/

class WebTranslationViewController: BaseViewController {

    private lazy var webView: WKWebView = {
        let view = WKWebView()
        view.navigationDelegate = self
        view.isHidden = true
        self.view.addSubview(view)
        return view
    }()
    
    
    private lazy var linkTextField: UITextField = {
        let view = UITextField(frame: CGRect(origin: .zero, size: CGSize(width: self.view.frame.width, height: 35)))
        view.placeholder = "输入网址"
        let marginV = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        view.leftView = marginV
        view.leftViewMode = .always
        view.backgroundColor = .white
        view.layer.borderColor = Theme.Color.borderColor.cgColor
        view.font = UIFont.systemFont(ofSize: 16)
        view.layer.borderWidth = 0.5
        view.returnKeyType = .search
        view.delegate = self
        return view
    }()
    
    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.activityIndicatorViewStyle = .gray
        self.view.addSubview(view)
        return view
    }()
    
    private lazy var progressView: UIProgressView = {
        let view = UIProgressView()
        view.trackTintColor = #colorLiteral(red: 0, green: 0.431372549, blue: 1, alpha: 0.3030818635)
        self.navigationController?.navigationBar.addSubview(view)
        return view
    }()
    
    public var urlString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupConstraints()
        
        view.backgroundColor = .white
        navigationItem.titleView = linkTextField
    
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        
        loadURL()
    }
    
    deinit {
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
        webView.navigationDelegate = nil
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func setupConstraints() {
        webView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        activityIndicatorView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        progressView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview().offset(2.5)
            $0.height.equalTo(2.5)
        }
    }
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard let `keyPath` = keyPath else { return }
        
        switch keyPath {
        case "estimatedProgress":
            guard (webView.url?.path ?? "") == "/translate_c" else { return }
            
            print("webView.url", webView.url)
            if let newValue = change?[NSKeyValueChangeKey.newKey] as? NSNumber {
                progressChanged(newValue)
            }
        default:
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

    private func progressChanged(_ newValue: NSNumber) {
        progressView.alpha = 1
        progressView.setProgress(newValue.floatValue, animated: true)
        if webView.estimatedProgress >= 1 {
            UIView.animate(withDuration: 0.3, delay: 0.4, options: .curveEaseOut, animations: {
                self.progressView.alpha = 0
            }, completion: { _ in
                self.progressView.setProgress(0, animated: false)
            })
        }
    }
    
    private func loadURL() {
        guard let `urlString` = urlString else { return }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        linkTextField.text = urlString
        
        //        let urlWrapper = "http://fanyi.baidu.com/transpage?query=\(urlString)&from=auto&to=zh&source=url&render=1"
        let urlWrapper = "https://translate.google.com/translate?sl=auto&tl=cn&u=\(urlString)"
        guard let url = URL(string: urlWrapper) else { return }
        webView.load(URLRequest(url: url))
    }
}

extension WebTranslationViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicatorView.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        //            let hiddenNode = "document.getElementById('gt-nvframe').style.display = 'none'"
        //            let deleteNode = "document.body.removeChild(document.getElementById('gt-nvframe'))"
        webView.evaluateJavaScript(
            "document.body.style.top = 0; document.getElementById('gt-nvframe').style.display = 'none'",
            completionHandler: nil)
        
        if (webView.url?.path ?? "") == "/translate_c" {
            activityIndicatorView.stopAnimating()
            webView.isHidden = false
        }
        print(webView.url ?? "")
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url,
            ["/translate_nv"].contains(url.path) {
            decisionHandler(.cancel)
            return
        } else {
            decisionHandler(.allow)
        }
    }
}

extension WebTranslationViewController: UITextFieldDelegate {
  
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        urlString = textField.text
        loadURL()
        return true
    }
}

