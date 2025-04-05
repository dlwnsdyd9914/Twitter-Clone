//
//  ProfileFilterViewModel.swift
//  Twitters
//
//  Created by 이준용 on 2/26/25.
//

import UIKit
class ProfileFilterViewModel {

    var selectedIndex: Int = 0

    let filterOptions: [FilterOption]

    init(filterOptions: [FilterOption] = FilterOption.allCases, selectedIndex: Int = 0) {
        self.filterOptions = filterOptions
        self.selectedIndex = selectedIndex
    }
}

