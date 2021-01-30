//
//  MVVM_CTests.swift
//  MVVM-CTests
//
//  Created by Dzmitry on 19.11.20.
//

import XCTest
@testable import MVVM_C

class MVVM_CTests: XCTestCase {

    private let testString = "string\nstring"
    private let testUrlString = "https://www.random.org/strings/"
    private let testQueryString = "num=10&len=8&digits=on&upperalpha=on&loweralpha=on&unique=on&format=plain&rnd=new"

    private var testData: Data {
        return Data(testString.utf8)
    }

    override func setUpWithError() throws {

    }

    override func tearDownWithError() throws {

    }

    func test_StringDataParser_Parse() throws {
        let parser = StringDataParser()
        let array = parser.parse(data: testData)
        let result = array.joined(separator: "\n")
        XCTAssertEqual(result, testString)
    }

    func test_URLBuilder_Build() throws {
        let builder = URLBuilder()
        let url = builder
            .set(url: testUrlString)
            .set(url: testQueryString).build()
        XCTAssertNotNil(url)
    }

    func test_URLBuilder_URL() throws {
        let builder = URLBuilder()
        let url = builder
            .set(url: testUrlString)
            .set(query: testQueryString)
            .build()
        let testURL = URL(string: testUrlString + "?" + testQueryString)
        XCTAssertEqual(url, testURL)
    }
}
