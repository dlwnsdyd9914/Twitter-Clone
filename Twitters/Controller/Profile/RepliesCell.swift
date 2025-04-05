import UIKit

class RepliesCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .lightGray
        let label = UILabel()
        label.text = "Replies"
        label.textAlignment = .center
        label.frame = bounds
        addSubview(label)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
