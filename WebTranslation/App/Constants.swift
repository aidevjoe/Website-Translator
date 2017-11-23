import Foundation
import UIKit

struct Closure {
    typealias Completion = () -> Void
    typealias Failure = (NSError?) -> Void
}

struct Constants {

    struct Config {
        // App
        static var baseURL = "https://www.v2ex.com"
        
        static var receiverEmail = "joesir7@foxmail.com"

        static var AppID = "1308118507"
    }

    struct Keys {
    }

    struct Metric {
        /// TODO: iPhone X 适配
        static let navigationHeight: CGFloat = 64
        static let tabbarHeight: CGFloat = 49
        
        static let screenWidth: CGFloat = UIScreen.main.bounds.width
        static let screenHeight: CGFloat = UIScreen.main.bounds.height
    }
}

// MARK: - 通知
extension Notification.Name {
    
    /// 自定义的通知
    struct T {
    }
}


