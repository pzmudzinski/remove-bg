//
//  Multipart.swift
//  
//
//  Created by Piotr Żmudziński on 27/12/2023.
//

import Foundation

struct MultipartFormData {
    fileprivate let boundary: String
    private var formData = Data()
    
    init(boundary: String) {
        self.boundary = boundary
    }

    fileprivate var httpBody: Data {
        var data = formData
        data.append("--\(boundary)--")
        return data
    }

    mutating func addField(named name: String, value: String) {
        formData.addField("--\(boundary)")
        formData.addField("Content-Disposition: form-data; name=\"\(name)\"")
        formData.addField()
        formData.addField(value)
    }

    mutating func addField(named name: String, filename: String, data: Data) {
        formData.addField("--\(boundary)")
        formData.addField("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename)\"")
        formData.addField()
        formData.addField(data)
    }
}

extension URLRequest {
    init(url: URL, formData: MultipartFormData) {
        self.init(url: url)
        httpMethod = "POST"
        setValue("multipart/form-data; boundary=\(formData.boundary)", forHTTPHeaderField: "Content-Type")
        httpBody = formData.httpBody
    }
}

fileprivate extension Data {
    mutating func append(_ string: String) {
        append(Data(string.utf8))
    }

    mutating func addField() {
        append(.httpFieldDelimiter)
    }

    mutating func addField(_ string: String) {
        append(string)
        append(.httpFieldDelimiter)
    }

    mutating func addField(_ data: Data) {
        append(data)
        append(.httpFieldDelimiter)
    }
}

fileprivate extension String {
    static let httpFieldDelimiter = "\r\n"
}
