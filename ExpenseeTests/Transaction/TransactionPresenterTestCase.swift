//
//  TransactionPresenterTestCase.swift
//  ExpenseeTests
//
//  Created by Jun Meng on 4/5/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import XCTest
@testable import Expensee

class TransactionPresenterTestCase: XCTestCase {

    var shortStyleDateFormatter: DateFormatter!

    override func setUp() {
        shortStyleDateFormatter = DateFormatter()
        shortStyleDateFormatter.timeStyle = .short
        shortStyleDateFormatter.dateStyle = .short
    }

    func testViewInitializeWithNoPassingInTransaction() {
        let stubView = MockTransactionView()
        let stubInteractor = MockTransactionInteractor()
        let presenter = TransactionPresenter(view: stubView,
                                             interactor: stubInteractor,
                                             router: MockRouter(),
                                             transaction: nil,
                                             category: nil)

        stubView.showStateAction = { amount, currency, date, categoryName, categoryColor in
            XCTAssertEqual(amount, nil, "Dont show amount")
            XCTAssertEqual(currency, "NZD", "Default to `NZD`")
            XCTAssertNotNil(date, "Default to use `now`")
            XCTAssertEqual(categoryName, "Select Category", "No Category Selected")
            XCTAssertEqual(categoryColor, "#647687", "Default Button color")
        }
        presenter.viewIsReady()
    }

    func testViewSelectANewDate() {
        let stubView = MockTransactionView()
        let stubInteractor = MockTransactionInteractor()
        let presenter = TransactionPresenter(view: stubView,
                                             interactor: stubInteractor,
                                             router: MockRouter(),
                                             transaction: nil,
                                             category: nil)

        let selectNewDate = Date(timeIntervalSince1970: 10)

        stubView.dateUpdateAction = { [self] text in
            XCTAssertEqual(text, self.shortStyleDateFormatter.string(from: selectNewDate),
                           "displays newly selected date")
        }

        presenter.viewIsReady()
        presenter.didSelectDate(selectNewDate)
    }

    func testViewInputAmountDoesNotSetSaveReady() {
        let stubView = MockTransactionView()
        let stubInteractor = MockTransactionInteractor()
        let presenter = TransactionPresenter(view: stubView,
                                             interactor: stubInteractor,
                                             router: MockRouter(),
                                             transaction: nil,
                                             category: nil)

        presenter.viewIsReady()

        stubView.handleSaveReady = { ready in
            XCTAssertFalse(ready, "Input amount does not enable save button, need to select category")
        }
        presenter.didInputTransactionAmount(200)
    }

    func testViewTapCategoryButton() {
        let stubView = MockTransactionView()
        let stubInteractor = MockTransactionInteractor()
        let router = MockRouter()
        let presenter = TransactionPresenter(view: stubView,
                                             interactor: stubInteractor,
                                             router: router,
                                             transaction: nil,
                                             category: nil)
        var routeToCategoryCalled = false
        presenter.viewIsReady()
        router.routeToCategoryAction = {
            routeToCategoryCalled = true
        }
        presenter.didTapCategory()
        XCTAssertTrue(routeToCategoryCalled)
    }



    class MockTransactionView: TransactionPresenting {

        var showStateAction: ((Double?, String?, String?, String?, String?) -> Void)?

        var dateUpdateAction: ((String) -> Void)?

        var handleSaveReady: ((Bool) -> Void)?

        func showState(amount: Double?, currency: String?, date: String?, categoryName: String?, categoryColor: String?) {
            showStateAction?(amount, currency, date, categoryName, categoryColor)
        }

        func handleSaveReady(_ enabled: Bool) {
            handleSaveReady?(enabled)
        }

        func updateDateButton(with text: String) {
            dateUpdateAction?(text)
        }

        func displayError(_ message: String) {

        }
    }

    class MockTransactionInteractor: TransactionInteracting {
        func saveTransaction(with request: SaveTransactionRequest) -> Future<SaveTransactionResponse> {
            fatalError()
        }

        func updateTransaction(with request: UpdateTransactionRequest) -> Future<UpdateTransactionResponse> {
            fatalError()
        }
    }

    class MockRouter: TransactionRouting {

        var routeToCategoryAction: (() -> Void)?

        func routeBackToTransactionList() {

        }

        func routeToCategoryList(completion: @escaping (TransactionRouterSceneModel) -> Void) {
            routeToCategoryAction?()
        }
    }
}
