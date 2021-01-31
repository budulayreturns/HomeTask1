//
//  MVVM_CUITests.swift
//  MVVM-CUITests
//
//  Created by Dzmitry on 19.11.20.
//

import XCTest

class MVVM_CUITests: XCTestCase {

    private var app: XCUIApplication?

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app?.launch()

    }

    override func tearDownWithError() throws {
        app = nil
    }

    func testLoginIsSuccessful() throws {
        guard let app = self.app else {
            XCTFail("XCUIApplication is nil")
            return
        }

        let loginField = app.textFields["loginField"]
        input(text: "user", element: loginField)

        let passwordField = app.secureTextFields["passwordField"]
        input(text: "123qwe", element: passwordField)
        input(text: "\n", element: passwordField)

        let signInButton = app.buttons["signIn"]
        signInButton.tap()

        let tableView = app.tables["tableView"]
        let errorLabel = app.staticTexts["errorLabel"]
        XCTAssertTrue(tableView.waitForExistence(timeout: 3))
        XCTAssertFalse(errorLabel.waitForExistence(timeout: 3))
    }

    func testLoginFailed() throws {
        guard let app = self.app else {
            XCTFail("XCUIApplication is nil")
            return
        }

        let loginField = app.textFields["loginField"]
        input(text: "user", element: loginField)

        let passwordField = app.secureTextFields["passwordField"]
        input(text: "00000", element: passwordField)
        input(text: "\n", element: passwordField)

        let signInButton = app.buttons["signIn"]
        signInButton.tap()

        let tableView = app.tables["tableView"]
        let errorLabel = app.staticTexts["errorLabel"]
    
        XCTAssertTrue(errorLabel.waitForExistence(timeout: 3)
                        && errorLabel.label.lowercased().contains("failed"))
        XCTAssertFalse(tableView.waitForExistence(timeout: 3))
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }

    func input(text: String, element: XCUIElement) {
        element.tap()
        element.typeText(text)
    }
}
