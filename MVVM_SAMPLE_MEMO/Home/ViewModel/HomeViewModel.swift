//
//  HomeViewModel.swift
//  MVVM_SAMPLE_MEMO
//
//  Created by 60067671 on 2021/01/26.
//

import UIKit

// YG 참고!
protocol ViewModel {
	associatedtype Model
	var model: Model { get set }
	init(model: Model)
	/// Data 갱신 처리 ( bind한 view에게 알림 )
	func configureOutput()
}

protocol HomeViewModelProtocol {
	var title: String! { get }
	var memoList: [MemoModel]! { get }
	var titleDidChange: ((HomeViewModelProtocol) -> ())? { get set }
	var memoListDidChange: ((HomeViewModelProtocol) -> ())? { get set }
	func refresHomeView()
	func memoDidSelect(for index: Int) -> MemoViewModel
}

class HomeViewModel: NSObject, HomeViewModelProtocol {
	var homeModel: HomeModel!
	var titleDidChange: ((HomeViewModelProtocol) -> ())?
	var memoListDidChange: ((HomeViewModelProtocol) -> ())?
	var title: String! {
		didSet {
			self.titleDidChange?(self)
		}
	}
	var memoList: [MemoModel]! {
		didSet {
			self.memoListDidChange?(self)
		}
	}

	override init() {
		super.init()
		self.homeModel = HomeModel.init(navigationTitle: "MVVM 메모앱", memoModelList: fetchFromCoreData())
	}

	func refresHomeView() {
		title = homeModel.navigationTitle
		memoList = homeModel.memoModelList
	}

	func memoDidSelect(for index: Int) -> MemoViewModel {
		return MemoViewModel(index: index, memoModel: memoList[index])
	}

	func memoListUpdate(memoViewModel: MemoViewModel) {
		if memoList.count > 0, memoViewModel.index != -1 {
			memoList.remove(at: memoViewModel.index)
		}
		memoList.insert(memoViewModel.memoModel, at: 0)
	}

	private func fetchFromCoreData() -> [MemoModel] {
		var memoModelList: [MemoModel] = []
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let context = appDelegate.persistentContainer.viewContext
		do {
			let memoEntityList = try context.fetch(MemoEntity.fetchRequest()) as! [MemoEntity]
			memoEntityList.forEach { (entity) in
				memoModelList.append(MemoModel(homeTitle: entity.homeTitle!, homeContent: entity.homeContent!, content: entity.content!, date: entity.date!))
			}
			return memoModelList
		} catch {
			print(error.localizedDescription)
			return []
		}
	}
}

extension HomeViewModel: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return memoList.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell: HomeTableViewCell = tableView.dequeueReusableCell(for: indexPath)
		cell.titleLabel.text = memoList[indexPath.row].homeTitle
		cell.contentLabel.text = memoList[indexPath.row].homeContent
		cell.dateLabel.text = memoList[indexPath.row].date.dateToString("yyyy.MM.dd HH:mm:ss")
		return cell
	}
}
