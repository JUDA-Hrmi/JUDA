//
//  AlarmStoreView.swift
//  FinalHrmiProjects
//
//  Created by phang on 1/30/24.
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
        .init(likedUserName: "내가아이디가좀길어", postImageName: "foodEx4", likedTime: randomDate()),
    ]
}

struct AlarmStoreView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // TODO: CustomScrollView 로 수정 예정
            ScrollView {
                ForEach(0..<Alarm.alarmList.count, id: \.self) { index in
                    AlarmStoreListCell(alarm: Alarm.alarmList[index])
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

struct AlarmStoreListCell: View {
    let alarm: Alarm
    
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Group {
                    Text(alarm.likedUserName)
                        .font(.medium14)
                    +
                    Text(" 님이 게시물에 하트를 남겼어요.")
                        .font(.regular14)
                }
                .foregroundStyle(.mainBlack)
                .overlay(alignment: .topLeading) {
                    NavigationLink {
                        // TODO: 해당 유저 프로필로 이동
                    } label: {
                        Text(alarm.likedUserName)
                            .font(.medium14)
                            .foregroundStyle(.mainBlack)
                    }
                    .buttonStyle(EmptyActionStyle())
                }
                Text(Formatter.formattedDateBeforeStyle(pastDate: alarm.likedTime))
                    .font(.regular12)
                    .foregroundStyle(.gray01)
            }
            Spacer()
            NavigationLink {
                // TODO: 해당 게시글로 이동
            } label: {
                Image(alarm.postImageName)
                    .resizable()
                    .aspectRatio(1.0, contentMode: .fill)
                    .frame(maxWidth: 60, maxHeight: 60)
                    .clipShape(.rect(cornerRadius: 5))
            }
            .buttonStyle(EmptyActionStyle())
        }
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity, maxHeight: 80, alignment: .leading)
        .padding(.horizontal, 20)
    }
}

#Preview {
    AlarmStoreView()
}
