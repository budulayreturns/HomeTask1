//
//  ListViewController.swift
//  MVVM-C
//
//  Created by Dzmitry on 19.11.20.
//

import UIKit

protocol ListViewCompatible: UIViewController {
    var flowDelegate: LoginFlowDelegate? { get set }
    var model: ListViewModelCompatible? { get set }
    func reloadData()
    func showLoadingError(message: String)
    func showLoading()
    func hideLoading()
}

final class ListViewController: UIViewController, ListViewCompatible {
    
    // MARK: - Enums
    
    enum Constants {
        static let reusableIdentifier = "basicStyle"
        static let logoutButtonName = "Logout"
        static let navigationBarTitle = "List"
        static let okActionName = "Ok"
    }
    
    // MARK: - Properties
    
    var model: ListViewModelCompatible?
    var flowDelegate: LoginFlowDelegate?
    
    private lazy var barButton: UIBarButtonItem = {
        let item = UIBarButtonItem(title: Constants.logoutButtonName,
                                  style: .plain,
                                  target: self,
                                  action: #selector(didTapLogout))
        return item
    }()
    
    private lazy var tableView: UITableView = {
        let item = UITableView()
        item.translatesAutoresizingMaskIntoConstraints = false
        item.delegate = self
        item.dataSource = self
        item.register(UITableViewCell.self,
                      forCellReuseIdentifier: Constants.reusableIdentifier)
        return item
    }()
    
    let progressView: UIActivityIndicatorView = {
        let item = UIActivityIndicatorView()
        item.translatesAutoresizingMaskIntoConstraints = false
        item.style = .large
        item.color = .gray
        return item
    }()
    
    // MARK: - Lifecyle
    
    deinit {
        model?.cancelRequestData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        model?.requestListData(completion: nil)
    }
    
    // MARK: - Public
    
    func showLoading() {
        progressView.startAnimating()
    }
    
    func hideLoading() {
        progressView.stopAnimating()
    }
    
    func reloadData() {
        tableView.reloadData()
    }
    
    func showLoadingError(message: String) {
        flowDelegate?.routeToAlert(message: message)
    }
    
    // MARK: - Actions
    
    @objc
    func didTapLogout() {
        flowDelegate?.routeToLogin()
    }
}

// MARK: - Private

private extension ListViewController {
    func setupUI() {
        view.backgroundColor = .white
        configureTableView()
        configureProgressView()
        configureNavigationBarButton()
    }
    
    func configureNavigationBarButton() {
        navigationItem.title = Constants.navigationBarTitle
        navigationItem.rightBarButtonItem = barButton
    }
    
    func configureProgressView() {
        view.addSubview(progressView)
        progressView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        progressView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    func configureTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model?.numberOfRows ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.reusableIdentifier, for: indexPath)
        cell.textLabel?.text = model?.textForRow(at: indexPath.row)
        return cell
    }
}
