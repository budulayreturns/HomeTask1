//
//  LoginDataProvider.swift
//  MVVM-C
//
//  Created by Dzmitry on 21.11.20.
//

import Foundation

struct LoginError: Error {
    enum ErrorKind {
        case failed
    }
    let message: String
    let kind: ErrorKind
}

protocol LoginDataProviderCompatible {
    func login(
        with model: LoginModelCompatible,
        completion: (Result<(url: String, query: String), LoginError>) -> Void
    )
}

struct LoginDataProvider: LoginDataProviderCompatible {
    private enum Constants {
        static let user = "user"
        static let password = "123qwe"
        static let loginError = "Sign in failed. Please check login or password"
        static let urlString = "https://www.random.org/strings/"
        static let queryString = "num=10&len=8&digits=on&upperalpha=on&loweralpha=on&unique=on&format=plain&rnd=new"
    }

    func login(
        with model: LoginModelCompatible,
        completion: (Result<(url: String, query: String), LoginError>) -> Void
    ) {
        guard model.login == Constants.user && model.password == Constants.password else {
            return completion(.failure(LoginError(
                                        message: Constants.loginError,
                                        kind: .failed)))
        }
        completion(.success((Constants.urlString, Constants.queryString)))
    }
}
