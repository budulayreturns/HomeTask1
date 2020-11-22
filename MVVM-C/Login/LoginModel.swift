//
//  LoginModel.swift
//  MVVM-C
//
//  Created by Dzmitry on 19.11.20.
//

import Foundation

protocol LoginModelCompatible {
    var login: String { get }
    var password: String { get }
}

struct LoginModel: LoginModelCompatible {
    let login: String
    let password: String
}


