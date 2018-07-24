import Foundation

public let shareDefaults = UserDefaults(suiteName: "group.com.Joe78.WebTranslation")

public func currentEngine() -> Engine {
    if let engineRaw = shareDefaults?.integer(forKey: "engine"),
        let engine = Engine(rawValue: engineRaw) {
        return engine
    } else {
        return Locale.current.description == "zh_CN" ? .baidu : .google
    }
}
