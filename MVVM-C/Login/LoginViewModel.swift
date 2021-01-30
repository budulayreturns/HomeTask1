//
//  LoginViewModel.swift
//  MVVM-C
//
//  Created by Dzmitry on 19.11.20.
//

import Foundation

protocol LoginViewModelCompatible {
    var loginDataProvider: LoginDataProviderCompatible { get set }
    func requestLoginData(model: LoginModelCompatible, completion: (() -> Void)?)
}

final class LoginViewModel {
    // MARK: - Properties

    weak var view: LoginViewCompatible?
    weak var flowDelegate: LoginFlowDelegate?
    var loginDataProvider: LoginDataProviderCompatible = LoginDataProvider()

    private let urlBuilder: URLBuilderCompatible = URLBuilder()

    // MARK: - Lifecycle

    init(view: LoginViewCompatible, flowDelegate: LoginFlowDelegate) {
        self.view = view
        self.flowDelegate = flowDelegate
    }
}

// MARK: - LoginViewModelCompatible protocol

extension LoginViewModel: LoginViewModelCompatible {
    func requestLoginData(model: LoginModelCompatible, completion: (() -> Void)?) {
        view?.showLoading()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.loginDataProvider.login(with: model) { result in
                switch result {
                case .success((let urlString, let queryString)):
                    self?.view?.hideLoading()
                    let url = self?.urlBuilder
                        .set(url: urlString)
                        .set(query: queryString)
                        .build()
                    self?.flowDelegate?.routeToList(url: url)
                    // completion?()
                case .failure(let error):
                    self?.view?.hideLoading()
                    switch error.kind {
                    case .failed:
                        self?.view?.showLoginError(message: error.message)
                    }
                }
                completion?()
            }
        }
    }
}
