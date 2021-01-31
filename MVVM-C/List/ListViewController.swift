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
        static let asIs = "As is"
        static let ascendingOrder = "A-Z"
        static let descendingOrder = "Z-A"
    }

    // MARK: - Properties

    var model: ListViewModelCompatible?
    var flowDelegate: LoginFlowDelegate?

    private lazy var barButton: UIBarButtonItem = {
        let item = UIBarButtonItem(
            title: Constants.logoutButtonName,
            style: .plain,
            target: self,
            action: #selector(didTapLogout))
        return item
    }()

    private lazy var segmentedControl: UISegmentedControl = {
        let item = UISegmentedControl(
            items: [Constants.asIs, Constants.ascendingOrder, Constants.descendingOrder]
        )
        item.accessibilityIdentifier = "segmentedControl"
        item.selectedSegmentIndex = 0
        item.translatesAutoresizingMaskIntoConstraints = false
        item.addTarget(self, action: #selector(indexChanged(_:)), for: .valueChanged)
        return item
    }()

    private lazy var tableView: UITableView = {
        let item = UITableView()
        item.accessibilityIdentifier = "tableView"
        item.translatesAutoresizingMaskIntoConstraints = false
        item.delegate = self
        item.dataSource = self
        item.register(
            UITableViewCell.self,
            forCellReuseIdentifier: Constants.reusableIdentifier
        )
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

    @objc func didTapLogout() {
        flowDelegate?.routeToLogin()
    }
    
    @objc func indexChanged(_ sender: UISegmentedControl) {
        reloadData()
    }
}

// MARK: - Private

private extension ListViewController {
    func setupUI() {
        view.backgroundColor = .white
        configureSegmentedControl()
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
        NSLayoutConstraint.activate([
            progressView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    func configureSegmentedControl() {
        view.addSubview(segmentedControl)
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    func configureTableView() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 4),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model?.numberOfRows ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.reusableIdentifier, for: indexPath)
        cell.textLabel?.text = model?.textForRow(
            at: indexPath.row,
            order: Order.init(rawValue: segmentedControl.selectedSegmentIndex)
        )
        return cell
    }
}
