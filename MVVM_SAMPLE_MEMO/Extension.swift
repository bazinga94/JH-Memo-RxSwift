//
//  Extension.swift
//  MVVM_SAMPLE_MEMO
//
//  Created by 60067671 on 2021/01/26.
//

import UIKit

extension NSObject {
	//	var className: String {
	//		return String(describing: type(of: self))
	//	}
	class var className: String {
		return String(describing: self)
	}
}

extension UITableView {
	func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T {
		guard let cell = self.dequeueReusableCell(withIdentifier: T.className, for: indexPath) as? T else {
			fatalError("Disable Dequeue Reusable Cell")
		}
		return cell
	}
}

extension UIView {
	/**
	UIView Round 처리
	- Parameter corners: UIRectCorner : [.topRight, .topLeft, .bottomLeft, .bottomRight]
	- Parameter radius: radius 값
	- Returns: rounding 처리 된 UIView
	*/
	func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
		var cornerMask = CACornerMask()
		if(corners.contains(.topLeft)) {
			cornerMask.insert(.layerMinXMinYCorner)
		}
		if(corners.contains(.topRight)) {
			cornerMask.insert(.layerMaxXMinYCorner)
		}
		if(corners.contains(.bottomLeft)) {
			cornerMask.insert(.layerMinXMaxYCorner)
		}
		if(corners.contains(.bottomRight)) {
			cornerMask.insert(.layerMaxXMaxYCorner)
		}
		self.layer.cornerRadius = radius
		self.layer.maskedCorners = cornerMask
	}
}

let koreaDateFormat: DateFormatter = {
	let df = DateFormatter()
	df.locale = Locale(identifier: "ko_KR")
	df.timeZone = TimeZone(abbreviation: "KST")
	return df
}()

extension Date {
	func dateToString(_ format: String = "yyyy.MM.dd") -> String {
		let dateFormatter = koreaDateFormat
		dateFormatter.dateFormat = format
		return dateFormatter.string(from: self)
	}
}
