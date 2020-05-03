//
//  StubCurrencyLayerService.swift
//  Expensee
//
//  Created by Jun Meng on 4/5/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import Foundation

final class StubCurrencyLayerService: CurrencyLayerServiceProtocol {

    let queryDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        return dateFormatter
    }()

    private func parametrizeDate(_ date: Date) -> String {
        return queryDateFormatter.string(from: date)
    }

    func historyUSDQuotes(convertionRequest: CurrencyConvertionRequestDTO) -> Future<CurrencyConvertionResponseDTO> {
        let future = Future<CurrencyConvertionResponseDTO>()

        DispatchQueue.global(qos: .background).async {
            let response = CurrencyConvertionResponseDTO(fromCurrency: "USD",
                                                         toCurrency: "NZD",
                                                         date: Date(),
                                                         fromCurrencyAmount: 1, toCurrencyAmount: 1.6)
            future.resolve(with: response)
        }

        return future
    }
}
