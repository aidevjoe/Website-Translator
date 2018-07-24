import UIKit

//@IBDesignable
class LeftAlignedIconButton: UIButton {
    override func layoutSubviews() {
        contentHorizontalAlignment = .left
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
        imageEdgeInsets = UIEdgeInsetsMake(0, 12.0, 0, 12.0)
    }
    
    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        let titleRect = super.titleRect(forContentRect: contentRect)
        let imageSize = currentImage?.size ?? .zero
        let availableWidth = contentRect.width - imageEdgeInsets.right - imageSize.width - titleRect.width
//        let extra = imageSize.width > 0 ? imageSize.width / 2 : 0
        return titleRect.offsetBy(dx: round(availableWidth / 2), dy: 0)
    }
}
