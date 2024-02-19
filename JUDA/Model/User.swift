//
//  User.swift
//  JUDA
//
//  Created by phang on 2/15/24.
//

import Foundation

// MARK: - User 모델
struct User: Codable, Hashable {
//  @DocumentID var id: String?
    var name: String
    var age: Int
    var gender: String
    var profileImage: String?
    var notificationAllowed: Bool
}
