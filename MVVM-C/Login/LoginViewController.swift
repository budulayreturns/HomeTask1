//
//  ViewController.swift
//  MVVM-C
//
//  Created by Dzmitry on 19.11.20.
//

import UIKit

protocol LoginViewCompatible: UIViewController {
    var flowDelegate: LoginFlowDelegate? { get set }
    var model: LoginViewModelCompatible? { get set }
    func hideLoading()
    func showLoading()
    func showLoginError(message: String)
    func hideLoginError()
}

class LoginViewController: UIViewController, LoginViewCompatible {
    // MARK: - Enums

    enum Constants {
        static let cornerRadius: CGFloat = 8
        static let spacing: CGFloat = 8
        static let buttonTitle = "Sign in"
        static let loginPlaceholder = "Login"
        static let passwordPlaceholder = "Password"
        static let navigationBarTitle = "Sign in"
    }

    // MARK: - Properties

    var flowDelegate: LoginFlowDelegate?
    var model: LoginViewModelCompatible?

    private lazy var button: UIButton = {
        let item = UIButton()
        item.accessibilityIdentifier = "signIn"
        item.setTitle(Constants.buttonTitle, for: .normal)
        item.setTitleColor(.white, for: .normal)
        item.layer.cornerRadius = Constants.cornerRadius
        item.backgroundColor = .blue
        item.translatesAutoresizingMaskIntoConstraints = false
        item.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
        return item
    }()

    private lazy var stackView: UIStackView = {
        let item = UIStackView(arrangedSubviews: [loginField, passwordField, errorLabel])
        item.translatesAutoresizingMaskIntoConstraints = false
        item.axis = .vertical
        item.alignment = .fill
        item.distribution = .fillEqually
        item.spacing = Constants.spacing
        return item
    }()

    private lazy var loginField: UITextField = {
        let item = UITextField()
        item.accessibilityIdentifier = "loginField"
        item.isAccessibilityElement = false
        item.translatesAutoresizingMaskIntoConstraints = false
        item.clearsOnInsertion = true
        item.clearsOnBeginEditing = true
        item.placeholder = Constants.loginPlaceholder
        item.layer.cornerRadius = Constants.cornerRadius
        item.borderStyle = .roundedRect
        item.spellCheckingType = .no
        item.autocorrectionType = .no
        item.textContentType = .nickname
        item.autocapitalizationType = .none
        item.delegate = self
        return item
    }()

    private lazy var passwordField: UITextField = {
        let item = UITextField()
        item.accessibilityIdentifier = "passwordField"
        item.isAccessibilityElement = false
        item.translatesAutoresizingMaskIntoConstraints = false
        item.clearsOnInsertion = true
        item.clearsOnBeginEditing = true
        item.placeholder = Constants.passwordPlaceholder
        item.borderStyle = .roundedRect
        item.spellCheckingType = .no
        item.autocorrectionType = .no
        item.textContentType = .password
        item.isSecureTextEntry = true
        item.autocapitalizationType = .none
        item.delegate = self
        return item
    }()

    let errorLabel: UILabel = {
        let item = UILabel()
        item.accessibilityIdentifier = "errorLabel"
        item.translatesAutoresizingMaskIntoConstraints = false
        item.numberOfLines = 0
        item.textColor = .red
        item.isHidden = true
        return item
    }()

    let progressView: UIActivityIndicatorView = {
        let item = UIActivityIndicatorView()
        item.translatesAutoresizingMaskIntoConstraints = false
        item.style = .large
        item.color = .gray
        return item
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: - Public

    func hideLoading() {
        progressView.stopAnimating()
    }

    func showLoading() {
        progressView.startAnimating()
    }

    func showLoginError(message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
    }

    func hideLoginError() {
        errorLabel.isHidden = true
        errorLabel.text = nil
    }

    // MARK: - Actions

    @objc
    func didTapLoginButton() {
        guard let login = loginField.text,
              let password = passwordField.text else { return }
        view.isUserInteractionEnabled = false
        loginField.resignFirstResponder()
        passwordField.resignFirstResponder()
        let credentials = LoginModel(login: login, password: password)
        model?.requestLoginData(model: credentials) { [weak self] in
            self?.view.isUserInteractionEnabled = true
        }
    }
}

// MARK: - Private

private extension LoginViewController {
    func setupUI() {
        view.backgroundColor = .white
        navigationItem.title = Constants.navigationBarTitle
        configureButton()
        configureStackView()
        configureProgressView()
    }

    func configureButton() {
        view.addSubview(button)
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40).isActive = true
    }

    func configureStackView() {
        view.addSubview(stackView)
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: view.centerYAnchor, constant: -40).isActive = true
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
    }

    func configureProgressView() {
        view.addSubview(progressView)
        progressView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        progressView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}

// MARK: - UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        hideLoginError()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
    }
}
