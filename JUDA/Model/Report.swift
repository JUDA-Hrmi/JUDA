//
//  Report.swift
//  JUDA
//
//  Created by Minjae Kim on 2/26/24.
//

import Foundation

struct Report {
	let reportedPost: Post
	let reportedUser: User
	let reportField: ReportField
}

struct ReportField: Codable {
	let reportedContents: [String]
	let reportedEtcContent: String
	let reportedTime: Date
}
