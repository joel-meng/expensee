/*
MIT License

Copyright (c) 2019 Daylight

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

import Foundation

/// A value type that wrappes a `Value` in atomic updating who would get updated in multiple thread.
final class Atomic<Value> {

	/// Thread safe wrapped value
	private var _value: Value

	/// An internal `Concurrent` dispatch queue that to access the value.
	private let mutex = DispatchQueue(label: "Atomic Concurrent Queue - Daylight/joel-meng/com.github",
									  attributes: .concurrent)

	// MARK: - Lifecycle

	init(_ value: Value) {
		self._value = value
	}

	// MARK: - Accessors

	/// A getter for accessing the value.
	var value: Value {
		mutex.sync {
			_value
		}
	}

	/// A mutating setter function for value which keeps value updating `Thread-Safe`
	/// - Parameter transform: An closure which used to update the actual value in a atomic transaction.
	func value<T>(_ transform: (inout Value) throws -> T) rethrows -> T {
		try mutex.sync(flags: .barrier) {
			try transform(&_value)
		}
	}
}
