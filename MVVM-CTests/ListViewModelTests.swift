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
    
    private let testArray = ["1", "2"]
    private let testString = "1\n2"
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
            return XCTFail()
        }
        listViewModel.model = testArray
        XCTAssertEqual(listViewModel.numberOfRows, testArray.count)
    }
    
    func test_ListViewModel_TextForRow() throws {
        guard let listViewModel = self.listViewModel as? ListViewModel else {
            return XCTFail()
        }
        listViewModel.model = testArray
        XCTAssertEqual(listViewModel.textForRow(at: 0), testArray.first)
    }
    
    func test_ListViewModel_LoadSuccessful() throws {
       
        let provider = ListDataProviderMock()
        provider.result = .success(testData)
        
        listViewModel.listDataProvider = provider
        navigationController?.setViewControllers([listView], animated: false)
        
        guard let viewModel = listViewModel as? ListViewModel else { return XCTFail() }
        viewModel.url = testUrl
        let promise = expectation(description: "Load finished")
        
        listViewModel.requestListData { [weak self] in
            let view = self?.listView as? ListViewController
            XCTAssertTrue(view?.progressView.isHidden ?? false)
            promise.fulfill()
        }
        wait(for: [promise], timeout: 10)
        
        guard let view = self.listView as? ListViewController else {
            return XCTFail()
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
        
        guard let viewModel = listViewModel as? ListViewModel else { return XCTFail() }
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
        
        guard let viewModel = listViewModel as? ListViewModel else { return XCTFail() }
        viewModel.url = testUrl
        let promise = expectation(description: "Load finished")
        
        listViewModel.requestListData {
            promise.fulfill()
        }
        wait(for: [promise], timeout: 10)
        guard let view = self.listView as? ListViewController else {
            return XCTFail()
        }
        XCTAssertTrue(viewModel.model.isEmpty)
        guard let alert = view.presentedViewController as? UIAlertController else {
            return XCTFail()
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
            return XCTFail()
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
        
        XCTFail()
    }
}
