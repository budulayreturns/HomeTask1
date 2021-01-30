//
//  ListDataProviderMock.swift
//  MVVM-CTests
//
//  Created by Dzmitry on 22.11.20.
//

import Foundation
@testable import MVVM_C

final class ListDataProviderMock: ListDataProviderCompatible {
    var result: Result<Data, NetworkError>?
    var immediatelyExecute: (() -> Void)?

    private var isLoading = false

    func load(url: URL, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        guard let result = result else { fatalError("No result was defined in the mock.") }
        completion(result)
    }

    func cancel() {
        immediatelyExecute?()
    }
}
