//
//  Copyright © 2019 Microsoft Corporation. All rights reserved.
//

open class MSResizingHandleView: UIView {
    private struct Constants {
        static let markSize = CGSize(width: 36, height: 4)
        static let markCornerRadius: CGFloat = 2
    }

    public static let height: CGFloat = 20

    private let markLayer: CALayer = {
        let markLayer = CALayer()
        markLayer.bounds.size = Constants.markSize
        markLayer.cornerRadius = Constants.markCornerRadius
        markLayer.backgroundColor = MSColors.ResizingHandle.mark.cgColor
        return markLayer
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = MSColors.ResizingHandle.background
        height = MSResizingHandleView.height
        autoresizingMask = .flexibleWidth
        isUserInteractionEnabled = false
        layer.addSublayer(markLayer)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: MSResizingHandleView.height)
    }

    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: MSResizingHandleView.height)
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        markLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
    }
}
