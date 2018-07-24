import Foundation

public enum Engine: Int {
    case google
    case bing
    case baidu
    case youdao
    case yandex
    
    static public var allCases: [Engine] {
        return [.google, .bing, .baidu, .youdao, .yandex]
    }
    
    public var description: String {
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
    
    public var script: String {
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
    
    public var supportLanguages: [String] {
        switch self {
        case .google:
            /// https://cloud.google.com/translate/docs/languages
            return ["af", "sq", "am", "ar", "hy", "az", "eu", "be", "bn", "bs", "bg", "ca", "ceb", "zh-CN", "zh-TW", "co", "hr", "cs", "da", "nl", "en", "eo", "et", "fi", "fr", "fy", "gl", "ka", "de", "el", "gu", "ht", "ha", "haw", "iw", "hi", "hmn", "hu", "is", "ig", "id", "ga", "ja", "jw", "kn", "kk", "km", "ko", "ku", "ky", "lo", "la", "lv", "lt", "lb", "mk", "mg", "ms", "ml", "mt", "mi", "mr", "mn", "my", "ne", "no", "ny", "ps", "fa", "pl", "pt", "pa", "ro", "ru", "sm", "gd", "sr", "st", "sn", "sd", "si", "sk", "sl", "so", "es", "su", "sw", "sv", "tl", "tg", "ta", "te", "th", "tr", "uk", "ur", "uz", "vi", "cy", "xh", "yi", "yo", "zu"]
        case .baidu:
            /// http://api.fanyi.baidu.com/api/trans/product/apidoc#languageList
            return ["en", "ja", "kor", "fra", "spa", "th", "ara", "ru", "pt", "de", "it", "el", "nl", "pl", "bul", "est", "dan", "fin", "cs", "rom", "sl", "swe", "hu", "zh", "yue", "zh-TW", "vie"]
        case .bing:
            return ["ar", "et", "bg", "is", "pl", "bs-Latn", "fa", "ko", "da", "de", "ru", "fr", "zh-CHT", "fil", "fj", "fi", "ht", "nl", "ca", "zh-CHS", "cs", "tlh", "tlh-Aaak", "hr", "lv", "lt", "ro", "mg", "mt", "ms", "bn", "af", "no", "pt", "ja", "sv", "sm", "sr-Latn", "sr-Cyrl", "sk", "sl", "sw", "ty", "ta", "th", "to", "tr", "cy", "ur", "uk", "es", "he", "el", "hu", "it", "hi", "id", "en", "vi", "yue"]
        case .yandex:
            return ["af", "sq", "am", "ar", "hy", "az", "ba", "eu", "be", "bn", "bs", "bg", "my", "ca", "ceb", "zh", "hr", "cs", "da", "nl", "en", "eo", "et", "fi", "fr", "gl", "ka", "de", "el", "gu", "ht", "he", "mrj", "hi", "hu", "is", "id", "ga", "it", "jv", "ja", "kn", "kk", "km", "ko", "ky", "lo", "la", "lv", "lt", "lb", "mk", "mg", "ms", "ml", "mt", "mi", "mr", "mn", "ne", "no", "pap", "fa", "pl", "pt", "pa", "ro", "ru", "gd", "sr", "si", "sk", "sl", "es", "su", "sw", "sv", "tl", "tg", "ta", "tt", "te", "th", "tr", "udm", "uk" ,"ur", "uz", "vi", "cy", "xh", "yi"]
        default:
            return []
        }
    }
}


public extension Engine {
    
    public func build(url: String) -> String {
        let languageCode = shareDefaults?.string(forKey: "languageCode") ?? "en"
        switch self {
        case .google:
            return "https://translate.google.com/translate?sl=auto&tl=\(languageCode)&u=\(url)"
        case .bing:
            return "https://www.microsofttranslator.com/bv.aspx?from=&to=\(languageCode)&a=\(url)"
        case .baidu:
            return "http://fanyi.baidu.com/transpage?query=\(url)&from=auto&to=\(languageCode)&source=url&render=1"
        case .youdao:
            return "http://fanyi.youdao.com/WebpageTranslate?keyfrom=fanyi.web.index&url=\(url)"
        case .yandex:
            return "https://z5h64q92x9.net/tr-start?ui=en&url=\(url)&lang=en-zh"
        }
    }
}
