//
//  Copyright © 2018 Microsoft Corporation. All rights reserved.
//

public extension UIImage {
    /// Full replacement for `UIImage(named:)` which attempts to recolor image assets with a color from the high contrast
    /// color palette when `Darken Colors` is enabled. The method is called `static` because the images are outputted with
    /// the rendering mode `AlwaysOriginal` with the intention of preventing further recoloring by `tintColor`.
    @objc class func staticImageNamed(_ name: String, in bundle: Bundle? = nil, withPrimaryColorForDarkerSystemColors primaryColor: UIColor? = nil) -> UIImage? {
        guard var image = UIImage(named: name, in: bundle, compatibleWith: nil) else {
            NSLog("Missing image asset with name: \(name)")
            return nil
        }

        if UIAccessibilityDarkerSystemColorsEnabled(), let primaryColor = primaryColor {
            // Recolor image with high contrast version of `primaryColor`
            image = recolorImage(image, withPrimaryColor: primaryColor)
        }

        // Force image to be `AlwaysOriginal` regardless of the setting in `.xcassets` to prevent recoloring caused by `tintColor`
        return image.withRenderingMode(.alwaysOriginal)
    }

    internal class func staticImageNamed(_ name: String) -> UIImage? {
        // TODO: Provide primary color for known images
        return staticImageNamed(name, in: OfficeUIFabricFramework.bundle)
    }

    private class func recolorImage(_ originalImage: UIImage, withPrimaryColor primaryColor: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(originalImage.size, false, originalImage.scale)

        // Fill canvas with `primaryColor`
        primaryColor.setFill()
        UIRectFill(CGRect(x: 0.0, y: 0.0, width: originalImage.size.width, height: originalImage.size.height))

        // Apply the `alpha` component of the image to the canvas
        originalImage.draw(at: CGPoint.zero, blendMode: .destinationIn, alpha: 1.0)

        // Create `image`
        let image = UIGraphicsGetImageFromCurrentImageContext()!

        UIGraphicsEndImageContext()

        return image
    }

    @objc public func image(withPrimaryColor primaryColor: UIColor) -> UIImage {
        // Force image to be `AlwaysOriginal` regardless of the setting in `.xcassets` to prevent recoloring caused by `tintColor`
        return UIImage.recolorImage(self, withPrimaryColor: primaryColor).withRenderingMode(.alwaysOriginal)
    }
}
