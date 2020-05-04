//
//  AtomicTestCase.swift
//  ExpenseeTests
//
//  Created by Jun Meng on 4/5/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import XCTest
@testable import Expensee

class AtomicTests: XCTestCase {

    override func setUp() {}

    override func tearDown() {}

    // MARK: - Initialization
    func testInitiliazing() {
        let atomic = Atomic<Int>(10)
        XCTAssertEqual(atomic.value, 10)
    }

    // MARK: - Preformance Tests
    func testAtomicWrite() {
        let atomic = Atomic<Int>(0)

        self.measure {
            atomic.value { $0 = 0}

            DispatchQueue.concurrentPerform(iterations: 100_000) { _ in
                atomic.value { $0 += 1; return }
            }
        }

        XCTAssertEqual(atomic.value, 100_000)
    }

    func testAtomicAccationalReading() {
        let atomic = Atomic<Int>(0)

        self.measure {
            atomic.value { $0 = 0}

            DispatchQueue.concurrentPerform(iterations: 100_000) { it in
                XCTAssertGreaterThanOrEqual(atomic.value, 0)
                if it.isMultiple(of: 100) {
                    atomic.value { $0 += 1 }
                }
            }
        }

        XCTAssertEqual(atomic.value, 1_000)
    }

    func testAtomicIntensiveWritingWithReading() {
        let atomic = Atomic<Int>(0)

        self.measure {
            atomic.value { $0 = 0}

            DispatchQueue.concurrentPerform(iterations: 100_000) { it in
                XCTAssertGreaterThanOrEqual(atomic.value, 0)
                if it.isMultiple(of: 10) {
                    atomic.value { $0 += 1 }
                }
            }
        }

        XCTAssertEqual(atomic.value, 10_000)
    }
}
