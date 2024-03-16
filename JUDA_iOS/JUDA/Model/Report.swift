//
//  Report.swift
//  JUDA
//
//  Created by Minjae Kim on 2/26/24.
//

import Foundation

struct Report: Codable {
	let reportedPostID: String
	let reportedUserID: String
    let reportedContents: [String]
    let reportedEtcContent: String
    let reportedTime: Date
}
