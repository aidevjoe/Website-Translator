import Foundation
import UIKit




// MARK: - UIApplication
public extension UIApplication {
    
    /// App版本
    public class func appVersion() -> String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }
    
    /// App构建版本
    public class func appBuild() -> String {
        return Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
    }
    
    public class var iconFilePath: String {
        let iconFilename = Bundle.main.object(forInfoDictionaryKey: "CFBundleIconFile")
        let iconBasename = (iconFilename as! NSString).deletingPathExtension
        let iconExtension = (iconFilename as! NSString).pathExtension
        return Bundle.main.path(forResource: iconBasename, ofType: iconExtension)!
    }
    
    public class func iconImage() -> UIImage? {
        guard let image = UIImage(contentsOfFile:self.iconFilePath) else {
            return nil
        }
        return image
    }
    
    public class func versionDescription() -> String {
        let version = appVersion()
        #if DEBUG
            return "Debug - \(version)"
        #else
            return "Release - \(version)"
        #endif
    }
    
    public class func appBundleName() -> String{
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as! String
    }
    
    public class func appDisplayName() -> String{
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as! String
    }
    
    public class func appReviewPage(with appId: String) {
        guard !appId.isEmpty else { return }
        var urlString = "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=\(appId)"
        if #available(iOS 11, *) {
            //            urlString = "itms-apps://itunes.apple.com/cn/app/id\(appId)?mt=8&action=write-review"
            //            urlString = "itms-apps://itunes.apple.com/app/viewContentsUserReviews?id=\(appId)"
            urlString = "itms-apps://itunes.apple.com/cn/app/v2er/id\(appId)?mt=8&action=write-review"
        }
        if let url = URL(string: urlString) {
            UIApplication.shared.openURL(url)
        }
    }
    
}




extension NSObject {
    static var className: String {
        return String(describing: type(of: self)).components(separatedBy: ".").last ?? ""
    }

    var className: String {
        return String(describing: type(of: self)).components(separatedBy: ".").last ?? ""
    }
}


// MARK: - UIDevice

extension UIDevice {
    
    public var isPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    public var isiPhoneX: Bool {
        return UIDevice.phoneModel == "iPhone X"
    }
    
    public var isLandscape: Bool {
        return [UIDeviceOrientation.landscapeLeft, UIDeviceOrientation.landscapeRight].contains(UIDevice.current.orientation)
    }
    
    /// MARK: - 获取设备型号
    public static var phoneModel: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8 , value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
        case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
        case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6":                return "iPhone X"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,3", "iPad6,4":                      return "iPad Pro 9.7 Inch"
        case "iPad6,7", "iPad6,8":                      return "iPad Pro"
        case "iPad7,1", "iPad7,2":                      return "iPad Pro 12.9 Inch 2. Generation"
        case "iPad7,3", "iPad7,4":                      return "iPad Pro 10.5 Inch"
        case "AppleTV5,3":                              return "Apple TV"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
    
    /// 判断是不是模拟器
    public static var isSimulator: Bool {
        return UIDevice.phoneModel == "Simulator"
    }
    
    public static var isiPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    /// 返回当前屏幕的一个像素的点大小
    public class var onePixel: CGFloat {
        return CGFloat(1.0) / UIScreen.main.scale
    }
    
    
    /// 将浮动值返回到当前屏幕的最近像素
    static public func roundFloatToPixel(_ value: CGFloat) -> CGFloat {
        return round(value * UIScreen.main.scale) / UIScreen.main.scale
    }
}
