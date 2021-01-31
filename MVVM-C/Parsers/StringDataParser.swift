//
//  StringDataParser.swift
//  MVVM-C
//
//  Created by Dzmitry on 21.11.20.
//

import Foundation

protocol StringDataParserCompatible {
    func parse(data: Data) -> [String]
}

struct StringDataParser: StringDataParserCompatible {
    func parse(data: Data) -> [String] {
        let string = String(data: data, encoding: .utf8)
        return string?
            .trimmingCharacters(in: .newlines)
            .components(separatedBy: .newlines) ?? []
    }
}
