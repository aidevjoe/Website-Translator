import UIKit
import WebKit

class WebViewController: BaseViewController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private let webView = WKWebView(frame: .zero)
    
    override func loadView() {
        view = webView
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        title = "How to enable extension?"
        guard
            let url = Bundle.main.url(forResource: "index", withExtension: "html")
            else { return }
        
        let request = URLRequest.init(url: url)
        webView.load(request)
        
        view.clipsToBounds = true
    }
}
