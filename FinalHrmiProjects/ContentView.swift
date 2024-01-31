//
//  ContentView.swift
//  FinalHrmiProjects
//
//  Created by 홍세희 on 2024/01/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
//        VStack {
//            Image(systemName: "globe")
//                .imageScale(.large)
//                .foregroundStyle(.tint)
//            Text("안녕하세요")
//                .font(.thin20)
//                .foregroundStyle(Color.mainAccent01)
//            Text("안녕하세요")
//                .font(.system(size: 20))
//        }
//        .padding()
//        RootView()
        NavigationStack {
            NavigationLink("WritingView") { WritingView() }
        }

    }
}

#Preview {
    ContentView()
}
