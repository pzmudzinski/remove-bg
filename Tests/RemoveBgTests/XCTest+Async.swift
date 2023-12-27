//
//  File.swift
//  
//
//  Created by Piotr Żmudziński on 07/08/2023.
//

import XCTest
import Foundation
@testable import RemoveBg

extension XCTest {
    func XCTAssertThrowsError<T: Sendable>(
        _ expression: @autoclosure () async throws -> T,
        _ message: @autoclosure () -> String = "",
        file: StaticString = #filePath,
        line: UInt = #line,
        _ errorHandler: (_ error: ApiError) -> Void = { _ in }
    ) async {
        do {
            _ = try await expression()
            XCTFail(message(), file: file, line: line)
        } catch {
            (error as? ApiError).flatMap(errorHandler)
        }
    }
}
