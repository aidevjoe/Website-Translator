import UIKit
import WebKit

class WebViewController: UIViewController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private lazy var webView: WKWebView = {
        let view = WKWebView(frame: .zero)
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "如何启用扩展"
        guard
            let url = Bundle.main.url(forResource: "index", withExtension: "html")
            else { return }
        
        let request = URLRequest.init(url: url)
        webView.load(request)
    }
}
