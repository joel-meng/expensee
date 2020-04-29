//
//  LaunchService.swift
//  SpaceXSpace
//
//  Created by Joel Meng on 12/4/19.
//  Copyright © 2019 Joel Meng. All rights reserved.
//

import Foundation

protocol LaunchInteracting {

//    func loadLaunches() -> Future<[LaunchDTO]>
}

final class LaunchInteractor: LaunchInteracting {

//    private var launches: [LaunchDTO]?
//
//    func loadLaunches() -> Future<[LaunchDTO]> {
//        if let launches = launches {
//            return Future<[LaunchDTO]>(launches)
//        }
//
//        let resultFuture = Future<[LaunchDTO]>()
//        let launchesFuture = SpaceXService.fetchLaunches()
//        launchesFuture.onSuccess { [unowned self] launches in
//            let validLaunches = launches.compactMap(LaunchDTO.init)
//            self.launches = validLaunches
//            resultFuture.resolve(with: validLaunches)
//        }
//
//        return resultFuture
//    }
}
