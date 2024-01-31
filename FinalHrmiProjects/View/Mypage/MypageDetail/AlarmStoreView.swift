//
//  AlarmStoreView.swift
//  FinalHrmiProjects
//
//  Created by phang on 1/31/24.
//

import SwiftUI

// UITest - 알림 내역 리스트
struct Alarm: Identifiable, Hashable {
    let id = UUID()
    let likedUserName: String
    let postImageName: String
    let likedTime: Date
    
    static func randomDate() -> Date {
        let randomTimeInterval = Double.random(in: -500 * 24 * 60 * 60 ... 0)
        return Date().addingTimeInterval(randomTimeInterval)
    }

    static let alarmList: [Alarm] = [
        .init(likedUserName: "phang", postImageName: "foodEx3", likedTime: randomDate()),
        .init(likedUserName: "mangJae", postImageName: "foodEx2", likedTime: randomDate()),
        .init(likedUserName: "SayHong", postImageName: "foodEx4", likedTime: randomDate()),
        .init(likedUserName: "withSeon", postImageName: "foodEx1", likedTime: randomDate()),
        .init(likedUserName: "DevLarva", postImageName: "foodEx2", likedTime: randomDate()),
        .init(likedUserName: "내가아이디가좀길어", postImageName: "foodEx1", likedTime: randomDate()),
        .init(likedUserName: "withSeon", postImageName: "foodEx3", likedTime: randomDate()),
        .init(likedUserName: "DevLarva", postImageName: "foodEx3", likedTime: randomDate()),
        .init(likedUserName: "withSeon", postImageName: "foodEx5", likedTime: randomDate()),
        .init(likedUserName: "SayHong", postImageName: "foodEx5", likedTime: randomDate()),
        .init(likedUserName: "phang", postImageName: "foodEx2", likedTime: randomDate()),
        .init(likedUserName: "mangJae", postImageName: "foodEx4", likedTime: randomDate()),
        .init(likedUserName: "phang", postImageName: "foodEx4", likedTime: randomDate()),
        .init(likedUserName: "내가아이디가좀길어ㅋ", postImageName: "foodEx4", likedTime: randomDate()),
    ]
}

struct AlarmStoreView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // TODO: CustomScrollView 로 수정 예정
            ScrollView {
                ForEach(0..<Alarm.alarmList.count, id: \.self) { index in
                    NavigationLink {
                        // TODO: 해당 게시글로 이동
                    } label: {
                        AlarmStoreListCell(alarm: Alarm.alarmList[index])
                    }

                    if index != Alarm.alarmList.count - 1 {
                        CustomDivider()
                    }
                }
            }
            .scrollIndicators(.hidden)
            .padding(.top, 10)
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    // TODO: 뒤로가기
                    dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                }
                .tint(.mainBlack)
            }
            ToolbarItem(placement: .principal) {
                Text("알림")
                    .font(.medium18)
                    .foregroundStyle(.mainBlack)
            }
        }
    }
}

#Preview {
    AlarmStoreView()
}
