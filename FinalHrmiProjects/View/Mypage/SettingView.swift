//
//  SettingView.swift
//  FinalHrmiProjects
//
//  Created by 홍세희 on 2024/01/29.
//

import SwiftUI

struct SettingView: View {
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                // MARK: 알림 설정
                NavigationLink {
                    // TODO: 각 설정사항에 맞게 뷰 생성 후 바꾸기
                    AlarmSettingView()
                } label: {
                    HStack {
                        Text("알림 설정")
                        Spacer()
                        Image(systemName: "chevron.forward")
                    }
                    //TODO: 반복되는 사항 ViewModifier로 하나로 묶기
                    .modifier(CustomText())
                }
                
                // MARK: 화면 모드 설정
                NavigationLink {
                    DisplaySettingView()
                } label: {
                    HStack {
                        Text("화면 모드 설정")
                        Spacer()
                        Image(systemName: "chevron.forward")
                    }
                    .modifier(CustomText())
                }
                
                // MARK: 로그아웃
                Button(action: {}, label: {
                    Text("로그아웃")
                        .foregroundStyle(.mainAccent02)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                })
                
                // MARK: 회원탈퇴
                Button(action: {}, label: {
                    Text("회원탈퇴")
                        .foregroundStyle(.mainAccent02)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                })
                
                CustomDivider()
                
                // MARK: 공지사항
                NavigationLink {
                    NoticeView()
                } label: {
                    HStack {
                        Text("공지사항")
                        Spacer()
                        Image(systemName: "chevron.forward")
                    }
                    .modifier(CustomText())
                    
                }
                
                // MARK: 1:1 문의하기
                NavigationLink {
                    InquiryView()
                } label: {
                    HStack {
                        Text("1:1 문의하기")
                        Spacer()
                        Image(systemName: "chevron.forward")
                    }
                    .modifier(CustomText())
                }
                
                CustomDivider()
                
                // MARK: 서비스 이용약관
                NavigationLink {
                    TermsofServiceView()
                } label: {
                    HStack {
                        Text("서비스 이용약관")
                        Spacer()
                        Image(systemName: "chevron.forward")
                    }
                    .modifier(CustomText())
                }
                
                // MARK: 개인정보 처리방침
                NavigationLink {
                    PrivacyPolicyView()
                } label: {
                    HStack {
                        Text("개인정보 처리방침")
                        Spacer()
                        Image(systemName: "chevron.forward")
                    }
                    .modifier(CustomText())
                }
                
                // MARK: 위치정보 처리방침
                NavigationLink {
                    LocationPolicyView()
                } label: {
                    HStack {
                        Text("위치정보 처리방침")
                        Spacer()
                        Image(systemName: "chevron.forward")
                    }
                    .modifier(CustomText())
                }
    
                // MARK: 버전 정보
                Text("버전 정보 0.0.1")
                    .font(.regular16)
                    .foregroundStyle(.gray01)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                
                CustomDivider()
            }
        }
    }
}

// 반복되는 UI 설정 ViewModifier를 통해 한꺼번에 묶기
struct CustomText: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.regular16)
            .foregroundStyle(.mainBlack)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
    }
}

#Preview {
    SettingView()
}
