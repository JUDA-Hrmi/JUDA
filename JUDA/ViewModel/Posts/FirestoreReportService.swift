//
//  FirestoreReportService.swift
//  JUDA
//
//  Created by phang on 3/9/24.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

@MainActor
final class FirestoreReportService {
    private let db = Firestore.firestore()
    private let reportCollection = "reports"
    private let postCollection = "posts"
    
    // 신고 올리기
    func uploadReport(report: Report) async throws {
        let reportDocumentID = UUID().uuidString
        let reportRef = db.collection(reportCollection)
        try reportRef.document(reportDocumentID)
            .setData(from: report)
    }
}
