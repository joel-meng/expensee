//
//  TransactionInteractorTestCase.swift
//  ExpenseeTests
//
//  Created by Jun Meng on 4/5/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import XCTest
@testable import Expensee

class TransactionInteractorTestCase: XCTestCase {

    func testSaveUSD_AmountConvertedToNZD() {
        class StubCurrencyConvertingUseCase: CurrencyConvertingUseCaseProtocol {

            let mockUSD2NZDQuote: Double

            init(mockUSD2NZDQuote: Double) {
                self.mockUSD2NZDQuote = mockUSD2NZDQuote
            }

            func convertCurrency(with request: ConvertCurrencyUseCaseRequest) -> Future<ConvertCurrencyUseCaseResponse> {
                let future = Future<ConvertCurrencyUseCaseResponse>()
                future.resolve(with: ConvertCurrencyUseCaseResponse(convertionResult:
                    ConvertCurrencyUseCaseResponse
                        .CurrencyConvertionDTO(fromCurrency: request.convertion.fromCurrency,
                                               toCurrency: request.convertion.toCurrency,
                                               date: request.convertion.date,
                                               fromCurrencyAmount: request.convertion.fromCurrencyAmount,
                                               toCurrencyAmount: mockUSD2NZDQuote)))
                return future
            }
        }

        class StubSaveTransactionUseCase: SaveTransactionUseCaseProtocol {

            func saveTransaction(with request: SaveTransactionUseCaseRequest) -> Future<SaveTransactionUseCaseResponse> {
                let future = Future<SaveTransactionUseCaseResponse>()
                let response = SaveTransactionUseCaseResponse(transaction:
                    TransactionDTO(amount: request.transaction.amount,
                                   date: request.transaction.date,
                                   currency: request.transaction.currency,
                                   uid: request.transaction.uid,
                                   originalAmount: request.transaction.originalAmount,
                                   originalCurrency: request.transaction.originalCurrency),
                                               category: CategoryDTO(name: "name",
                                                                     color: "#ffffff",
                                                                     budget: nil,
                                                                     uid: UUID()))
                future.resolve(with: response)
                return future
            }

            func updateTransaction(with request: UpdateTransactionUseCaseRequest) -> Future<UpdateTransactionUseCaseResponse> {
                XCTFail()
                return Future<UpdateTransactionUseCaseResponse>()
            }
        }

        let mockUSD2NZDQuote = 1.65
        let interactor = TransactionInteractor(currencyConversionUseCase: StubCurrencyConvertingUseCase(mockUSD2NZDQuote: mockUSD2NZDQuote),
                                               saveTransactionUseCase: StubSaveTransactionUseCase())

        expect("Success should be called", { (expectation) in
            let transactionDate = Date()
            let saveFuture = interactor.saveTransaction(with:
                SaveTransactionRequest(transaction:
                    SaveTransactionRequest.Transaction(amount: 10,
                                                       date: transactionDate,
                                                       currency: "USD"),
                                       categoryId: UUID()))
            saveFuture.onSuccess { (response) in
                XCTAssertEqual(response.transaction.currency, "NZD", "Saved USD must be converted to NZD and saved.")
                XCTAssertEqual(response.transaction.originalCurrency, "USD", "Original currency will be save as `originalCurrency`")
                XCTAssertEqual(response.transaction.amount, response.transaction.originalAmount * mockUSD2NZDQuote ,
                               "Saving USD amount must be converted to NZD and saved.")
                XCTAssertEqual(response.transaction.originalAmount, 10, "Original amount will be save as `originalAmount`")
                XCTAssertEqual(response.transaction.date, transactionDate, "Transaction date should not intact")
                expectation.fulfill()
            }
        })
    }

    func testSaveNZD_AmountDoesNOTConvert() {
        class StubCurrencyConvertingUseCase: CurrencyConvertingUseCaseProtocol {

            let mockUSD2NZDQuote: Double

            init(mockUSD2NZDQuote: Double) {
                self.mockUSD2NZDQuote = mockUSD2NZDQuote
            }

            func convertCurrency(with request: ConvertCurrencyUseCaseRequest) -> Future<ConvertCurrencyUseCaseResponse> {
                let future = Future<ConvertCurrencyUseCaseResponse>()
                future.resolve(with: ConvertCurrencyUseCaseResponse(convertionResult:
                    ConvertCurrencyUseCaseResponse
                        .CurrencyConvertionDTO(fromCurrency: request.convertion.fromCurrency,
                                               toCurrency: request.convertion.toCurrency,
                                               date: request.convertion.date,
                                               fromCurrencyAmount: request.convertion.fromCurrencyAmount,
                                               toCurrencyAmount: mockUSD2NZDQuote)))
                return future
            }
        }

        class StubSaveTransactionUseCase: SaveTransactionUseCaseProtocol {

            func saveTransaction(with request: SaveTransactionUseCaseRequest) -> Future<SaveTransactionUseCaseResponse> {
                let future = Future<SaveTransactionUseCaseResponse>()
                let response = SaveTransactionUseCaseResponse(transaction:
                    TransactionDTO(amount: request.transaction.amount,
                                   date: request.transaction.date,
                                   currency: request.transaction.currency,
                                   uid: request.transaction.uid,
                                   originalAmount: request.transaction.originalAmount,
                                   originalCurrency: request.transaction.originalCurrency),
                                                              category: CategoryDTO(name: "name",
                                                                                    color: "#ffffff",
                                                                                    budget: nil,
                                                                                    uid: request.categoryId))
                future.resolve(with: response)
                return future
            }

            func updateTransaction(with request: UpdateTransactionUseCaseRequest) -> Future<UpdateTransactionUseCaseResponse> {
                XCTFail()
                return Future<UpdateTransactionUseCaseResponse>()
            }
        }

        let mockUSD2NZDQuote = 1.65
        let interactor = TransactionInteractor(
            currencyConversionUseCase: StubCurrencyConvertingUseCase(mockUSD2NZDQuote: mockUSD2NZDQuote),
            saveTransactionUseCase: StubSaveTransactionUseCase())

        expect("Success should be called", { (expectation) in
            let transactionDate = Date()
            let saveFuture = interactor.saveTransaction(with:
                SaveTransactionRequest(transaction:
                    SaveTransactionRequest.Transaction(amount: 10,
                                                       date: transactionDate,
                                                       currency: "NZD"),
                                       categoryId: UUID()))
            saveFuture.onSuccess { (response) in
                XCTAssertEqual(response.transaction.currency, "NZD", "Saved NZD straigt away to use case.")
                XCTAssertEqual(response.transaction.originalCurrency, "NZD", "Original currency will be save as `originalCurrency`")
                XCTAssertEqual(response.transaction.amount, 10,
                               "Saving NZD amount DOSE NOT CHANGE and saved.")
                XCTAssertEqual(response.transaction.originalAmount, 10, "Original amount will be save as `originalAmount`")
                XCTAssertEqual(response.transaction.date, transactionDate, "Transaction date should not intact")
                expectation.fulfill()
            }
        })
    }
}
