//
//  LoginDataProviderMock.swift
//  MVVM-CTests
//
//  Created by Dzmitry on 22.11.20.
//

import Foundation
@testable import MVVM_C

class LoginDataProviderMock: LoginDataProviderCompatible {
    var result: Result<(url: String, query: String), LoginError>?

    func login(with model: LoginModelCompatible, completion: (Result<(url: String, query: String), LoginError>) -> Void) {
        guard let result = result else { fatalError("No result was defined in the mock.") }
        completion(result)
    }
}
