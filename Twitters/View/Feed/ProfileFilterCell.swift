import UIKit
import Then

class ProfileFilterCell: UICollectionViewCell {

    var viewModel: ProfileFilterItemViewModel? {
        didSet {
            configureCell()
        }
    }

    private let titleLabel = UILabel().then {
        $0.textColor = .lightGray
        $0.font = .systemFont(ofSize: 14)
        $0.textAlignment = .center
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        addSubview(titleLabel)
        setupConstraints()
    }

    private func setupConstraints() {
        titleLabel.anchor(top: nil, leading: nil, trailing: nil, bottom: nil, paddingTop: 0, paddingLeading: 0, paddingTrailing: 0, paddingBottom: 0, width: 0, height: 0, centerX: centerXAnchor, centerY: centerYAnchor)
    }

    private func configureCell() {
        guard let viewModel else { return }
        titleLabel.text = viewModel.selectedFilterOption.description
        updateUI()

        // ✅ 뷰모델의 `onFilterStatus`를 통해 UI 업데이트 감지
        viewModel.onFilterStatus = { [weak self] isSelected in
            self?.updateUI()
        }
    }

    private func updateUI() {
        guard let viewModel else { return }
        titleLabel.font = viewModel.isSelected ? UIFont.boldSystemFont(ofSize: 16) : UIFont.systemFont(ofSize: 14)
        titleLabel.textColor = viewModel.isSelected ? UIColor.twitterBlue : .lightGray
    }
}

