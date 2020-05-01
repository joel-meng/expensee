//
//  Reader.swift
//  GithubUsers
//
//  Created by Joel Meng on 10/26/19.
//  Copyright © 2019 Joel Meng. All rights reserved.
//

import Foundation

struct Reader<A, B> {

	var f: (A) -> B

	init(_ f: @escaping (A) -> B) {
		self.f = f
	}

	func apply(from: A) -> B {
		return f(from)
	}

	func map<C>(_ f: @escaping (B) -> C) -> Reader<A, C> {
		return Reader<A, C> { from in
			f(self.f(from))
		}
	}

	func flatMap<C>(_ f: @escaping (B) -> Reader<A, C>) -> Reader<A, C> {
		return Reader<A, C> { from in
			f(self.f(from)).f(from)
		}
	}
}

infix operator >>= : RunesMonadicPrecedenceLeft

precedencegroup RunesMonadicPrecedenceLeft {
	associativity: left
	lowerThan: LogicalDisjunctionPrecedence
	higherThan: AssignmentPrecedence
}

func >>=<E, A, B>(a: Reader<E, A>, f: @escaping (A) -> B) -> Reader<E, B> {
	return a.map(f)
}
