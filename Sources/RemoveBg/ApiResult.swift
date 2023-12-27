//
//  ApiResult.swift
//  
//
//  Created by Piotr Żmudziński on 26/12/2023.
//

import Foundation

/// `ApiResult` represents the result of an API call to the remove.bg service.
/// It contains the image data with the background removed and associated metadata.
public struct ApiResult {
    /// The raw image data with the background removed.
    public let imageData: Data

    /// Optional metadata associated with the API call and result.
    public let meta: Meta?

    /// `Meta` is a nested struct within `ApiResult` that contains additional metadata about the API call.
    public struct Meta: Codable {
        /// The amount of credits charged for this API call.
        public let creditsCharged: Float?

        /// The detected foreground type, which varies based on the `type_level` parameter in the request.
        /// This could provide specific classifications of the foreground subject.
        public let detectedType: String?

        /// The width of the resulting image in pixels.
        public let width: Int?

        /// The height of the resulting image in pixels.
        public let height: Int?

        /// The top position of the foreground image along the vertical axis.
        /// For input images with resolution higher than the limit (> 25 megapixels), this value relates to the input image resolution.
        public let foregroundTop: Int?

        /// The left position of the foreground image along the horizontal axis.
        /// For input images with resolution higher than the limit (> 25 megapixels), this value relates to the input image resolution.
        public let foregroundLeft: Int?

        /// The width of the foreground image.
        /// For input images with resolution higher than the limit (> 25 megapixels), this value relates to the input image resolution.
        public let foregroundWidth: Int?

        /// The height of the foreground image.
        /// For input images with resolution higher than the limit (> 25 megapixels), this value relates to the input image resolution.
        public let foregroundHeight: Int?
    }
}
