//
//  LikedPostGrid.swift
//  FinalHrmiProjects
//
//  Created by phang on 1/26/24.
//

import SwiftUI

struct LikedPostGrid: View {
    // 현재 유저가 해당 술 상을 좋아요 눌렀는지 bool
    @State private var isLikePost = true
    // 게시물
    @State private var postLikeCount = 45
    
    var body: some View {
        Text("Post")
    }
}

#Preview {
    LikedPostGrid()
}
