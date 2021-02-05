//
//  ViewController.swift
//  MVVM_SAMPLE_MEMO
//
//  Created by 60067671 on 2021/01/26.
//

import UIKit
import CoreData
import RxSwift
import RxCocoa

class HomeViewController: UIViewController {
	@IBOutlet weak var tableView: UITableView!
	@IBAction func newMemoButtonAction(_ sender: Any) {
		let storyBoard: UIStoryboard! = UIStoryboard(name: "Memo", bundle: nil)
		if let viewController = storyBoard.instantiateViewController(withIdentifier: "MemoViewController") as? MemoViewController {
			viewController.viewModel = MemoViewModel(index: -1, memoModel: MemoModel(homeTitle: "", homeContent: "", content: "", date: Date()))
			self.navigationController?.pushViewController(viewController, animated: true)
		}
	}

	var viewModel: HomeViewModel? {
		didSet {
			viewModel?.titleDidChange = { [weak self] viewModel in
				self?.navigationItem.title = viewModel.title
			}
//			viewModel?.memoListDidChange = { [weak self] viewModel in
//				self?.tableView.reloadData()
//			}
		}
	}

	private var bag = DisposeBag()

	override func viewDidLoad() {
		super.viewDidLoad()
		initUI()
		initAndBindData()
		self.viewModel?.refresHomeView()
	}

	private func initUI() {
		tableView.roundCorners([.topLeft, .topRight], radius: 10)
	}

	private func initAndBindData() {
		self.viewModel = HomeViewModel.init()
//		tableView.delegate = self
//		tableView.dataSource = viewModel
//		tableView.rx.setDelegate(self)
//			.disposed(by: bag)	// 만약 UITableViewDelegate를 사용하는 경우

		self.viewModel?.homeModelObservable?.bind(to: tableView.rx.items(cellIdentifier: HomeTableViewCell.className, cellType: HomeTableViewCell.self)) { row, element, cell in
			cell.titleLabel.text = element.homeTitle
			cell.contentLabel.text = element.homeContent
			cell.dateLabel.text = element.date.dateToString("yyyy.MM.dd HH:mm:ss")
		}
		.disposed(by: bag)

//		tableView.rx.itemSelected
//			.subscribe(onNext: { [weak self] indexPath in
//				self?.tableView.deselectRow(at: indexPath, animated: true)
//				let storyBoard: UIStoryboard! = UIStoryboard(name: "Memo", bundle: nil)
//				if let viewController = storyBoard.instantiateViewController(withIdentifier: "MemoViewController") as? MemoViewController {
//					viewController.viewModel = self?.viewModel?.memoDidSelect(for: indexPath.row)
//					self?.navigationController?.pushViewController(viewController, animated: true)
//				}
//			})
//			.disposed(by: bag)

		Observable.zip(tableView.rx.modelSelected(MemoModel.self), tableView.rx.itemSelected)
			.bind{ [weak self] (memoModel, indexPath) in
				self?.tableView.deselectRow(at: indexPath, animated: true)
				let storyBoard: UIStoryboard! = UIStoryboard(name: "Memo", bundle: nil)
				if let viewController = storyBoard.instantiateViewController(withIdentifier: "MemoViewController") as? MemoViewController {
					viewController.viewModel = MemoViewModel(index: indexPath.row, memoModel: memoModel)
					self?.navigationController?.pushViewController(viewController, animated: true)
				}
			}
			.disposed(by: bag)
	}
}

//extension HomeViewController: UITableViewDelegate {
//	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//		let storyBoard: UIStoryboard! = UIStoryboard(name: "Memo", bundle: nil)
//		if let viewController = storyBoard.instantiateViewController(withIdentifier: "MemoViewController") as? MemoViewController {
//			viewController.viewModel = self.viewModel?.memoDidSelect(for: indexPath.row)
//			self.navigationController?.pushViewController(viewController, animated: true)
//		}
//	}
//}
