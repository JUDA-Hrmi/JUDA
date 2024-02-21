//
//  AlarmStoreView.swift
//  JUDA
//
//  Created by phang on 1/31/24.
//

import SwiftUI
import FirebaseAuth

// MARK: - 알람 쌓여있는 리스트 화면
struct AlarmStoreView: View {
    let userId = Auth.auth().currentUser?.uid ?? ""

    @Environment(\.dismiss) private var dismiss
    @StateObject var notifications = Alarms.shared

    var body: some View {
        VStack(spacing: 0) {
            // 알람 리스트
            // MARK: iOS 16.4 이상
            if #available(iOS 16.4, *) {
                ScrollView() {
                    AlarmListContent(notifications: notifications)
                }
                .scrollBounceBehavior(.basedOnSize, axes: .vertical)
            // MARK: iOS 16.4 미만
            } else {
                ViewThatFits(in: .vertical) {
                    AlarmListContent(notifications: notifications)
                        .frame(maxHeight: .infinity, alignment: .top)
                    ScrollView {
                        AlarmListContent(notifications: notifications)
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
                    .font(.medium16)
                    .foregroundStyle(.mainBlack)
            }
        }
        .task {
            await notifications.fetchNotificationForUser(userId: userId)
        }
    }
}

// MARK: - 스크롤 뷰 or 뷰 로 보여질 알람 리스트
struct AlarmListContent: View {
    @StateObject var notifications: Alarms

    var body: some View {
        LazyVStack {
            ForEach(notifications.alarms, id: \.self) { alarm in
                // TODO: NavigationLink - value 로 수정
                NavigationLink(destination: PostDetailView(postUserType: .writter, nickName: "Hrmi", isLike: .constant(false), likeCount: .constant(45))) {
                    AlarmStoreListCell(alarm: alarm)
                }

                if alarm != notifications.alarms.last {
                    CustomDivider()
                }
            }
        }
    }
}

