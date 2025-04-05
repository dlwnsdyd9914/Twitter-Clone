//
//  CustomAlertController.swift
//  Twitters
//
//  Created by 이준용 on 3/27/25.
//

import UIKit
import SwiftUI
import Then

/// 트위터 스타일 하단에서 올라오는 커스텀 액션 시트 (알럿) 컨트롤러
final class CustomAlertController: UIViewController {

    /// 하단에 올라올 콘텐츠 뷰 (여기선 UITableView 사용)
    private let tableView = UITableView()

    private var tableViewHeight: CGFloat {
        let rowHeight: CGFloat = 60
        let cancelButtonHeight: CGFloat = 60
        let spacing: CGFloat = 20 // 여유 여백

        return CGFloat(viewModel.options.count) * rowHeight + cancelButtonHeight + spacing
    }


    /// 현재 사용하는 UIWindow를 참조할 수 있도록 잡아둠 (선택사항, 지금은 사용 X)
    private var window: UIWindow?

    private let viewModel: ActionSheetViewModel

    /// 화면 전체를 덮는 반투명 배경 뷰 (터치 시 dismiss 용도)
    private lazy var blackView = UIView().then {
        $0.alpha = 0 // 시작은 투명하게 (페이드 인 효과용)
        $0.backgroundColor = UIColor(white: 0, alpha: 0.4) // 검정색 반투명 배경
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleDismissal))
        $0.addGestureRecognizer(tap) // 탭하면 ㅂ닫히도록
    }

    private lazy var cancleButton = UIButton(type: .custom).then {
        $0.setTitle("Cancle", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 18)
        $0.setTitleColor(.black, for: .normal)
        $0.backgroundColor = .systemGroupedBackground
        $0.addTarget(self, action: #selector(handleDismissal), for: .touchUpInside)
    }

    private lazy var footerView = UIView().then {
        $0.addSubview(cancleButton)
        cancleButton.anchor(top: nil, leading: $0.leadingAnchor, trailing: $0.trailingAnchor, bottom: nil, paddingTop: 0, paddingLeading: 12, paddingTrailing: 12, paddingBottom: 0, width: 0, height: 50, centerX: nil, centerY: $0.centerYAnchor)
    }

    // MARK: - Life Cycle

    init(viewModel: ActionSheetViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        configureTableView()
        bindViewModel()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // 등장 애니메이션: 배경은 점점 어두워지고, 테이블은 위로 올라옴
        UIView.animate(withDuration: 0.5) {
            self.tableView.transform = .identity // 원래 자리로 이동 (아래서 위로 올라옴)
            self.blackView.alpha = 1 // 배경 뷰 페이드 인
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cancleButton.clipsToBounds = true
        cancleButton.layer.cornerRadius = cancleButton.frame.height / 2
    }

    // MARK: - Actions

    @objc private func handleDismissal() {
        UIView.animate(withDuration: 0.3, animations: {
            self.tableView.transform = CGAffineTransform(translationX: 0, y: self.tableViewHeight)
            self.blackView.alpha = 0
        }) { _ in
            self.dismiss(animated: false)
        }
    }


    // MARK: - Setup

    /// 초기 설정 (배경 투명으로 설정)
    private func setup() {
        view.backgroundColor = .clear
    }

    /// 테이블뷰 및 블랙 배경 구성 + 초기 transform 설정
    private func configureTableView() {
        // 배경 뷰 먼저 추가 (뒤에 깔리게)
        view.addSubview(blackView)
        blackView.frame = view.frame // 화면 전체를 덮게 설정

        // 테이블 뷰 추가 (알럿처럼 보이는 영역)
        view.addSubview(tableView)



        // 오토레이아웃 설정: 하단에 고정, 높이 300
        tableView.anchor(
            top: nil,
            leading: view.leadingAnchor,
            trailing: view.trailingAnchor,
            bottom: view.bottomAnchor,
            paddingTop: 0,
            paddingLeading: 0,
            paddingTrailing: 0,
            paddingBottom: 0,
            width: 0,
            height: tableViewHeight,
            centerX: nil,
            centerY: nil
        )

        // 테이블뷰 속성 설정
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .white // 테스트용 색상
        tableView.rowHeight = 60
        tableView.layer.cornerRadius = 5
        tableView.clipsToBounds = true
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none


        // 셀 등록
        tableView.register(CustomAlertCell.self, forCellReuseIdentifier: Cell.customAlertCell)

        // 🎯 시작 위치 설정: 화면 아래로 숨겨놓음 (올라올 준비)
        tableView.transform = CGAffineTransform(translationX: 0, y: tableViewHeight)

        // 배경도 투명하게 시작
        self.blackView.alpha = 0
    }

    private func bindViewModel() {
        viewModel.onHandleAction = { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension CustomAlertController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.options.count // 임시: 알럿 항목 수
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 커스텀 셀로 캐스팅해서 재사용
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: Cell.customAlertCell,
            for: indexPath
        ) as? CustomAlertCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        let option = viewModel.options[indexPath.row]
        cell.configure(with: option)

        return cell

    }
}

// MARK: - UITableViewDelegate
extension CustomAlertController: UITableViewDelegate {
    // 필요시 셀 선택 이벤트 처리 가능

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return footerView
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let option = viewModel.options[indexPath.row]


        print("DEBUG: Selected option is \(option.description)")


        switch option {
        case .follow, .unfollow:
            viewModel.handleFollowAction()
            dismiss()
        case .report:
            print("DEBUG: Selected option is Report")
            dismiss()
        case .delete:
            break
        }

    }

    private func dismiss() {
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            guard let self else { return }
            self.blackView.alpha = 0
            self.tableView.transform = CGAffineTransform(translationX: 0, y: self.tableViewHeight)
        }, completion: { [weak self] _ in
            self?.dismiss(animated: true)
        })
    }
}

// MARK: - SwiftUI Preview 지원
#Preview {

    let actionSheetViewModel = ActionSheetViewModel(userviewModel: UserViewModel(user: MockUserModel(didFollow: true)))

    VCPreView {
        CustomAlertController(viewModel: actionSheetViewModel)
    }
    .edgesIgnoringSafeArea(.all)
}
