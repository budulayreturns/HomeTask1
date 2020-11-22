//
//  URLBuilder.swift
//  MVVM-C
//
//  Created by Dzmitry on 21.11.20.
//

import Foundation

protocol URLBuilderCompatible: class {
    func build() -> URL?
    func set(url: String) -> Self
    func set(query: String) -> Self
}

class URLBuilder: URLBuilderCompatible {
    
    // MARK: - Properties
    
    private var url: String?
    private var query: String?
    
    // MARK: - Public
    
    func set(url: String) -> Self {
        self.url = url
        return self
    }
    
    func set(query: String) -> Self {
        self.query = query
        return self
    }
    
    func build() -> URL? {
        guard let url = self.url else { return nil }
        if var urlComponents = URLComponents(string: url) {
            urlComponents.query = query
            return urlComponents.url
        }
        return nil
    }
}
