//
//  LoginFlowControllerTests.swift
//  MVVM-CTests
//
//  Created by Dzmitry on 22.11.20.
//

import XCTest
@testable import MVVM_C

class LoginFlowControllerTests: XCTestCase {
    private let testString = "string\nstring"
    private var navigationController: UINavigationController?
    private weak var flowDelegate: LoginFlowDelegate?

    override func setUpWithError() throws {
        navigationController = UINavigationController()
        guard let navigationController = navigationController else {
            fatalError("UINavigationController not found.")
        }
        UIApplication.shared.windows.first?.rootViewController = navigationController
        flowDelegate = LoginFlowController(navigationController: navigationController)
    }

    override func tearDownWithError() throws {
        navigationController = nil
        flowDelegate = nil
        UIApplication.shared.windows.first?.rootViewController = nil
    }

    func test_LoginFlowController_routeToLogin() throws {
        flowDelegate?.routeToLogin()
        XCTAssert(navigationController?.viewControllers.first is LoginViewController)
    }

    func test_LoginFlowController_routeToList() throws {
        flowDelegate?.routeToList(url: nil)
        XCTAssert(navigationController?.viewControllers.first is ListViewController)
    }

    func test_LoginFlowController_routeToAlert() throws {
        flowDelegate?.routeToAlert(message: "")
        XCTAssert(navigationController?.presentedViewController is UIAlertController)
    }

    func test_LoginFlowController_routeToAlertMessage() throws {
        flowDelegate?.routeToAlert(message: testString)
        guard let alert = navigationController?.presentedViewController as? UIAlertController else {
            return XCTFail()
        }
        XCTAssertEqual(alert.message, testString)
    }
}
