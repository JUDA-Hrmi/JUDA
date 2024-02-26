//
//  Report.swift
//  JUDA
//
//  Created by Minjae Kim on 2/26/24.
//

import Foundation

struct Report: Codable {
	let postID: String
	let contents: [String]
	let etcReportText: String
	let reportedUserID: String
	let reportedTime: Date
}
