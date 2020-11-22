//
//  ListDataProvider.swift
//  MVVM-C
//
//  Created by Dzmitry on 21.11.20.
//

import Foundation

struct NetworkError: Error {
    enum ErrorKind {
        case noData
        case unavailable
        case networkError
    }
    let code: Int
    let message: String
    let kind: ErrorKind
}

protocol ListDataProviderCompatible {
    func load(url: URL, completion: @escaping (Result<Data, NetworkError>) -> Void)
    func cancel()
}

final class ListDataProvider: ListDataProviderCompatible {
    
    // MARK: - Properties
    
    enum Constants {
        static let noData = "No data."
    }
    
    private let defaultURLSession = URLSession(configuration: .default)
    private var dataTask: URLSessionDataTask?
    
    
    deinit {
        dataTask?.cancel()
    }
    
    // MARK: - Public
    
    func load(url: URL,
              completion: @escaping (Result<Data, NetworkError>) -> Void) {
        
        dataTask?.cancel()
        
        dataTask = defaultURLSession.dataTask(with: url,
                                              completionHandler: { [weak self] (data, response, error) in
            defer {
                self?.dataTask = nil
            }
            if let error = error {
                return completion(.failure(.init(code: -1,
                                          message: error.localizedDescription,
                                          kind: .networkError)))
            }
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200...299:
                    if let data = data {
                        return completion(.success(data))
                    }
                    return completion(.failure(.init(code: httpResponse.statusCode,
                                                     message: Constants.noData,
                                                     kind: .noData)))
                default:
                    return completion(.failure(.init(code: httpResponse.statusCode,
                                                     message: response?.description ?? "",
                                                     kind: .networkError)))
                }
            }
        })
        dataTask?.resume()
    }
    
    func cancel() {
        dataTask?.cancel()
    }
}
