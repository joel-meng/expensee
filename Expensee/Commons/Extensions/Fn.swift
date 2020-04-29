//
//  Fn.swift
//  CPixels
//
//  Created by Joel Meng on 8/4/19.
//  Copyright © 2019 Joel Meng. All rights reserved.
//

import Foundation

/// An helper function that helps to dispatch a code block to UI thread.
///
/// - Parameters:
///   - weaker: `Any` type thingy(including function) to be *weakly* retained and passing to the 2nd parameter
///				`updatingUI`.
///   - updatingUI: A code block that would run on UI thread with parameter `weaker` that passed in from 1st parameter.
func updaterUI<X>(weaker: X?, _ updatingUI: @escaping (X) -> Void) {
	guard let weaker = weaker else { return }
	DispatchQueue.main.async {
		updatingUI(weaker)
	}
}
