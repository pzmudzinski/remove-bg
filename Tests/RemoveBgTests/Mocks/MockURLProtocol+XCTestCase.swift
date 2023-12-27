//
//  File.swift
//  
//
//  Created by Piotr Żmudziński on 07/08/2023.
//

import Foundation
import XCTest

extension XCTest {
    var httpBody: [String: String] {
        (try? MockURLProtocol.httpBody()) ?? [:]
    }
    
    
    func addMockResponse(response: HTTPURLResponse, data: Data? = nil) {
        MockURLProtocol.set(mockedResponse: response, data: data)
    }
}

func XCTAssertHeader(key: String, value: String, file: StaticString = #filePath, line: UInt = #line) {
    guard let lastRequest = MockURLProtocol.lastRequest else {
        XCTFail("No URLRequest recorded", file: file, line: line)
        return
    }
    
    XCTAssertEqual(value, lastRequest.allHTTPHeaderFields?[key], file: file, line: line)
}

//@available(iOS 15, macOS 13, *)
//func XCTAssertHeader(key: String, value: Regex<Substring>, file: StaticString = #filePath, line: UInt = #line) {
//    guard let lastRequest = MockURLProtocol.lastRequest else {
//        XCTFail("No URLRequest recorded", file: file, line: line)
//        return
//    }
//    
//    let headerValue = lastRequest.value(forHTTPHeaderField: key)
//    
//    let match = headerValue?.firstMatch(of: value)
//    
//    XCTAssertNotNil(match, file: file, line: line)
//}

func XCTAssertMultipart(key: String, value: String, file: StaticString = #filePath, line: UInt = #line) {
    guard let lastRequest = MockURLProtocol.lastRequest else {
        XCTFail("No URLRequest recorded", file: file, line: line)
        return
    }
    
    
    
    XCTAssertEqual(value, lastRequest.allHTTPHeaderFields?[key], file: file, line: line)
}
