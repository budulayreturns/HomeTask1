//
//  LoginViewModelTests.swift
//  MVVM-CTests
//
//  Created by Dzmitry on 22.11.20.
//

import XCTest
@testable import MVVM_C

class LoginViewModelTests: XCTestCase {
    private let testUrlString = "https://www.random.org/strings/"
    private let testQueryString = "num=10&len=8&digits=on&upperalpha=on&loweralpha=on&unique=on&format=plain&rnd=new"

    private var navigationController: UINavigationController!
    private var loginViewModel: LoginViewModelCompatible!
    private var loginView: LoginViewCompatible!

    override func setUpWithError() throws {
        let navigationController = UINavigationController()
        self.navigationController = navigationController
        UIApplication.shared.windows.first?.rootViewController = navigationController
        let flowDelegate = LoginFlowController(navigationController: navigationController)
        loginView = LoginViewController()
        loginViewModel = LoginViewModel(view: loginView, flowDelegate: flowDelegate)
        loginView.flowDelegate = flowDelegate
        loginView.model = loginViewModel
    }

    override func tearDownWithError() throws {
        navigationController = nil
        loginViewModel = nil
        loginView = nil
        UIApplication.shared.windows.first?.rootViewController = nil
    }

    func test_LoginViewModel_LoginSuccessful() throws {
        let model = LoginModel(login: "user", password: "123qwe")
        let provider = LoginDataProviderMock()
        provider.result = .success((testUrlString, testQueryString))
        loginViewModel.loginDataProvider = provider

        navigationController?.setViewControllers([loginView], animated: false)
        let promise = expectation(description: "Request finished.")

        loginViewModel.requestLoginData(model: model) { [weak self] in
            let view = self?.loginView as? LoginViewController
            XCTAssertTrue(view?.progressView.isHidden ?? false)
            promise.fulfill()
        }
        wait(for: [promise], timeout: 10)
        guard let view = navigationController?.viewControllers.first as? ListViewController else { return XCTFail() }
        XCTAssertNotNil(view.model?.url)
    }

    func test_LoginViewModel_LoginFailed() throws {
        let errorText = "Error"
        let model = LoginModel(login: "", password: "")
        let provider = LoginDataProviderMock()
        provider.result = .failure(.init(message: errorText, kind: .failed))
        loginViewModel.loginDataProvider = provider
        navigationController?.setViewControllers([loginView], animated: false)
        let promise = expectation(description: "Request finished.")
        loginViewModel.requestLoginData(model: model) {
            promise.fulfill()
        }
        wait(for: [promise], timeout: 10)
        guard let viewController = navigationController?.viewControllers.first as? LoginViewController else {
            return XCTFail()
        }
        XCTAssertEqual(viewController.errorLabel.text, errorText)
        XCTAssertFalse(viewController.errorLabel.isHidden)
        XCTAssertTrue(viewController.progressView.isHidden)
    }

    func test_LoginViewModel_ErrorHidden() throws {
        navigationController?.setViewControllers([loginView], animated: false)
        guard let viewController = navigationController?.viewControllers.first as? LoginViewController else {
            return XCTFail()
        }
        XCTAssertTrue(viewController.errorLabel.isHidden)
    }

    func test_LoginViewModel_ProgressShown() throws {
        let model = LoginModel(login: "user", password: "123qwe")
        let provider = LoginDataProviderMock()
        provider.result = .success((testUrlString, testQueryString))
        loginViewModel.loginDataProvider = provider
        navigationController?.setViewControllers([loginView], animated: false)

        loginViewModel.requestLoginData(model: model, completion: nil)
        guard let viewController = navigationController?.viewControllers.first as? LoginViewController else {
            return XCTFail()
        }
        XCTAssertFalse(viewController.progressView.isHidden)
    }
}
