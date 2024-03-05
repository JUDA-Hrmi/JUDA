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
    @EnvironmentObject private var navigationRouter: NavigationRouter
    @EnvironmentObject private var notificationViewModel: MyPageViewModel
	@EnvironmentObject private var authService: AuthService

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
                    navigationRouter.back()
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
            await notificationViewModel.fetchNotificationList(userId: authService.currentUser?.userID ?? "")
        }
    }
}

// MARK: - 스크롤 뷰 or 뷰 로 보여질 알람 리스트
struct AlarmListContent: View {
    @EnvironmentObject private var notificationViewModel: MyPageViewModel

    var body: some View {
        LazyVStack {
            ForEach(notificationViewModel.notifications.indices, id: \.self) { index in
                let alarm = notificationViewModel.notifications[index]
                
//                NavigationLink(value: post) {
//                    AlarmStoreListCell(alarm: alarm)
//                }
                AlarmStoreListCell(alarm: alarm)
                if alarm != notificationViewModel.notifications.last {
                    CustomDivider()
                }
            }
        }
    }
}

