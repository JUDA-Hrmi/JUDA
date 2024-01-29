//
//  SettingView.swift
//  FinalHrmiProjects
//
//  Created by 홍세희 on 2024/01/29.
//

import SwiftUI
import WebKit

struct SettingView: View {
    private let optionNameList = ["라이트 모드", "다크 모드", "시스템 모드"]
    private let urlStringList = [
        "https://glacier-coneflower-d58.notion.site/2003b94d70cc46ca95fe76266a30df09?pvs=4",
        "https://glacier-coneflower-d58.notion.site/2003b94d70cc46ca95fe76266a30df09?pvs=4",
        "https://glacier-coneflower-d58.notion.site/25acb23600d24ec3b3146115f98d2dad?pvs=4"
    ]
    
    @State private var isShowingSheet: Bool = false
    @State private var selectedSortingOption: String = "시스템 모드"
    @State private var headText = "화면 모드 선택"
    
    @State private var isLogoutClicked = false // 로그아웃 버튼 클릭 시
    @State private var isDeletAccount = false // 회원탈퇴 버튼 클릭 시
    
    @State private var isShowServiceWebView = false // 서비스 이용약관 보여주기
    @State private var isShowPrivacyWebView = false // 개인 정보 처리 방침 보여주기
    @State private var isShowLocationWebView = false // 위치 정보 처리방침 보여주기
    
    var body: some View {
        NavigationStack {
            ZStack {
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
                    // TODO: CustomBottomSheet로 바꾸기
                    // 버튼 클릭 시 반짝이는 애니메이션 제거 코드 추가하기
                    Button(action: {
                        isShowingSheet.toggle()
                    }, label: {
                        HStack {
                            Text("화면 모드 설정")
                            Spacer()
                            CustomSortingButton(optionNameList: optionNameList, selectedSortingOption: $selectedSortingOption, isShowingSheet: $isShowingSheet, isShowSymbolImage: .constant(false), buttonColor: .constant(.gray01))
                                .buttonStyle(EmptyActionStyle())
                        }
                        .modifier(CustomText())
                    })
                    // MARK: 로그아웃
                    Button(action: {
                        isLogoutClicked.toggle() // 버튼 클릭 시, 커스텀 다이얼로그 활성화
                    }, label: {
                        Text("로그아웃")
                            .foregroundStyle(.mainAccent02)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                    })
                    
                    // MARK: 회원탈퇴
                    Button(action: {
                        isDeletAccount.toggle() // 버튼 클릭 시, 커스텀 다이얼로그 활성화
                    }, label: {
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
                    
                    // MARK: 메일 문의하기
                    NavigationLink {
                        EmailContactView()
                    } label: {
                        HStack {
                            Text("메일 문의하기")
                            Spacer()
                            Image(systemName: "chevron.forward")
                        }
                        .modifier(CustomText())
                    }
                    
                    CustomDivider()
                    
                    // MARK: 서비스 이용약관
                    Button {
                        isShowServiceWebView.toggle()
                    } label: {
                        HStack {
                            Text("서비스 이용약관")
                            Spacer()
                            Image(systemName: "chevron.forward")
                        }
                        .modifier(CustomText())
                        .sheet(isPresented: $isShowServiceWebView) {
                            SettingWKWebView(url: urlStringList[0])
                        }
                    }
                    
                    // MARK: 개인정보 처리방침
                    Button {
                        isShowPrivacyWebView.toggle()
                    } label: {
                        HStack {
                            Text("개인정보 처리방침")
                            Spacer()
                            Image(systemName: "chevron.forward")
                        }
                        .modifier(CustomText())
                        .sheet(isPresented: $isShowPrivacyWebView) {
                            SettingWKWebView(url: urlStringList[1])
                        }
                    }
                    
                    // MARK: 위치정보 처리방침
                    Button {
                        isShowLocationWebView.toggle()
                    } label: {
                        HStack {
                            Text("위치정보 처리방침")
                            Spacer()
                            Image(systemName: "chevron.forward")
                        }
                        .modifier(CustomText())
                        .sheet(isPresented: $isShowLocationWebView) {
                            SettingWKWebView(url: urlStringList[2])
                        }
                    }
        
                    // MARK: 버전 정보
                    Text("버전 정보 0.0.1")
                        .font(.regular16)
                        .foregroundStyle(.gray01)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                    
                    CustomDivider()
                }
                // 화면 모드 설정 클릭 시 띄워지는 CustomBottomSheetView
                EnabledBottomSheetView(optionNameList: optionNameList, selectedSortingOption: $selectedSortingOption, isShowingSheet: $isShowingSheet, headText: $headText)
                
                // 로그아웃 버튼 클릭 시 띄워지는 CustomAlert
                if isLogoutClicked {
                    CustomAlert(message: "로그아웃 하시겠습니까?", leftButtonLabel: "취소", leftButtonAction: {
                        isLogoutClicked.toggle()
                    }, rightButtonLabel: "로그아웃", rightButtonAction: {}) // TODO: 로그아웃 기능 추가하기
                }
                
                // 회원탈퇴 버튼 클릭 시 띄워지는 CustomAlert
                if isDeletAccount {
                    CustomAlert(message: "계정을 삭제하시겠습니까?", leftButtonLabel: "취소", leftButtonAction: {
                        isDeletAccount.toggle()
                    }, rightButtonLabel: "탈퇴하기", rightButtonAction: {}) // TODO: 회원탈퇴 기능 추가하기
                }
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
