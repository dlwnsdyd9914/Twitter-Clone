//
//  ProfileFilterView.swift
//  Twitters
//
//  Created by 이준용 on 2/26/25.
//

import UIKit
import Then

protocol ProfileFilterViewDelegate: AnyObject {
    func filterView(view: ProfileFilterView, indexPath: Int)
    func filterView(view: ProfileFilterView, didSelect filter: FilterOption)
}

class ProfileFilterView: UIView {

     private lazy var collectionView: UICollectionView = {
         let layout = UICollectionViewFlowLayout()

         layout.minimumLineSpacing = 0          // 셀 간 간격 제거
         layout.minimumInteritemSpacing = 0

         let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

         return collectionView
    }()




    private let underLineView = UIView().then {
        $0.backgroundColor = .twitterBlue
    }

    var viewModel = ProfileFilterViewModel()

    weak var delegate: ProfileFilterViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .red
        configureCollectionView()


    }

    required init?(coder: NSCoder) {
        fatalError("")
    }
    override func layoutSubviews() {
        super.layoutSubviews()

        addSubview(underLineView)
        underLineView.anchor(top: nil, leading: leadingAnchor, trailing: nil, bottom: bottomAnchor, paddingTop: 0, paddingLeading: 0, paddingTrailing: 0, paddingBottom: 0, width: frame.width / 3, height: 2, centerX: nil, centerY: nil)

        let selectedIndexPath = IndexPath(row: 0, section: 0)
        DispatchQueue.main.async {
            self.collectionView.selectItem(at: selectedIndexPath, animated: false, scrollPosition: .left)
            self.collectionView.delegate?.collectionView?(self.collectionView, didSelectItemAt: selectedIndexPath)
        }
    }




    private func configureCollectionView() {
        self.addSubview(collectionView)

        collectionView.anchor(top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor, paddingTop: 0, paddingLeading: 0, paddingTrailing: 0, paddingBottom: 0, width: 0, height: 0, centerX: nil, centerY: nil)
        collectionView.backgroundColor = .white

        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.register(ProfileFilterCell.self, forCellWithReuseIdentifier: Cell.profileFilterCell)


    }

}

extension ProfileFilterView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.filterOptions.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.profileFilterCell, for: indexPath) as? ProfileFilterCell else {
            return UICollectionViewCell()
        }
        let filterOption = viewModel.filterOptions[indexPath.item]
        let isSelected = (indexPath.item == viewModel.selectedIndex)
        cell.viewModel = ProfileFilterItemViewModel(filterOption: filterOption, isSelected: isSelected)
        return cell
    }
}

extension ProfileFilterView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.selectedIndex = indexPath.item  // ✅ 인덱스만 갱신
            delegate?.filterView(view: self, didSelect: viewModel.filterOptions[indexPath.item])

            UIView.animate(withDuration: 0.3) {
                self.underLineView.frame.origin.x = collectionView.cellForItem(at: indexPath)?.frame.origin.x ?? 0
            }

            collectionView.reloadData() // ✅ 셀 상태 반영은 여기서 깔끔하게

//        let selectedOption = viewModel.filterOptions[indexPath.item]
//        let cell = collectionView.cellForItem(at: indexPath)
//        let xPosition = cell?.frame.origin.x ?? 0
//
//        UIView.animate(withDuration: 0.3) {
//            self.underLineView.frame.origin.x = xPosition
//        }
//        delegate?.filterView(view: self, didSelect: selectedOption)
//
//        print("🟢 [DEBUG] 선택된 필터 IndexPath: \(indexPath.item)")
//
//        // ✅ 기존 선택된 모든 필터의 상태를 false로 변경
//        for cell in collectionView.visibleCells {
//            if let filterCell = cell as? ProfileFilterCell {
//                filterCell.viewModel?.updateSelectionStatus(isSelected: false)
//                print("🔴 [DEBUG] 필터 해제 - \(filterCell.viewModel?.selectedFilterOption.description ?? "알 수 없음")")
//            }
//        }
//
//        // ✅ 새로 선택된 셀의 상태를 true로 변경
//        if let selectedCell = collectionView.cellForItem(at: indexPath) as? ProfileFilterCell {
//            selectedCell.viewModel?.updateSelectionStatus(isSelected: true)
//            print("🟢 [DEBUG] 필터 선택 - \(selectedCell.viewModel?.selectedFilterOption.description ?? "알 수 없음")")
//        }
    }
}





extension ProfileFilterView: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 3, height: collectionView.frame.height)
    }

}
