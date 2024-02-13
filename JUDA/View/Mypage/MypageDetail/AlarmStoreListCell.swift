//
//  AlarmStoreListCell.swift
//  JUDA
//
//  Created by phang on 1/31/24.
//

import SwiftUI

// MARK: - 알람 리스트 셀
struct AlarmStoreListCell: View {
    let alarm: Alarm
    
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                // 게사물 좋아요 알람 내용
                Group {
                    Text(alarm.likedUserName)
                        .font(.medium14)
                    +
                    Text(" 님이 게시물에 하트를 남겼어요.")
                        .font(.regular14)
                }
                .multilineTextAlignment(.leading)
                .foregroundStyle(.mainBlack)
                .overlay(alignment: .topLeading) {
                    // TODO: NavigationLink - value 로 수정
                    NavigationLink {
                        NavigationProfileView(likeCount: 44, userType: .otheruser, userName: alarm.likedUserName)
                            .modifier(TabBarHidden())
                    } label: {
                        Text(alarm.likedUserName)
                            .font(.medium14)
                            .foregroundStyle(.mainBlack)
                    }
                    .buttonStyle(EmptyActionStyle())
                }
                // 알람 왔던 시기
                Text(Formatter.formattedDateBeforeStyle(pastDate: alarm.likedTime))
                    .font(.regular12)
                    .foregroundStyle(.gray01)
            }
            Spacer()
            // 해당 술상 이미지
            Image(alarm.postImageName)
                .resizable()
                .aspectRatio(1.0, contentMode: .fill)
                .frame(maxWidth: 60, maxHeight: 60)
                .clipShape(.rect(cornerRadius: 5))
        }
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity, maxHeight: 80, alignment: .leading)
        .padding(.horizontal, 20)
    }
}

#Preview {
    AlarmStoreListCell(alarm: Alarm(likedUserName: "내가아이디가좀길어ㅋ", postImageName: "foodEx1", likedTime: Alarm.randomDate()))
}
