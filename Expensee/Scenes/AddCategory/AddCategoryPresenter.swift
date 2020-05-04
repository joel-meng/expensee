//
//  AddCategoryPresenter.swift
//  Expensee
//
//  Created by Jun Meng on 1/5/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import Foundation

protocol AddCategoryPresenting: class {

    func displayColors(colors: [ColorCellModel])

    func setSaveButtonEnable(_ enabled: Bool)
    
    func displayCategory(name: String, monthlyBudget: (Double, String)?)

    func displayError(_ message: String)
}

protocol AddCategoryControlling: class {

    func viewIsReady()

    func didSelectMonthlyLimit(_ limit: Double?)

    func didSelectMonthlyLimitCurrency(_ currency: String?)

    func didSelectCategoryName(_ name: String?)

    func didSelectCategoryColor(_ color: String?)

    func didTapSave()
}

final class AddCategoryPresenter {

    private weak var view: AddCategoryPresenting?

    private let interactor: AddCategoryInteracting

    private let router: AddCategoriesRouting

    private let flavor: SceneFlavor

    private var monthlyLimit: MonthlyLimit? {
        didSet { update(category: category, limit: monthlyLimit) }
    }

    private var category: Category? {
        didSet { update(category: category, limit: monthlyLimit) }
    }

    init(view: AddCategoryPresenting,
         interactor: AddCategoryInteracting,
         router: AddCategoriesRouting,
         category: Category?,
         monthlyLimit: MonthlyLimit?) {
        self.category = category
        self.monthlyLimit = monthlyLimit
        self.flavor = category == nil ? .save : .update
        self.view = view
        self.interactor = interactor
        self.router = router
    }

    private func update(category: Category?, limit: MonthlyLimit?) {
        print(category, limit)
        view?.setSaveButtonEnable(isValid(category: category, limit: limit))
    }

    private func isValid(category: Category?, limit: MonthlyLimit?) -> Bool {
        guard category?.name != nil, category?.color != nil else { return false }
        if (limit?.limit != nil && limit?.currency != nil) ||
            (limit?.limit == nil && limit?.currency == nil) {
            return true
        }
        return false
    }

    struct MonthlyLimit {
        let limit: Double?
        let currency: String?
    }

    struct Category {
        let id: UUID?
        let name: String?
        let color: String?
    }
}

extension AddCategoryPresenter: AddCategoryControlling {

    func viewIsReady() {
        if let name = category?.name {
            if let budget = monthlyLimit?.limit, let currency = monthlyLimit?.currency {
                view?.displayCategory(name: name, monthlyBudget: (budget, currency) )
            } else {
                view?.displayCategory(name: name, monthlyBudget: nil)
            }
        }
        view?.displayColors(colors: colorsCellModels(withSelection: category?.color))
        view?.setSaveButtonEnable(false)
    }

    func didSelectMonthlyLimit(_ limit: Double?) {
        self.monthlyLimit = MonthlyLimit(limit: limit,
                                         currency: limit == nil ? nil : monthlyLimit?.currency)
    }

    func didSelectMonthlyLimitCurrency(_ currency: String?) {
        guard monthlyLimit?.limit != nil else { return }
        self.monthlyLimit = MonthlyLimit(limit: monthlyLimit?.limit, currency: currency)
    }

    func didSelectCategoryName(_ name: String?) {
        category = Category(id: category?.id, name: name, color: category?.color)
    }

    func didSelectCategoryColor(_ color: String?) {
        category = Category(id: category?.id, name: category?.name, color: color)
        let cellModel = colorsCellModels(withSelection: color)
        view?.displayColors(colors: cellModel)
    }

    func didTapSave() {
        switch flavor {
        case .save:
            saveCategory()
        case .update:
            updateCategory()
        }
    }

    func saveCategory() {
        guard let name = category?.name, let color = category?.color else {
            view?.displayError("Oops, must have category name and color")
            return
        }

        let monthlyLimit = self.monthlyLimit.flatMap { monthlyLimit -> SaveCategoryRequest.MontlyLimit? in
            guard let limit = monthlyLimit.limit else { return nil }
            return SaveCategoryRequest.MontlyLimit(limitAmount: limit, limitCurrency: monthlyLimit.currency ?? "NZD")
        }

        let category = SaveCategoryRequest.Category(name: name, color: color, monthlyLimit: monthlyLimit)
        let savedFuture = interactor.saveCategory(request: SaveCategoryRequest(category: category))
        savedFuture.on(success: { [weak router] (response) in
            router?.routeBackAndRefresh()
        }, failure: { error in
            print(error)
        })
    }

    func updateCategory() {
        guard let name = category?.name, let color = category?.color else {
            view?.displayError("Oops, must have category name and color.")
            return
        }

        guard let id = category?.id else {
            view?.displayError("Oops, something went wrong.")
            return
        }

        let monthlyLimit = self.monthlyLimit.flatMap { monthlyLimit -> UpdateCategoryRequest.MontlyLimit? in
            guard let limit = monthlyLimit.limit else { return nil }
            return UpdateCategoryRequest.MontlyLimit(limitAmount: limit, limitCurrency: monthlyLimit.currency ?? "NZD")
        }

        let category = UpdateCategoryRequest.Category(id: id, name: name, color: color, monthlyLimit: monthlyLimit)
        interactor.updateCategory(request:UpdateCategoryRequest(category:category)).on(success: { [weak router] (response) in
            router?.routeBackAndRefresh()
        }, failure: { error in
            print(error)
        })
    }

    // MARK: - Color Cells

    private func colorsCellModels(withSelection selection: String?) -> [ColorCellModel] {
        let categoriesColor = interactor.listColors(request: ListColorsRequest())
        return categoriesColor.colors.map {
            ColorCellModel(color: $0.color, isChecked: selection != nil ? selection == $0.color : false)
        }
    }

    // MARK: - Flavor

    enum SceneFlavor {
        case save
        case update
    }
}
