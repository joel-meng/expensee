//
//  LaunchPresenter.swift
//  SpaceXSpace
//
//  Created by Joel Meng on 12/4/19.
//  Copyright © 2019 Joel Meng. All rights reserved.
//

import Foundation

protocol LaunchPreseting {

//    func didLoadView() -> Future<[LaunchCellModel]>
//
//    func didSelect(_ launch: LaunchCellModel) -> Future<LaunchSceneModel>
}

final class LaunchPresenter: LaunchPreseting {

//    var interactor: LaunchInteracting
//
//    private var future: Future<[LaunchDTO]>?
//
//    init(interactor: LaunchInteracting) {
//        self.interactor = interactor
//    }
//
//    // MARK: - Presenting
//
//    func didLoadView() -> Future<[LaunchCellModel]> {
//        interactor.loadLaunches().map { dtos -> [LaunchCellModel] in
//            dtos.map { dto -> LaunchCellModel in
//                LaunchCellModel(missionName: dto.missionName,
//                                site: dto.site,
//                                time: dto.launchDateLocal,
//                                year: dto.launchYear,
//                                success: dto.isSuccess,
//                                flightNumber: dto.flightNumber,
//                                rocketID: dto.rocket.id)
//            }
//        }
//    }
//
//    func didSelect(_ launch: LaunchCellModel) -> Future<LaunchSceneModel> {
//        let future = Future<LaunchSceneModel>()
//        defer {
//            future.resolve(with: LaunchSceneModel(flightNumber: launch.flightNumber, rocketID: launch.rocketID))
//        }
//        return future
//    }
}
