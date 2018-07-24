import UIKit
import MobileCoreServices
import WebKit
import WebTranslationCore


class ActionViewController: UIViewController {

    private var isLoaded: Bool = false
    
    private var engine: Engine = currentEngine() {
        didSet {
            shareDefaults?.set(engine.rawValue, forKey: "engine")
            shareDefaults?.synchronize()
        }
    }
    
    private lazy var webView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        
        Engine.allCases.forEach {
            contentController.addUserScript(WKUserScript(source: $0.script, injectionTime: .atDocumentEnd, forMainFrameOnly: false))
        }

        webConfiguration.userContentController = contentController
        
        let view = WKWebView(frame: .zero, configuration: webConfiguration)
        view.isHidden = true
        view.navigationDelegate = self
        view.uiDelegate = self
        self.view.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [view.heightAnchor.constraint(equalTo: self.view.heightAnchor),
             view.widthAnchor.constraint(equalTo: self.view.widthAnchor),
             view.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
             view.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)]
        )
        return view
    }()
    
//    override func loadView() {
//        view = webView
//    }
    
    private lazy var progressView: UIProgressView = {
        let view = UIProgressView()
        view.trackTintColor = .clear
        view.tintColor = #colorLiteral(red: 0.2941176471, green: 0.5450980392, blue: 0.9607843137, alpha: 1)
        if let navigationBar = self.navigationController?.navigationBar {
            self.navigationController?.navigationBar.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate(
                [view.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor),
                view.leftAnchor.constraint(equalTo: navigationBar.leftAnchor),
                view.rightAnchor.constraint(equalTo: navigationBar.rightAnchor),
                view.heightAnchor.constraint(equalToConstant: 2)]
            )
        }
        return view
    }()
    
    private var url: String? {
        didSet {
            self.translate(for: engine)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        
        for item in self.extensionContext?.inputItems as! [NSExtensionItem] {
            for provider in item.attachments! as! [NSItemProvider] {
                provider.loadItem(forTypeIdentifier: kUTTypePropertyList as String) { [unowned self] (dict, error) in
                    guard
                        let itemDictionary = dict as? [String: Any],
                        let javaScriptValues = itemDictionary[NSExtensionJavaScriptPreprocessingResultsKey] as? [String: Any]
                        else { return }
                    
                    let pageTitle = javaScriptValues["title"] as? String
                    guard let url = javaScriptValues["URL"] as? String else { return }
                    DispatchQueue.main.async {
                        self.title = pageTitle
                        self.isLoaded = true
                        self.url = url
                    }
                }
                
                guard self.isLoaded == false, provider.hasItemConformingToTypeIdentifier(kUTTypeURL as String) else { return }
                provider.loadItem(forTypeIdentifier: kUTTypeURL as String) { [unowned self] (url, error) in
                    guard let URL = url as? URL else { return }
                    DispatchQueue.main.async {
                        self.url = URL.absoluteString
                    }
                }
            }
        }
    }

    deinit {
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
        webView.navigationDelegate = nil
    }
    
    private func translate(for engine: Engine) {
        guard let `url` = url,
            let URL = URL(string: engine.build(url: url)) else { return }
        self.engine = engine
        
        webView.stopLoading()
        webView.load(URLRequest(url: URL))
    }
    
    @IBAction func done() {
        self.extensionContext?.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
    }

    @IBAction func switchEngine(_ sender: UIBarButtonItem) {
        
        let alertController = UIAlertController(title: "Select engine", message: nil, preferredStyle: .actionSheet)

        let allCases = Engine.allCases
        let action: ((UIAlertAction) -> Void) = { [weak self] alert in
            let selectedEngine = allCases.first { $0.description == alert.title }
            guard let engine = selectedEngine else { return }
            self?.translate(for: engine)
        }
        
        allCases.forEach { alertController.addAction(UIAlertAction(title: $0.description, style: .default, handler: action))}
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}

extension ActionViewController {
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard let `keyPath` = keyPath else { return }
        
        switch keyPath {
        case "estimatedProgress":
//            guard (webView.url?.path ?? "") == "/translate_c" else { return }
            
            print("webView.url", webView.url ?? "")
            if let newValue = change?[NSKeyValueChangeKey.newKey] as? NSNumber {
                progressChanged(newValue)
            }
        default:
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    private func progressChanged(_ newValue: NSNumber) {
        if newValue.floatValue < progressView.progress {
            progressView.setProgress(1, animated: true)
            return
        }
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
}

extension ActionViewController: WKNavigationDelegate {
    
    
    /// 网页开始加载
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if webView.url?.absoluteString == "webtranslator://refresh" {
            self.translate(for: self.engine)
        }
    }
    
    /// 网页加载完成
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        switch engine {
        case .google:
            webView.isHidden = (webView.url?.path ?? "") != "/translate_c"
        default:
            webView.isHidden = false
        }
    }
    
    /// 网页加载失败
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print(error, webView.url)
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        print(webView.url)
    }
    
    ///  网页返回内容时发生的失败
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        // NSURLErrorDomain
        if [-1002, -999].contains((error as NSError).code) {
            return
        }
        let alertController = UIAlertController(title: url, message: error.localizedDescription, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK.", style: .cancel, handler: { _ in
            guard let url = Bundle.main.url(forResource: "error", withExtension: "html") else { return }
            webView.isHidden = false
            webView.load(URLRequest(url: url))
        }))
        present(alertController, animated: true, completion: nil)
        
    }
    
    /// 网页进程终止
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print(webView.url)
        if engine == .google,
            let url = navigationAction.request.url,
            ["/translate_nv"].contains(url.path) { // Google 的翻译工具条 请求
            decisionHandler(.cancel)
            return
        } else {
            decisionHandler(.allow)
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        if let response = navigationResponse.response as? HTTPURLResponse {
            if response.statusCode == 500 {
                guard let path = Bundle.main.path(forResource: "error", ofType: "html"),
                    let html = try? String(contentsOfFile: path, encoding: .utf8) else {
                        return decisionHandler(.allow)
                }
                webView.loadHTMLString(html, baseURL: nil)
            }
        }
        decisionHandler(.allow)
    }
}

extension ActionViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        print(message)
        let alertController = UIAlertController(title: url, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK.", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
        
        completionHandler()
    }
}
