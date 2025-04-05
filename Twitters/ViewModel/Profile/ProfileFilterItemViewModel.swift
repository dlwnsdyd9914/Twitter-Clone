//
//  ProfileFilterItemViewModel.swift
//  Twitters
//
//  Created by 이준용 on 4/3/25.
//

import Foundation
class ProfileFilterItemViewModel {
    var isSelected: Bool {
        didSet {
            onFilterStatus?(isSelected)
        }
    }

    let selectedFilterOption: FilterOption
    var onFilterStatus: ((Bool) -> Void)?

    init(filterOption: FilterOption, isSelected: Bool) {
        self.selectedFilterOption = filterOption
        self.isSelected = isSelected
    }

    func updateSelectionStatus(isSelected: Bool) {
        self.isSelected = isSelected
    }
}
