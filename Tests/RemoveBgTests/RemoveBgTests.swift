import XCTest
@testable import RemoveBg

final class RemoveBgParametersTests: XCTestCase {
    private let apiKey = "MY_TEST_API_KEY"
    private var client: RemoveBgClient!
    
    override func setUp() {
        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.protocolClasses = [MockURLProtocol.self]
        client = RemoveBgClient(urlSessionConfiguration: sessionConfiguration, apiKey: apiKey)
        
        addMockResponse(response: .init(url: RemoveBgClient.endpoint, statusCode: 200, httpVersion: nil, headerFields: nil)!, data: "IMAGE".data(using: .utf8))
        super.setUp()
    }
    
    func testApiKeyHeader() async throws {
        let _ = try await client.removeBackground(fromFileAtUrl: .sampleImage)
        XCTAssertHeader(key: "X-Api-Key", value: apiKey)
    }
    
//    @available(iOS 15, macOS 13, *)
//    func testContentType() async throws {
//        let _ = try await client.removeBackground(fromFileAtUrl: .sampleImage)
//        let regex = #/^multipart/form-data; boundary=.+$/#
//        XCTAssertHeader(key: "Content-Type", value: regex)
//    }
   
    func testAcceptContentType() async throws {
        let _ = try await client.removeBackground(fromFileAtUrl: .sampleImage)
        XCTAssertHeader(key: "Accept", value: "image/*")
    }
    
    func testImageUrl() async throws {
        let _ = try await client.removeBackground(fromFileAtUrl: .sampleImage)
        XCTAssertEqual(URL.sampleImage.absoluteString, httpBody["image_url"])
    }
    
    func testImageBase64() async throws {
        let _ = try await client.removeBackground(fromBase64Image: "ABC")
        XCTAssertEqual("ABC", httpBody["image_file_b64"] )
    }
    
    func testImageData() async throws {
        let imageData = "IMAGE".data(using: .utf8)!
        let _ = try await client.removeBackground(fromImageData: imageData)
        XCTAssertEqual("IMAGE", httpBody["image_file"])
    }
    
    func testSize() async throws {
        let _ = try await client.removeBackground(fromFileAtUrl: .sampleImage, options: .init(size: .full))
        XCTAssertEqual("full", httpBody["size"])
    }
    
    func testCropMargin() async throws {
        let _ = try await client.removeBackground(fromFileAtUrl: .sampleImage, options: .init(cropMargin: "30px"))
        XCTAssertEqual("30px", httpBody["crop_margin"])
    }
    
    func testTypeLevel() async throws {
        let _ = try await client.removeBackground(fromFileAtUrl: .sampleImage, options: .init(typeLevel: .two))
        XCTAssertEqual("2", httpBody["type_level"])
    }
    
    func testCrop() async throws {
        let _ = try await client.removeBackground(fromFileAtUrl: .sampleImage, options: .init(crop: false))
        XCTAssertEqual("false", httpBody["crop"])
    }
    
    func testMultipeOptions() async throws {
        let _ = try await client.removeBackground(fromFileAtUrl: .sampleImage, options: .init(position: "10%", bgColor: "#FFF"))
        XCTAssertEqual("10%", httpBody["position"])
        XCTAssertEqual("#FFF", httpBody["bg_color"])
    }
}

final class RemoveBgHeadersTests: XCTestCase {
    private let apiKey = "MY_TEST_API_KEY_2"
    private var client: RemoveBgClient!
    
    override func setUp() {
        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.protocolClasses = [MockURLProtocol.self]
        client = RemoveBgClient(urlSessionConfiguration: sessionConfiguration, apiKey: apiKey)
        addMockResponse(response: .init(url: .sampleImage, statusCode: 200, httpVersion: nil, headerFields: [
            "X-Type": "auto",
            "X-Width": "640",
            "X-Height": "480",
            "X-Credits-Charged": "0.25",
            "X-Foreground-Top": "10",
            "X-Foreground-Left": "20",
            "X-Foreground-Width": "620",
            "X-Foreground-Height": "440"
        ])!)
        super.setUp()
    }
    
    func testType() async throws {
        let result = try await client.removeBackground(fromImageData: .init())
        XCTAssertEqual("auto", result.meta?.detectedType)
    }

    func testWidth() async throws {
        let result = try await client.removeBackground(fromImageData: .init())
        XCTAssertEqual(640, result.meta?.width)
    }
    
    func testHeight() async throws {
        let result = try await client.removeBackground(fromImageData: .init())
        XCTAssertEqual(480, result.meta?.height)
    }
    
    func testCreditsCharged() async throws {
        let result = try await client.removeBackground(fromImageData: .init())
        XCTAssertEqual(0.25, result.meta?.creditsCharged)
    }
    
    func testForegroundTop() async throws {
        let result = try await client.removeBackground(fromImageData: .init())
        XCTAssertEqual(10, result.meta?.foregroundTop)
    }
    
    func testForegroundLeft() async throws {
        let result = try await client.removeBackground(fromImageData: .init())
        XCTAssertEqual(20, result.meta?.foregroundLeft)
    }
    
    func testForegroundWidth() async throws {
        let result = try await client.removeBackground(fromImageData: .init())
        XCTAssertEqual(620, result.meta?.foregroundWidth)
    }
    
    func testForegroundHeight() async throws {
        let result = try await client.removeBackground(fromImageData: .init())
        XCTAssertEqual(440, result.meta?.foregroundHeight)
    }
}

final class RemoveBgErrorsTests: XCTestCase {
    private let apiKey = "MY_TEST_API_KEY_2"
    private var client: RemoveBgClient!
    
    override func setUp() {
        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.protocolClasses = [MockURLProtocol.self]
        client = RemoveBgClient(urlSessionConfiguration: sessionConfiguration, apiKey: apiKey)
        super.setUp()
    }
    
    func testBadResponseIfNotExpectedStatusCode() async {
        addMockResponse(response: .init(url: .sampleImage, statusCode: 404, httpVersion: nil, headerFields: nil)!)
        
        await XCTAssertThrowsError(try await client.removeBackground(fromImageData: .init())) { error in
            XCTAssertEqual(ApiError.Reason.badServerResponse, error.reason)
        }
    }
    
    func testInsufficientCredits() async {
        addMockResponse(response: .init(url: .sampleImage, statusCode: 402, httpVersion: nil, headerFields: nil)!)
        
        await XCTAssertThrowsError(try await client.removeBackground(fromImageData: .init())) { error in
            XCTAssertEqual(ApiError.Reason.insufficientCredits, error.reason)
        }
    }
    
    func testAuthenticationFailed() async {
        addMockResponse(response: .init(url: .sampleImage, statusCode: 403, httpVersion: nil, headerFields: nil)!)
        
        await XCTAssertThrowsError(try await client.removeBackground(fromImageData: .init())) { error in
            XCTAssertEqual(ApiError.Reason.authenticationFailed, error.reason)
        }
    }
    
    func testRateLimitExceeded() async {
        addMockResponse(response: .init(url: .sampleImage, statusCode: 429, httpVersion: nil, headerFields: nil)!)
        
        await XCTAssertThrowsError(try await client.removeBackground(fromImageData: .init())) { error in
            XCTAssertEqual(ApiError.Reason.rateLimitExceeded, error.reason)
        }
    }
    
    func testInvalidParameters() async {
        addMockResponse(response: .init(url: .sampleImage, statusCode: 400, httpVersion: nil, headerFields: nil)!)
        
        await XCTAssertThrowsError(try await client.removeBackground(fromImageData: .init())) { error in
            XCTAssertEqual(ApiError.Reason.invalidParameters, error.reason)
        }
    }
    
    func testInvalidParametersBody() async {
        let response = [
          "errors": [
            [
              "code": "resolution_too_high",
              "title": "Image resolution too high",
              "detail": "Input image has 60 megapixels, maximum supported input resolution is 50 megapixels"
            ]
          ]
        ]
        
        addMockResponse(
            response: .init(url: .sampleImage, statusCode: 400, httpVersion: nil, headerFields: nil)!,
            data: try? JSONSerialization.data(withJSONObject: response)
        )
        
        await XCTAssertThrowsError(try await client.removeBackground(fromImageData: .init())) { error in
            let nsError = error as NSError
            let errors = nsError.userInfo["errors"] as? Array<[String: String]>
            XCTAssertEqual("resolution_too_high", errors?.first?["code"])
            XCTAssertEqual("Image resolution too high", errors?.first?["title"])
            XCTAssertEqual("Input image has 60 megapixels, maximum supported input resolution is 50 megapixels", errors?.first?["detail"])
        }
    }
}


extension URL {
    static let sampleImage = URL(string: "https://i.insider.com/602ee9ced3ad27001837f2ac?width=2000&format=jpeg&auto=webp")!
}
