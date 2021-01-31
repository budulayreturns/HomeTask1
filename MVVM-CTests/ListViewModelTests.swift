//
//  ListViewModelTests.swift
//  MVVM-CTests
//
//  Created by Dzmitry on 22.11.20.
//

import XCTest
@testable import MVVM_C

class ListViewModelTests: XCTestCase {
    private let testUrl = URL(string: "https://www.random.org/strings/?num=10&len=8&digits=on&upperalpha=on&loweralpha=on&unique=on&format=plain&rnd=new")

    private let testArray = ["1", "2", "b", "a"]
    private let testString = "1\n2\nb\na\n"
    private let errorText = "Error"
    private var testData: Data {
        return Data(testString.utf8)
    }

    private var navigationController: UINavigationController!
    private var listViewModel: ListViewModelCompatible!
    private var listView: ListViewCompatible!

    override func setUpWithError() throws {
        let navigationController = UINavigationController()
        self.navigationController = navigationController
        UIApplication.shared.windows.first?.rootViewController = navigationController
        let flowDelegate = LoginFlowController(navigationController: navigationController)
        listView = ListViewController()
        listViewModel = ListViewModel(view: listView, flowDelegate: flowDelegate)
        listView.flowDelegate = flowDelegate
        listView.model = listViewModel
    }

    override func tearDownWithError() throws {
        navigationController = nil
        listViewModel = nil
        listView = nil
        UIApplication.shared.windows.first?.rootViewController = nil
    }

    func test_ListViewModel_NumberOfRows() throws {
        guard let listViewModel = self.listViewModel as? ListViewModel else {
            return XCTFail("listViewModel is nil")
        }
        listViewModel.model = testArray
        XCTAssertEqual(listViewModel.numberOfRows, testArray.count)
    }

    func test_ListViewModel_TextForRowUnsorted() throws {
        guard let listViewModel = self.listViewModel as? ListViewModel else {
            return XCTFail("listViewModel is nil")
        }
        listViewModel.model = testArray
        var resultArray: [String] = []
        for index in 0...listViewModel.model.count {
            guard let string = listViewModel.textForRow(at: index, order: .unsorted) else { continue }
            resultArray.append(string)
        }
        XCTAssertEqual(resultArray, testArray)
    }

    func test_ListViewModel_TextForRowAscending() throws {
        guard let listViewModel = self.listViewModel as? ListViewModel else {
            return XCTFail("listViewModel is nil")
        }
        listViewModel.model = testArray
        var resultArray: [String] = []
        for index in 0...listViewModel.model.count {
            guard let string = listViewModel.textForRow(at: index, order: .ascending) else { continue }
            resultArray.append(string)
        }
        XCTAssertEqual(resultArray, testArray.sorted(by: <))
    }

    func test_ListViewModel_TextForRowDescending() throws {
        guard let listViewModel = self.listViewModel as? ListViewModel else {
            return XCTFail("listViewModel is nil")
        }
        listViewModel.model = testArray

        var resultArray: [String] = []
        for index in 0...listViewModel.model.count {
            guard let string = listViewModel.textForRow(at: index, order: .descending) else { continue }
            resultArray.append(string)
        }
        XCTAssertEqual(resultArray, testArray.sorted(by: >))
    }

    func test_ListViewModel_LoadSuccessful() throws {
        let provider = ListDataProviderMock()
        provider.result = .success(testData)

        listViewModel.listDataProvider = provider
        navigationController?.setViewControllers([listView], animated: false)

        guard let viewModel = listViewModel as? ListViewModel else { return XCTFail("listViewModel is nil") }
        viewModel.url = testUrl
        let promise = expectation(description: "Load finished")

        listViewModel.requestListData { [weak self] in
            let view = self?.listView as? ListViewController
            XCTAssertTrue(view?.progressView.isHidden ?? false)
            promise.fulfill()
        }
        wait(for: [promise], timeout: 10)

        guard let view = self.listView as? ListViewController else {
            return XCTFail("listView is nil")
        }

        XCTAssertFalse(viewModel.model.isEmpty)
        XCTAssertEqual(viewModel.model, testArray)
        expectToEventually(view.progressView.isHidden, timeout: 2)
    }

    func test_ListViewModel_EmptyURL() throws {
        let provider = ListDataProviderMock()
        provider.result = .success(testData)

        listViewModel.listDataProvider = provider
        navigationController?.setViewControllers([listView], animated: false)

        guard let viewModel = listViewModel as? ListViewModel else { return XCTFail("listViewModel is nil") }
        viewModel.url = nil
        let promise = expectation(description: "Load finished")

        listViewModel.requestListData {
            promise.fulfill()
        }
        wait(for: [promise], timeout: 10)
        XCTAssertTrue(viewModel.model.isEmpty)
    }

    func test_ListViewModel_LoadFailed() throws {
        let provider = ListDataProviderMock()
        provider.result = .failure(.init(code: 404, message: errorText, kind: .networkError))

        listViewModel.listDataProvider = provider
        navigationController?.setViewControllers([listView], animated: false)

        guard let viewModel = listViewModel as? ListViewModel else { return XCTFail("listViewModel is nil") }
        viewModel.url = testUrl
        let promise = expectation(description: "Load finished")

        listViewModel.requestListData {
            promise.fulfill()
        }
        wait(for: [promise], timeout: 10)
        guard let view = self.listView as? ListViewController else {
            return XCTFail("listView is nil")
        }
        XCTAssertTrue(viewModel.model.isEmpty)
        guard let alert = view.presentedViewController as? UIAlertController else {
            return XCTFail("No view is presented")
        }
        XCTAssertEqual(alert.message, errorText)
        expectToEventually(view.progressView.isHidden, timeout: 2)
    }

    func test_ListViewModel_ProgressShown() throws {
        let provider = ListDataProviderMock()
        provider.result = .success(testData)
        listViewModel.listDataProvider = provider
        navigationController?.setViewControllers([listView], animated: false)
        guard let viewModel = listViewModel as? ListViewModel else { return XCTFail() }
        viewModel.url = testUrl
        listViewModel.requestListData(completion: nil)
        guard let view = self.listView as? ListViewController else {
            return XCTFail("listView is nil")
        }
        XCTAssertFalse(view.progressView.isHidden)
    }
}

extension XCTest {
    func expectToEventually(_ isFulfilled: @autoclosure () -> Bool, timeout: TimeInterval) {
        let timeout = Date(timeIntervalSinceNow: timeout)

        func wait() {
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.01))
        }

        func isTimeout() -> Bool {
            Date() >= timeout
        }

        repeat {
            if isFulfilled() { return }
            wait()
        } while !isTimeout()

        XCTFail("Failed by timeout")
    }
}
