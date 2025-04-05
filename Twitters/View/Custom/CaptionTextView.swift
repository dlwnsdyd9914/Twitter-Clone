import UIKit
import Then

class CaptionTextView: UITextView, UITextViewDelegate {

    let placeholderLabel = UILabel().then {
        $0.text = "What's happening?"
        $0.font = .systemFont(ofSize: 16)
        $0.textColor = .lightGray
    }

    let charCountLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 12)
        $0.textColor = .gray
        $0.textAlignment = .right
    }

    let minHeight: CGFloat = 50
    let maxHeight: CGFloat = 250
    let maxCharacters: Int = 200  // ✅ 최대 글자 수 제한

    private lazy var heightConstraint = heightAnchor.constraint(equalToConstant: minHeight)

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        delegate = self
        configureUI()
        setup()
        configureConstraints()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTextInputChange),
            name: UITextView.textDidChangeNotification,
            object: self
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func handleTextInputChange() {
        placeholderLabel.isHidden = !self.text.isEmpty
        charCountLabel.text = "\(self.text.count)/\(maxCharacters)"  // ✅ 글자 수 카운터 표시
        updateHeight()
    }

    private func configureUI() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .white
        font = .systemFont(ofSize: 16)
        isScrollEnabled = false
        textContainer.lineBreakMode = .byWordWrapping
        textContainer.widthTracksTextView = true

        heightConstraint.isActive = true
    }

    private func setup() {
        [placeholderLabel, charCountLabel].forEach { addSubview($0) }
    }

    private func configureConstraints() {
        placeholderLabelConstraints()
        charCountLabelConstraints()
    }

    private func placeholderLabelConstraints() {
        placeholderLabel.anchor(top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: nil, paddingTop: 4, paddingLeading: 4, paddingTrailing: 4, paddingBottom: 0, width: 0, height: 0, centerX: nil, centerY: nil)
    }

    private func charCountLabelConstraints() {
        charCountLabel.anchor(top: nil, leading: nil, trailing: trailingAnchor, bottom: bottomAnchor, paddingTop: 0, paddingLeading: 0, paddingTrailing: 8, paddingBottom: 4, width: 0, height: 0, centerX: nil, centerY: nil)

    }

    private func updateHeight() {
        let size = CGSize(width: frame.width, height: .infinity)
        let estimatedSize = sizeThatFits(size)

        let newHeight = min(max(minHeight, estimatedSize.height), maxHeight)
        heightConstraint.constant = newHeight
    }

    // ✅ 글자 수 제한 로직
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }

        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)

        return updatedText.count <= maxCharacters
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
