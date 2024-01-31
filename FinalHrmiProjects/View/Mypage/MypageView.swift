//
//  MypageView.swift
//  FinalHrmiProjects
//
//  Created by 홍세희 on 2024/01/24.
//

import SwiftUI

struct MypageView: View {
    var body: some View {
//        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        NavigationStack {
            NavigationLink {
                AlarmStoreView()
            } label: {
                Text("이동")
            }
        }
    }
}

#Preview {
    MypageView()
}
