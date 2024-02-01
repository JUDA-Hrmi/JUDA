//
//  ContentView.swift
//  FinalHrmiProjects
//
//  Created by 홍세희 on 2024/01/22.
//

import SwiftUI

struct ContentView: View {
	@State var isReportPresented = false
	@State var isLike = false
	@State var likeCount = 45
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
<<<<<<< HEAD
//        RootView()
        NavigationStack {
            NavigationLink("d") { AddTagView() }
        }
=======
        Content2View()
>>>>>>> de2f959 ([Feat] 바인딩 변수끼리 연결 #35)
    }
}

#Preview {
    ContentView()
}
