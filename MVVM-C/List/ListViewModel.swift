//
//  ListViewModel.swift
//  MVVM-C
//
//  Created by Dzmitry on 19.11.20.
//

import Foundation

protocol ListViewModelCompatible: class {
    var url: URL? { get }
    var numberOfRows: Int { get }
    var listDataProvider: ListDataProviderCompatible { get set }
    func textForRow(at index: Int, order: Order?) -> String?
    func requestListData(completion: (() -> Void)?)
    func cancelRequestData()
}

enum Order: Int {
    case unsorted = 0, ascending, descending
}

final class ListViewModel {
    // MARK: - Properties
    var url: URL?
    weak var flowDelegate: LoginFlowDelegate?
    weak var view: ListViewCompatible?

    var model: [String] = []
    var listDataProvider: ListDataProviderCompatible = ListDataProvider()

    private let dataParser: StringDataParserCompatible = StringDataParser()

    // MARK: - Lifecycle

    init(view: ListViewCompatible, flowDelegate: LoginFlowDelegate) {
        self.view = view
        self.flowDelegate = flowDelegate
    }
}

// MARK: - ListViewModelCompatible protocol

extension ListViewModel: ListViewModelCompatible {
    var numberOfRows: Int {
        return model.count
    }

    func textForRow(at index: Int, order: Order?) -> String? {
        if model.indices.contains(index) {
            return sort(model: model, order: order)[index]
        }
        return nil
    }

    func requestListData(completion: (() -> Void)?) {
        guard let url = url else {
            completion?()
            return
        }
        view?.showLoading()
        listDataProvider.load(url: url) { result in
            DispatchQueue.main.async { [weak self] in
                self?.view?.hideLoading()
            }
            switch result {
            case .success(let data):
                DispatchQueue.main.async { [weak self] in
                    self?.model = self?.dataParser.parse(data: data) ?? []
                    self?.view?.reloadData()
                    completion?()
                }
            case .failure(let error):
                DispatchQueue.main.async { [weak self] in
                    self?.flowDelegate?.routeToAlert(message: error.message)
                    completion?()
                }
            }
        }
    }

    func cancelRequestData() {
        listDataProvider.cancel()
    }
}

// MARK: - Private

private extension ListViewModel {
    func sort(model: [String], order: Order?) -> [String] {
        switch order {
        case .ascending:
            return model.sorted(by: <)
        case .descending:
            return model.sorted(by: >)
        default:
            return model
        }
    }
}
