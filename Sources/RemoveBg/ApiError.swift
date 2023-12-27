//
//  ApiError.swift
//
//
//  Created by Piotr Żmudziński on 26/12/2023.
//

import Foundation

/// `ApiError` represents an error that occurs during an API call to the remove.bg service.
public struct ApiError: CustomNSError {
    /// Enumeration of possible reasons for the API error.
    public enum Reason: Int {
        /// Indicates invalid parameters were provided or the input file is unprocessable. No credits are charged for this error.
        case invalidParameters = 1000

        /// Indicates insufficient credits for the API call. No credits are charged for this error.
        case insufficientCredits = 1001

        /// Indicates authentication with the API failed. No credits are charged for this error.
        case authenticationFailed = 1002

        /// Indicates the rate limit for the API has been exceeded. No credits are charged for this error.
        case rateLimitExceeded = 1003

        /// Indicates an unexpected response was received from the API.
        case badServerResponse = 1004
    }

    /// The domain for the error.
    public static var errorDomain = "api.remove.bg"

    /// The specific reason for the error.
    public let reason: Reason

    /// Optional additional information about the error, typically received from the API.
    let errorsBody: [String: Any]?

    /// The error code, which corresponds to the raw value of the `reason`.
    public var errorCode: Int { reason.rawValue }

    /// The user info dictionary for the error, which may contain additional error details.
    public var errorUserInfo: [String : Any] { errorsBody ?? [:] }

    /// Initializes a new `ApiError` with the specified reason and optional error body.
    /// - Parameters:
    ///   - errorReason: The reason for the error.
    ///   - errorsBody: Optional additional information about the error.
    public init(errorReason: Reason, errorsBody: [String: Any]?) {
        self.reason = errorReason
        self.errorsBody = errorsBody
    }
}
