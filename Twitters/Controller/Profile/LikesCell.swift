import UIKit

class LikesCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .twitterBlue
        let label = UILabel()
        label.text = "Likes"
        label.textAlignment = .center
        label.frame = bounds
        addSubview(label)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
