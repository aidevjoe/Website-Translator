//
//  ActionViewController.swift
//  Translation
//
//  Created by Joe-c on 2017/11/17.
//  Copyright © 2017年 Joe-c. All rights reserved.
//

import UIKit
import MobileCoreServices
import WebKit

class ActionViewController: UIViewController {

    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var imageFound = false

        for item in self.extensionContext!.inputItems as! [NSExtensionItem] {
            for provider in item.attachments! as! [NSItemProvider] {
                
                if provider.hasItemConformingToTypeIdentifier(kUTTypeURL as String) {
                    // This is an image. We'll load it, then place it in our image view.
                    weak var weakWebView = self.webView
                    
                    provider.loadItem(forTypeIdentifier: kUTTypeURL as String, options: nil, completionHandler: { (url, error) in
                        OperationQueue.main.addOperation {
                            
                            guard let strongWebView = weakWebView,
                                let urlWrapper = url as? URL else { return }
                            
//                            let googleFanyi = "https://translate.google.com/translate?sl=auto&tl=cn&u=\(urlWrapper.absoluteString)"
//                            let biyingFanyi = "https://www.microsofttranslator.com/bv.aspx?from=&to=zh-CHS&a=\(urlWrapper.absoluteString)"
//                            let baiduFanyi = "http://fanyi.baidu.com/transpage?query=\(urlWrapper.absoluteString)&from=auto&to=zh&source=url&render=1"
                            let youdaoFanyi = "http://fanyi.youdao.com/WebpageTranslate?keyfrom=fanyi.web.index&url=\(urlWrapper.absoluteString)&type=undefined"
//                            let finalURL = URL(string: baiduFanyi)!
//                            let finalURL = URL(string: googleFanyi)!
//                            let finalURL = URL(string: biyingFanyi)!
                            let finalURL = URL(string: youdaoFanyi)!
                        
                            strongWebView.loadRequest(URLRequest(url: finalURL))
                        }
                    })
                    
                    imageFound = true
                    break
                }
            }
            
            if (imageFound) {
                // We only handle one image, so stop looking for more.
                break
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func done() {
        // Return any edited content to the host app.
        // This template doesn't do anything, so we just echo the passed in items.
        self.extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
    }

}
