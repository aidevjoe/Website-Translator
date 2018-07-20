import UIKit
import MobileCoreServices
import WebKit

enum Engine {
    case google
    case bing
    case baidu
    case youdao
    case yandex
    
    static var allCases: [Engine] {
        return [.google, .bing, .baidu, .youdao, .yandex]
    }
    
    var description: String {
        switch self {
        case .google:
            return "Google"
        case .bing:
            return "Bing"
        case .baidu:
            return "Baidu"
        case .youdao:
            return "Youdao"
        case .yandex:
            return "Yandex"
        }
    }
    
    var script: String {
        switch self {
        case .google:
            return "document.querySelector('#gt-nvframe').remove();document.querySelector('body').style.top = '0px';"
        case .bing:
            return "document.querySelector('#divBVHeader').remove();"
        case .baidu:
            return "document.querySelector('.header').remove();"
        case .youdao:
            return "document.querySelector('.yd-snap').remove();document.querySelector('.yd-snap-line').remove();"
        case .yandex:
            return "document.querySelector('#tr-stripe').remove();"
        }
    }
}

extension Engine {
    
    func build(url: String) -> String {
        switch self {
        case .google:
            return "https://translate.google.com/translate?sl=auto&tl=cn&u=\(url)"
        case .bing:
            return "https://www.microsofttranslator.com/bv.aspx?from=&to=zh-CHS&a=\(url)"
        case .baidu:
            return "http://fanyi.baidu.com/transpage?query=\(url)&from=auto&to=zh&source=url&render=1"
        case .youdao:
            return "http://fanyi.youdao.com/WebpageTranslate?keyfrom=fanyi.web.index&url=\(url)"
        case .yandex:
            return "https://z5h64q92x9.net/tr-start?ui=en&url=\(url)&lang=en-zh"
        }
    }
}

/// http://api.fanyi.baidu.com/api/trans/product/apidoc#languageList
enum BaiduStandard: String {
    case auto  // 自动检测
    case zh  // 中文
    case en  // 英语
    case yue  // 粤语
    case wyw  // 文言文
    case jp  // 日语
    case kor  // 韩语
    case fra  // 法语
    case spa  // 西班牙语
    case th  // 泰语
    case ara  // 阿拉伯语
    case ru  // 俄语
    case pt  // 葡萄牙语
    case de  // 德语
    case it  // 意大利语
    case el  // 希腊语
    case nl  // 荷兰语
    case pl  // 波兰语
    case bul  // 保加利亚语
    case est  // 爱沙尼亚语
    case dan  // 丹麦语
    case fin  // 芬兰语
    case cs  // 捷克语
    case rom  // 罗马尼亚语
    case slo  // 斯洛文尼亚语
    case swe  // 瑞典语
    case hu  // 匈牙利语
    case cht  // 繁体中文
    case vie  // 越南语
}

/// https://cloud.google.com/translate/docs/languages
enum GoogleStandard: String {
    case af
}

class ActionViewController: UIViewController {

    private var isLoaded: Bool = false
    
    var webView: WKWebView!
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        
        Engine.allCases.forEach {
            contentController.addUserScript(WKUserScript(source: $0.script, injectionTime: .atDocumentEnd, forMainFrameOnly: false))
        }
        
        webConfiguration.userContentController = contentController
        
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        
        webView.navigationDelegate = self
        view = webView
    }
    
    private lazy var progressView: UIProgressView = {
        let view = UIProgressView()
        view.trackTintColor = .clear
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
            self.translate()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        
        for item in self.extensionContext!.inputItems as! [NSExtensionItem] {
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
    
    private func translate(for engine: Engine = .bing) {
        guard let `url` = url,
            let URL = URL(string: engine.build(url: url)) else { return }
        
        webView.stopLoading()
        webView.load(URLRequest(url: URL))
    }
    
    @IBAction func done() {
        self.extensionContext?.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
    }

    @IBAction func switchEngine(_ sender: UIBarButtonItem) {
        
        let alertController = UIAlertController(title: "选择引擎", message: nil, preferredStyle: .actionSheet)

        let allCases = Engine.allCases
        let action: ((UIAlertAction) -> Void) = { [weak self] alert in
            let selectedEngine = allCases.first { $0.description == alert.title }
            guard let engine = selectedEngine else { return }
            self?.translate(for: engine)
        }
        
        allCases.forEach { alertController.addAction(UIAlertAction(title: $0.description, style: .default, handler: action))}
        
        alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
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
    
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("didStartProvisionalNavigation")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print(error)
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        print(webView.url)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

        print(#function, navigationAction.request.url)
        
//        if let url = navigationAction.request.url,
//            ["/translate_nv"].contains(url.path) {
//            decisionHandler(.cancel)
//            return
//        } else {
            decisionHandler(.allow)
//        }
    }
}
