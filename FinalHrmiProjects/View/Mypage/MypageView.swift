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
            NavigationLink(value: "") {
                Text("이동")
            }
            .navigationDestination(for: String.self) { _ in
                AlarmStoreView()
            }
        }
    }
}

#Preview {
    MypageView()
}
