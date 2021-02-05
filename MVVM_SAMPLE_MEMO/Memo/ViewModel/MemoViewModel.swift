//
//  MemoViewModel.swift
//  MVVM_SAMPLE_MEMO
//
//  Created by 60067671 on 2021/01/27.
//

import UIKit
import CoreData

protocol MemoViewModelProtocol {
	var memoContent: String! { get }
	var memoContentDidChange: ((MemoViewModelProtocol) -> ())? { get set }
	func refreshMemoView()
}

class MemoViewModel: MemoViewModelProtocol {
	var memoModel: MemoModel
	var memoContentDidChange: ((MemoViewModelProtocol) -> ())?
	var index: Int
	var memoContent: String! {
		didSet {
			self.memoContentDidChange?(self)
		}
	}

	init(index: Int, memoModel: MemoModel) {
		self.index = index
		self.memoModel = memoModel
	}

	func refreshMemoView() {
		memoContent = memoModel.content
	}

	func memoContentInsert(content: String) {
		let title = content.split(separator: "\n", maxSplits: 1).map(String.init)
		if title.count == 0 { return }
		memoModel.homeTitle = title[0]
		memoModel.homeContent = (title.count > 1) ? title[1] : "추가 텍스트 없음"
		memoModel.content = content
		memoModel.date = Date()
		insertInCoreData(memoModel: memoModel)
	}

	func memoContentUpdate(content: String) {
		let title = content.split(separator: "\n", maxSplits: 1).map(String.init)
		if title.count == 0 { return }
		memoModel.homeTitle = title[0]
		memoModel.homeContent = (title.count > 1) ? title[1] : "추가 텍스트 없음"
		memoModel.content = content
		memoModel.date = Date()
		updateInCoreData(memoModel: memoModel)
	}

	func memoContentDelete() {
		deleteCoreData(memoModel: memoModel)
	}

	private func insertInCoreData(memoModel: MemoModel) {
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let context = appDelegate.persistentContainer.viewContext
		let entity = NSEntityDescription.entity(forEntityName: "MemoEntity", in: context)

		let content = NSManagedObject(entity: entity!, insertInto: context)
		content.setValue(memoModel.content, forKey: "content")
		content.setValue(memoModel.homeTitle, forKey: "homeTitle")
		content.setValue(memoModel.homeContent, forKey: "homeContent")
		content.setValue(memoModel.date, forKey: "date")

		saveContext(context)
	}

	private func updateInCoreData(memoModel: MemoModel) {
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let context = appDelegate.persistentContainer.viewContext
		let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "MemoEntity")
		fetchRequest.predicate = NSPredicate(format: "date = %@", memoModel.date as CVarArg)

		do {
			let results = try context.fetch(fetchRequest) as? [MemoEntity]
			if results?.count != 0 {
				results?[0].setValue(memoModel.content, forKey: "content")
				results?[0].setValue(memoModel.homeTitle, forKey: "homeTitle")
				results?[0].setValue(memoModel.homeContent, forKey: "homeContent")
				results?[0].setValue(memoModel.date, forKey: "date")
			}
			saveContext(context)
		} catch {
			print(error.localizedDescription)
		}

	}

	private func deleteCoreData(memoModel: MemoModel) {
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let context = appDelegate.persistentContainer.viewContext
		let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "MemoEntity")
		fetchRequest.predicate = NSPredicate(format: "date = %@", memoModel.date as CVarArg)

		do {
			guard let results = try context.fetch(fetchRequest) as? [MemoEntity] else { return }
			if results.count != 0 {
				context.delete(results[0])
			}
			saveContext(context)
		} catch {
			print(error.localizedDescription)
		}
	}

	private func saveContext(_ context: NSManagedObjectContext) {
		do {
			try context.save()
		} catch {
			print(error.localizedDescription)
		}
	}
}
