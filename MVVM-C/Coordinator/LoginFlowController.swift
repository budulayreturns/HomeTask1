//
//  LoginFlowController.swift
//  MVVM-C
//
//  Created by Dzmitry on 19.11.20.
//

import UIKit

protocol LoginFlowDelegate: class {
    func routeToLogin()
    func routeToList(url: URL?)
    func routeToAlert(message: String)
}

final class LoginFlowController: LoginFlowDelegate {
    // MARK: - Enums

    enum Constants {
        static let okActionName = "Ok"
    }

    // MARK: - Properties

    private weak var navigationController: UINavigationController?

    // MARK: - Lifecycle

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    // MARK: - Public

    func routeToLogin() {
        let view = LoginViewController()
        let model = LoginViewModel(view: view, flowDelegate: self)
        view.model = model
        view.flowDelegate = self
        navigationController?.setViewControllers([view], animated: true)
    }

    func routeToList(url: URL?) {
        let view = ListViewController()
        let model = ListViewModel(view: view, flowDelegate: self)
        model.url = url
        view.model = model
        view.flowDelegate = self
        navigationController?.setViewControllers([view], animated: true)
    }

    func routeToAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: Constants.okActionName, style: .default, handler: nil)
        alert.addAction(action)
        navigationController?.present(alert, animated: true, completion: nil)
    }
}
