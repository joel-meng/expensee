//
//  FutureTestCase.swift
//  ExpenseeTests
//
//  Created by Jun Meng on 4/5/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import XCTest
@testable import Expensee

class FutureTests: XCTestCase {

    override func setUp() {
    }

    override func tearDown() {
    }

    // MARK: - Testing initial value
    func testFutureWithInitialValue() {
        let futureUT = Future<Int>(0)
        expect("Success should be called", { (expectation) in
            futureUT.onSuccess { (futureValue) in
                XCTAssert(futureValue == 0)
                expectation.fulfill()
            }
        })
    }

    func testFutureWithInitialError() {
        let error = NSError(domain: "", code: 0, userInfo: nil)
        let futureUT = Future<Int>(error: error)
        expect("Success should be called", { (expectation) in
            futureUT.on(success: { _ in
                XCTFail("Success should not be called.")
            }, failure: { error in
                expectation.fulfill()
                XCTAssertTrue((error as NSError).code == 0)
            })
        })
    }

    // MARK: - Resovled and Rejected
    func testFutureResolvedWithValue() {
        let futureUT = Future<Int>()
        expect("Success should be called", { (expectation) in
            futureUT.onSuccess { (futureValue) in
                expectation.fulfill()
                XCTAssert(futureValue == 2)
            }
            futureUT.resolve(with: 2)
        })
    }

    func testFutureRejectedWithError() {
        let futureUT = Future<Int>()
        let stubError = NSError(domain: "", code: 1, userInfo: nil)
        expect("Rejection should be called", { (expectation) in
            futureUT.on(success: { _ in
                XCTFail("Should never been called")
            }, failure: { error in
                expectation.fulfill()
                XCTAssertNotNil(error as NSError)
            })
            futureUT.reject(with: stubError)
        })

    }

    // MARK: - Mapping
    func testFutureResolvedMappingWithValue() {
        let initialFuture = Future<Int>()
        let futureUT = initialFuture.map { $0 * 2 }.map {  $0 * 2 }
        expect("Success should be called", { (expectation) in
            futureUT.onSuccess { (futureValue) in
                expectation.fulfill()
                XCTAssert(futureValue == 8)
            }
            initialFuture.resolve(with: 2)
        })
    }

    func testFutureResolvedMappingWithDifferentTypeValue() {
        let initialFuture = Future<Int>()
        let futureUT = initialFuture.map { "\($0)" }
        expect("Success should be called", { (expectation) in
            futureUT.onSuccess { (futureValue) in
                expectation.fulfill()
                XCTAssertEqual(futureValue, "2")
            }
            initialFuture.resolve(with: 2)
        })
    }

    func testFutureResolvedMappingWithError() {
        let stubError = NSError(domain: "", code: 1, userInfo: nil)
        let initialFuture = Future<Int>()
        let futureUT = initialFuture.map { $0 * 2 }
        expect("Success should be called", { (expectation) in
            futureUT.on(success: { _ in
                XCTFail("Should never be called.")
            }, failure: { error in
                expectation.fulfill()
                XCTAssertEqual((error as NSError).code, 1)
            })
            initialFuture.reject(with: stubError)
        })
    }

    // MARK: - Concurrency
    func testFutureWithConcurrencySuccess() {
        let futureUT = Future<Int>()
        expect("Future notifies success 100_000 times", { expectation in
            futureUT.on(success: { (newValue) in
                XCTAssertGreaterThanOrEqual(newValue, 0)
                expectation.fulfill()
            },
            failure: { _ in
                XCTFail("Should Never GET ERROR")
            })
            DispatchQueue.concurrentPerform(iterations: 100_000) {
                futureUT.resolve(with: $0)
            }
        }, within: 4, fulfillmentCount: 100_000)
    }

    func testFutureWithConcurrencyFailure() {
        let futureUT = Future<Int>()
        let stubError = NSError(domain: "", code: 1, userInfo: nil)

        expect("Future notifies failure 100_000 times", { expectation in
            futureUT.on(success: { _ in
                XCTFail("Should Never GET ERROR")
            },
            failure: { _ in
                expectation.fulfill()
            })
            DispatchQueue.concurrentPerform(iterations: 100_000) { _ in
                futureUT.reject(with: stubError)
            }
        }, within: 4, fulfillmentCount: 100_000)
    }

    func testFutureWithConcurrencySuccessAndFailure() {
        let futureUT = Future<Int>()
        let stubError = NSError(domain: "", code: 1, userInfo: nil)

        expect("Future notifies success and failure 100_000 times", { expectation in
            futureUT.on(success: { _ in
                expectation.fulfill()
            },
            failure: { _ in
                expectation.fulfill()
            })
            DispatchQueue.concurrentPerform(iterations: 100_000) {
                if $0.isMultiple(of: 2) {
                    futureUT.reject(with: stubError)
                }
                else {
                    futureUT.resolve(with: $0)
                }
            }
        }, within: 4, fulfillmentCount: 100_000)
    }

    func testFutureWithConcurrencySuccessAndFailureWithMapping() {
        let initialFuture = Future<Int>()
        let futureUT = initialFuture.map {
            $0 * 2
        }
        let stubError = NSError(domain: "", code: 1, userInfo: nil)

        expect("Future notifies success and failure 100_000 times", { expectation in
            futureUT.on(success: { _ in
                expectation.fulfill()
            },
            failure: { _ in
                expectation.fulfill()
            })
            DispatchQueue.concurrentPerform(iterations: 100) {
                if $0.isMultiple(of: 2) {
                    initialFuture.reject(with: stubError)
                }
                else {
                    initialFuture.resolve(with: $0)
                }
            }
        }, within: 4, fulfillmentCount: 100)
    }

}

extension XCTestCase {

    func expect(_ _expectation: String, _ willHappen: (XCTestExpectation) -> Void, within time: TimeInterval = 0.3, fulfillmentCount: Int = 1) {
        let exp = expectation(description: _expectation)
        exp.expectedFulfillmentCount = fulfillmentCount
        willHappen(exp)
        waitForExpectations(timeout: time) { (error) in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func expectNotHappen(_ _expectation: String, _ willNotHappen: (XCTestExpectation) -> Void, within time: TimeInterval = 0.5) {
        let exp = expectation(description: _expectation)
        exp.isInverted = true
        willNotHappen(exp)
        waitForExpectations(timeout: time) { (error) in
            XCTAssertNil(error)
        }
    }
}
