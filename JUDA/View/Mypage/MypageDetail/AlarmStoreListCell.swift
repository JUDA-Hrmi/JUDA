//
//  AlarmStoreListCell.swift
//  FinalHrmiProjects
//
//  Created by phang on 1/31/24.
//

import SwiftUI

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
                .multilineTextAlignment(.leading)
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
