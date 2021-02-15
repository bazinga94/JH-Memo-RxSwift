//
//  MemoViewController.swift
//  MVVM_SAMPLE_MEMO
//
//  Created by 60067671 on 2021/01/26.
//

import UIKit
import RxSwift
import RxCocoa

class MemoViewController: UIViewController {
	@IBOutlet weak var memoTextView: UITextView!

	var disposeBag = DisposeBag()
	var viewModel: MemoViewModel? {
		didSet {
			viewModel?.memoContentDidChange = { [weak self] viewModel in
				self?.memoTextView.text = viewModel.memoContent
			}
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		viewModel?.refreshMemoView()
		memoTextView.rx.text
			.subscribe(onNext: { [weak self] str in
				self?.viewModel?.memoContentUpdate(content: str ?? "")
			})
			.disposed(by: disposeBag)		// UI 스레드 작업이 있다면 bind 메소드를 사용(중요)
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		if self.isMovingFromParent, let homeViewController = self.navigationController?.topViewController as? HomeViewController, let viewModel = viewModel {
			(viewModel.index == -1) ? viewModel.memoContentInsert(content: memoTextView.text) : print("ViewModel update by RxSwift")//viewModel.memoContentUpdate(content: memoTextView.text)
			homeViewController.viewModel?.memoListUpdate(memoViewModel: viewModel)
		}
	}
}
