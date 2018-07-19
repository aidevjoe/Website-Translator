import UIKit
import MobileCoreServices
import WebKit

enum Producer {
    case google
    case bing
    case baidu
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
    
    private lazy var webView: WKWebView = {
        let view = WKWebView(frame: .zero)
//        view.navigationDelegate = self
        self.view.addSubview(view)
        view.edges(to: self.view)
        return view
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        for item in self.extensionContext!.inputItems as! [NSExtensionItem] {
            for provider in item.attachments! as! [NSItemProvider] {
                provider.loadItem(forTypeIdentifier: kUTTypePropertyList as String) { [unowned self] (dict, error) in
                    guard
                        let itemDictionary = dict as? [String: Any],
                        let javaScriptValues = itemDictionary[NSExtensionJavaScriptPreprocessingResultsKey] as? [String: Any]
                        else { return }
                    
                    let pageTitle = javaScriptValues["title"] as? String
//                    let sourceCode = javaScriptValues["outerHTML"] as? String
                    guard let url = javaScriptValues["URL"] as? String else { return }
                    DispatchQueue.main.async {
                        self.title = pageTitle
                        self.isLoaded = true
                        self.translate(for: url)
                    }
                }
                
                guard self.isLoaded == false, provider.hasItemConformingToTypeIdentifier(kUTTypeURL as String) else { return }
                provider.loadItem(forTypeIdentifier: kUTTypeURL as String) { [unowned self] (url, error) in
                    guard let URL = url as? URL else { return }
                    DispatchQueue.main.async {
                        self.translate(for: URL.absoluteString)
                    }
                }
            }
        }
    }

    private func translate(for url: String) {
        let googleFanyi = "https://translate.google.com/translate?sl=auto&tl=cn&u=\(url)"
//        let biyingFanyi = "https://www.microsofttranslator.com/bv.aspx?from=&to=zh-CHS&a=\(url)"
//        let baiduFanyi = "http://fanyi.baidu.com/transpage?query=\(url)&from=auto&to=zh&source=url&render=1"
//        let youdaoFanyi = "http://fanyi.youdao.com/WebpageTranslate?keyfrom=fanyi.web.index&url=\(url)&type=undefined"

        guard let URL = URL(string: googleFanyi) else { return }
        
        let request = URLRequest(url: URL)
        webView.load(request)
    }
    
    @IBAction func done() {
        self.extensionContext?.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
    }

    @IBAction func switchProducer(_ sender: UIBarButtonItem) {
        print("switchProducer")
    }
}


extension UIView {
    public static func activateConstraints(_ constraints: [NSLayoutConstraint]) {
        constraints.forEach {
            ($0.firstItem as? UIView)?.translatesAutoresizingMaskIntoConstraints = false
        }
        NSLayoutConstraint.activate(constraints)
    }
    
    public func edges(to view: UIView, insets: UIEdgeInsets = .zero) {
        
        UIView.activateConstraints([
            topAnchor.constraint(equalTo: view.topAnchor, constant: insets.top),
            leftAnchor.constraint(equalTo: view.leftAnchor, constant: insets.left),
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -insets.bottom),
            rightAnchor.constraint(equalTo: view.rightAnchor, constant: -insets.right)
            ])
    }
}
