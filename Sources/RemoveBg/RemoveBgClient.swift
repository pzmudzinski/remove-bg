import Foundation

/// `RemoveBgClient` is a class for interacting with the remove.bg API.
/// It provides methods to remove the background from images using different input formats such as URL, Base64, or raw image data.
public class RemoveBgClient {
    static let endpoint = URL(string: "https://api.remove.bg/v1.0/removebg")!
    private let urlSession: URLSession
    private let boundary = UUID().uuidString

    /// Initializes a new instance of `RemoveBgClient` with the specified URL session configuration and API key.
    /// - Parameters:
    ///   - urlSessionConfiguration: The `URLSessionConfiguration` to be used for network requests.
    ///   - apiKey: The API key for authenticating with the remove.bg API.
    init(urlSessionConfiguration: URLSessionConfiguration, apiKey: String) {
        urlSessionConfiguration.httpAdditionalHeaders = [
            "X-Api-Key": apiKey,
            "Accept": "image/*",
        ]
        
        self.urlSession = URLSession(configuration: urlSessionConfiguration)
    }

    /// Convenience initializer that creates a `RemoveBgClient` instance with the default URL session configuration.
    /// - Parameter apiKey: The API key for authenticating with the remove.bg API.
    convenience public init(apiKey: String) {
        self.init(urlSessionConfiguration: .default, apiKey: apiKey)
    }
    
    /// Removes the background from the image located at the specified URL.
    /// - Parameters:
    ///   - url: The URL of the image.
    ///   - options: The options to use for the API call.
    /// - Returns: An `ApiResult` containing the processed image or an error.
    public func removeBackground(fromFileAtUrl url: URL, options: ApiOptions = ApiOptions()) async throws -> ApiResult {
        let body = try createRequestBody(options: options, imageInput: .remoteURL(url))
        return try await fetch(body: body)
    }
    
    /// Removes the background from the image provided as a Base64 encoded string.
    /// - Parameters:
    ///   - base64: The Base64 encoded string of the image.
    ///   - options: The options to use for the API call.
    /// - Returns: An `ApiResult` containing the processed image or an error.
    public func removeBackground(fromBase64Image base64: String, options: ApiOptions = ApiOptions()) async throws -> ApiResult {
        let body = try createRequestBody(options: options, imageInput: .base64(base64))
        return try await fetch(body: body)
    }
    
    /// Removes the background from the image provided as raw image data.
    /// - Parameters:
    ///   - imageData: The raw data of the image.
    ///   - options: The options to use for the API call.
    /// - Returns: An `ApiResult` containing the processed image or an error.
    public func removeBackground(fromImageData imageData: Data, options: ApiOptions = ApiOptions()) async throws -> ApiResult {
        let body = try createRequestBody(options: options, imageInput: .data(imageData))
        return try await fetch(body: body)
    }
    
    func createRequestBody(options: ApiOptions, imageInput: ImageInputType) throws -> MultipartFormData {
        var multipart = MultipartFormData(boundary: boundary)
        
        if let optionsDict = options.dictionary {
            for (key, value) in optionsDict {
                if let stringValue = value as? String {
                    multipart.addField(named: key, value: stringValue)
                } else if let boolValue = value as? Bool {
                    multipart.addField(named: key, value: String(boolValue))
                }
            }
        }
        
        switch imageInput {
        case let .base64(base64Image):
            multipart.addField(named: "image_file_b64", value: base64Image)
        case let .data(imageData):
            multipart.addField(named: "image_file", filename: "image", data: imageData)
        case let .remoteURL(imageURL):
            multipart.addField(named: "image_url", value: imageURL.absoluteString)
        }
        
        
        
        return multipart
    }

    
    func fetch(body: MultipartFormData) async throws -> ApiResult {
        let httpRequest = URLRequest(url: RemoveBgClient.endpoint, formData: body)

        let (data, response) = try await urlSession.data(for: httpRequest)
        if let httpResponse = response as? HTTPURLResponse {
            switch httpResponse.statusCode {
            case 200: return .init(imageData: data, meta: .init(urlResponse: response))
            default: throw parseError(fromResponse: httpResponse, data: data)
            }
        } else {
            throw ApiError(errorReason: .badServerResponse, errorsBody: nil)
        }
    }
    
    func parseError(fromResponse response: HTTPURLResponse, data: Data) -> ApiError {
        let errorsBody = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        let statusMapping: [Int: ApiError.Reason] = [
            400: .invalidParameters,
            402: .insufficientCredits,
            403: .authenticationFailed,
            429: .rateLimitExceeded
        ]
        
        return ApiError(errorReason: statusMapping[response.statusCode, default: .badServerResponse], errorsBody: errorsBody)
    }
}

enum ImageInputType {
    case remoteURL(URL)
    case data(Data)
    case base64(String)
}


extension ApiResult.Meta {
    init?(urlResponse: URLResponse) {
        guard let httpResponse = urlResponse as? HTTPURLResponse else {
            return nil
        }

        func parseHeader<T>(_ field: String, _ transform: (String) -> T?) -> T? {
            return httpResponse.value(forHTTPHeaderField: field).flatMap(transform)
        }

        creditsCharged = parseHeader("X-Credits-Charged", Float.init)
        width = parseHeader("X-Width", Int.init)
        height = parseHeader("X-Height", Int.init)
        detectedType = httpResponse.value(forHTTPHeaderField: "X-Type")
        foregroundTop = parseHeader("X-Foreground-Top", Int.init)
        foregroundLeft = parseHeader("X-Foreground-Left", Int.init)
        foregroundWidth = parseHeader("X-Foreground-Width", Int.init)
        foregroundHeight = parseHeader("X-Foreground-Height", Int.init)
    }
}

extension Encodable {
  var dictionary: [String: Any]? {
    guard let data = try? JSONEncoder().encode(self) else { return nil }
    return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
  }
}
