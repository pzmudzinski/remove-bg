//
//  ApiOptions.swift
//  
//
//  Created by Piotr Żmudziński on 26/12/2023.
//

import Foundation

/// `ApiOptions` represents the configuration to an API call to the remove.bg service.
public struct ApiOptions: Codable {
    /// Possible values for `size` option
    public enum ImageSize: String, Codable {
        case auto, preview, full
    }

    /// Possible values for `type` option
    public enum ImageType: String, Codable {
        case auto, person, product, car
    }

    /// Possible values for `typeLevel` option
    public enum ImageTypeLevel: String, Codable {
        case none = "none", one = "1", two = "2", latest = "latest"
    }

    /// Possibele values for `format` option
    public enum ImageFormat: String, Codable {
        case auto, png, jpg, zip
    }
    
    /// Maximum output image resolution: "preview" (default) = Resize image to 0.25 megapixels (e.g. 625×400 pixels) – 0.25 credits per image, "full" = Use original image resolution, up to 25 megapixels (e.g. 6250x4000) with formats ZIP or JPG, or up to 10 megapixels (e.g. 4000x2500) with PNG – 1 credit per image), "auto" = Use highest available resolution (based on image size and available credits).
    public let size: ImageSize?
    /// Foreground type: "auto" = Automatically detect kind of foreground, "person" = Use person(s) as foreground, "product" = Use product(s) as foreground. "car" = Use car as foreground.
    public let type: ImageType?
    /// Classification level of the detected foreground type: "none" = No classification (X-Type Header won't bet set on the response) "1" = Use coarse classification classes: [person, product, animal, car, other] "2" = Use more specific classification classes: [person, product, animal, car, car_interior, car_part, transportation, graphics, other] "latest" = Always use the latest classification classes available
    public let typeLevel: ImageTypeLevel?
    /// Result image format: "auto" = Use PNG format if transparent regions exist, otherwise use JPG format (default), "png" = PNG format with alpha transparency, "jpg" = JPG format, no transparency, "zip" = ZIP format, contains color image and alpha matte image, supports transparency (recommended).
    public let format: ImageFormat?
    /// Region of interest: Only contents of this rectangular region can be detected as foreground. Everything outside is considered background and will be removed. The rectangle is defined as two x/y coordinates in the format "x1 y1 x2 y2". The coordinates can be in absolute pixels (suffix 'px') or relative to the width/height of the image (suffix '%'). By default, the whole image is the region of interest ("0% 0% 100% 100%").
    public let roi: String?
    /// Whether to crop off all empty regions (default: false). Note that cropping has no effect on the amount of charged credits.
    public let crop: Bool?
    /// Adds a margin around the cropped subject (default: 0). Can be an absolute value (e.g. "30px") or relative to the subject size (e.g. "10%"). Can be a single value (all sides), two values (top/bottom and left/right) or four values (top, right, bottom, left). This parameter only has an effect when "crop=true". The maximum margin that can be added on each side is 50% of the subject dimensions or 500 pixels.
    public let cropMargin: String?
    /// Scales the subject relative to the total image size. Can be any value from "10%" to "100%", or "original" (default). Scaling the subject implies "position=center" (unless specified otherwise).
    public let scale: String?
    /// Positions the subject within the image canvas. Can be "original" (default unless "scale" is given), "center" (default when "scale" is given) or a value from "0%" to "100%" (both horizontal and vertical) or two values (horizontal, vertical).
    public let position: String?
    /// Request either the finalized image ("rgba", default) or an alpha mask ("alpha"). Note: Since remove.bg also applies RGB color corrections on edges, using only the alpha mask often leads to a lower final image quality. Therefore "rgba" is recommended.
    public let channels: String?
    /// Whether to add an artificial shadow to the result (default: false). NOTE: Adding shadows is currently only supported for car photos. Other subjects are returned without shadow, even if set to true (this might change in the future).
    public let addShadow: Bool?
    /// Whether to have semi-transparent regions in the result (default: true). NOTE: Semitransparency is currently only supported for car windows (this might change in the future). Other objects are returned without semitransparency, even if set to true.
    public let semitransparency: Bool?
    /// Adds a solid color background. Can be a hex color code (e.g. 81d4fa, fff) or a color name (e.g. green). For semi-transparency, 4-/8-digit hex codes are also supported (e.g. 81d4fa77). (If this parameter is present, the other bg_ parameters must be empty.)
    public let bgColor: String?
    ///  Adds a background image from a URL. The image is centered and resized to fill the canvas while preserving the aspect ratio, unless it already has the exact same dimensions as the foreground image. (If this parameter is present, the other bg_ parameters must be empty.)
    public let bgImageUrl: String?
    /// Adds a background image from a file (binary). The image is centered and resized to fill the canvas while preserving the aspect ratio, unless it already has the exact same dimensions as the foreground image. (If this parameter is present, the other bg_ parameters must be empty.)
    public let bgImageFile: String?

    enum CodingKeys: String, CodingKey {        
        case size = "size"
        case type = "type"
        case typeLevel = "type_level"
        case format = "format"
        case roi = "roi"
        case crop = "crop"
        case cropMargin = "crop_margin"
        case scale = "scale"
        case position = "position"
        case channels = "channels"
        case addShadow = "add_shadow"
        case semitransparency = "semitransparency"
        case bgColor = "bg_color"
        case bgImageUrl = "bg_image_url"
        case bgImageFile = "bg_image_file"
    }

    public init(size: ImageSize? = nil, type: ImageType? = nil, typeLevel: ImageTypeLevel? = nil, format: ImageFormat? = nil, roi: String? = nil, crop: Bool? = nil, cropMargin: String? = nil, scale: String? = nil, position: String? = nil, channels: String? = nil, addShadow: Bool? = nil, semitransparency: Bool? = nil, bgColor: String? = nil, bgImageUrl: String? = nil, bgImageFile: String? = nil) {        
        self.size = size
        self.type = type
        self.typeLevel = typeLevel
        self.format = format
        self.roi = roi
        self.crop = crop
        self.cropMargin = cropMargin
        self.scale = scale
        self.position = position
        self.channels = channels
        self.addShadow = addShadow
        self.semitransparency = semitransparency
        self.bgColor = bgColor
        self.bgImageUrl = bgImageUrl
        self.bgImageFile = bgImageFile
    }
}
