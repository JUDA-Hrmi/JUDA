//
//  AlarmStoreView.swift
//  JUDA
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

// MARK: - 알람 쌓여있는 리스트 화면
struct AlarmStoreView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // 알람 리스트
            // MARK: iOS 16.4 이상
            if #available(iOS 16.4, *) {
                ScrollView() {
                    AlarmListContent()
                }
                .scrollBounceBehavior(.basedOnSize, axes: .vertical)
            // MARK: iOS 16.4 미만
            } else {
                ViewThatFits(in: .vertical) {
                    AlarmListContent()
                        .frame(maxHeight: .infinity, alignment: .top)
                    ScrollView {
                        AlarmListContent()
                    }
                }
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                }
                .tint(.mainBlack)
            }
            ToolbarItem(placement: .principal) {
                Text("알림")
                    .font(.regular16)
                    .foregroundStyle(.mainBlack)
            }
        }
    }
}

// MARK: - 스크롤 뷰 or 뷰 로 보여질 알람 리스트
struct AlarmListContent: View {
    var body: some View {
        LazyVStack {
            ForEach(0..<Alarm.alarmList.count, id: \.self) { index in
                // TODO: NavigationLink - value 로 수정
                NavigationLink {
                    PostDetailView(postUserType: .writter, nickName: "Hrmi", isLike: .constant(false), likeCount: .constant(45))
                } label: {
                    AlarmStoreListCell(alarm: Alarm.alarmList[index])
                }
                
                if index != Alarm.alarmList.count - 1 {
                    CustomDivider()
                }
            }
        }
    }
}

#Preview {
    AlarmStoreView()
}
