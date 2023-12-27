//
//  File.swift
//  
//
//  Created by Piotr Żmudziński on 07/08/2023.
//

import Foundation
@testable import RemoveBg
import MultipartKit

class MockURLProtocol: URLProtocol {
    private static var mockResponse: HTTPURLResponse = .notFound
    private static var mockData: Data? = nil
    static var lastRequest: URLRequest?
    
    public static func set(mockedResponse: HTTPURLResponse, data: Data?) {
        MockURLProtocol.mockResponse = mockedResponse
        MockURLProtocol.mockData = data
    }
    
    public static func clearResponse() {
        MockURLProtocol.mockResponse = .notFound
        MockURLProtocol.mockData = nil
    }
    
    public static func httpBody() throws -> [String: String]? {
        guard let lastRequest, let lastBody = lastRequest.bodyStreamToString() else {
            return nil
        }
        let decoder = FormDataDecoder()
        guard let boundary = lastRequest.boundary else { return nil }
        return try decoder.decode([String: String].self, from: lastBody, boundary: boundary)
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        lastRequest = request
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }
    
    override func startLoading() {
        client?.urlProtocol(self, didReceive: MockURLProtocol.mockResponse, cacheStoragePolicy: .notAllowed)
        if let data = MockURLProtocol.mockData {
            client?.urlProtocol(self, didLoad: data)
        }
        
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {
  
    }
}

private extension URLResponse {
    static let notFound: HTTPURLResponse = .init(url: RemoveBgClient.endpoint, statusCode: 404, httpVersion: nil, headerFields: [:])!
}

extension URLRequest {
    
    var boundary: String? {
        guard let contentTypeHeader = value(forHTTPHeaderField: "Content-Type") else { return nil }
        return contentTypeHeader.replacingOccurrences(of: "multipart/form-data; boundary=", with: "")
    }

    func bodyStreamToString() -> String? {
        guard let bodyStream = self.httpBodyStream else { return nil }

        bodyStream.open()

        let bufferSize: Int = 16

        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)

        var dat = Data()

        while bodyStream.hasBytesAvailable {
            let readDat = bodyStream.read(buffer, maxLength: bufferSize)
            dat.append(buffer, count: readDat)
        }

        buffer.deallocate()
        bodyStream.close()


        return String(data: dat, encoding: .utf8)
    }
}
