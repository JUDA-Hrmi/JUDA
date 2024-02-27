//
//  SettingView.swift
//  JUDA
//
//  Created by 홍세희 on 2024/02/01.
//

import SwiftUI
import WebKit

// MARK: - 환경설정 세팅 화면
struct SettingView: View {
    @EnvironmentObject private var navigationRouter: NavigationRouter
    @EnvironmentObject private var authService: AuthService
    @EnvironmentObject private var appViewModel: AppViewModel
    @EnvironmentObject var colorScheme: SystemColorTheme

	private let optionNameList = ["라이트 모드", "다크 모드", "시스템 모드"] // 화면 모드 설정 옵션 이름 리스트
	private let webViewNameList = ["서비스 이용약관", "개인정보 처리방침", "위치정보 처리방침"] // 웹뷰로 보여줘야하는 항목 이름 리스트
	private let webViewurlList = ["https://bit.ly/HrmiService",
                                  "https://bit.ly/HrmiPrivacyPolicy",
                                  "https://bit.ly/HrmiLocationPolicy"] // webViewNameList에 해당하는 url 주소
	    
    @AppStorage("selectedSortingOption") private var selectedSortingOption: String = "시스템 모드"
    @State private var isAlarmOn: Bool = false // 알람 설정 toggle
	@State private var isShowingSheet: Bool = false // CustomBottomSheet 올라오기
	@State private var isLogoutClicked = false // 로그아웃 버튼 클릭 시
	@State private var isDeletAccount = false // 회원탈퇴 버튼 클릭 시
    
    @Binding var selectedTabIndex: Int
	
    var version: String? {
        guard let dictionary = Bundle.main.infoDictionary,
        let version = dictionary["CFBundleShortVersionString"] as? String else {return nil}
        return version //1.0.0
    }

    var build: String? {
        guard let dictionary = Bundle.main.infoDictionary,
        let build = dictionary["CFBundleVersion"] as? String else {return nil}
        return build //1
    }
    
	var body: some View {
		ZStack {
            VStack(alignment: .leading) {
                if authService.signInStatus {
                    // 알림 설정
                    VStack(alignment: .leading, spacing: -10) {
                        Text("JUDA 알림을 켜주세요!")
                            .modifier(CustomText())
                        
                        Text("정보 알림을 받기 위해서 기기 알림을 켜주세요")
                            .font(.light14)
                            .foregroundStyle(.gray01)
                            .padding(.horizontal, 20)
                    }
                    Button {
                        openAppSettings()
                    } label: {
                        Text("기기 알림 켜기")
                            .font(.medium20)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(.mainAccent03)
                            .clipShape(.rect(cornerRadius: 10))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                    }
                    //
                    CustomDivider()
                }

                // 화면 모드 설정
                // 버튼 클릭 시 반짝이는 애니메이션 제거 코드 추가하기
                Button {
                    isShowingSheet.toggle()
                } label: {
                    HStack {
                        Text("화면 모드 설정")
                        Spacer()
                        CustomSortingButton(optionNameList: optionNameList, selectedSortingOption: selectedSortingOption, isShowingSheet: $isShowingSheet)
                        // CustomSortingButton에서 선택한 selectedSortingOption로 화면 색상 설정하기
                        .onChange(of: selectedSortingOption) { _ in
                            switch selectedSortingOption {
                            case "라이트 모드":
                                colorScheme.selectedColor = .light
                            case "다크 모드":
                                colorScheme.selectedColor = .dark
                            case "시스템 모드":
                                colorScheme.selectedColor = nil
                            default:
                                break
                            }
                        }
                    }
                    .modifier(CustomText())
                }
                
                
                if authService.signInStatus {
                    // 로그아웃
                    Button {
                        isLogoutClicked.toggle() // 버튼 클릭 시, 커스텀 다이얼로그 활성화
                    } label: {
                        Text("로그아웃")
                            .font(.regular16)
                            .foregroundStyle(.mainAccent02)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.background)
                    }
                    // 회원탈퇴
                    Button {
                        isDeletAccount.toggle() // 버튼 클릭 시, 커스텀 다이얼로그 활성화
                    } label: {
                        Text("회원탈퇴")
                            .font(.regular16)
                            .foregroundStyle(.mainAccent02)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.background)
                    }
                    //
                    CustomDivider()
                }
                // 공지사항
                NavigationLink(value: Route.Notice) {
                    HStack {
                        Text("공지사항")
                        Spacer()
                        Image(systemName: "chevron.forward")
                    }
                    .modifier(CustomText())
                }
                //
                CustomDivider()
                // 이용약관 및 정보 처리 방침
                ForEach(0..<webViewNameList.count, id: \.self) { index in
                    AppServiceInfoView(text: webViewNameList[index], urlString: webViewurlList[index])
                }
                // 버전 정보
                Text("버전 정보 \(version ?? "1.1.4")")
                    .font(.regular16)
                    .foregroundStyle(.gray01)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                //
                CustomDivider()
                Spacer()
            }
            // 화면 모드 설정 - CustomBottomSheet (.displaySetting)
            .sheet(isPresented: $isShowingSheet) {
                CustomBottomSheetContent(optionNameList: optionNameList,
                                         isShowingSheet: $isShowingSheet,
                                         selectedSortingOption: $selectedSortingOption,
                                         bottomSheetTypeText: BottomSheetType.displaySetting)
                    .presentationDetents([.displaySetting])
                    .presentationDragIndicator(.hidden) // 시트 상단 인디케이터 비활성화
                    .interactiveDismissDisabled() // 내려서 닫기 비활성화
            }
    
            // 로그아웃 - CustomAlert
            if isLogoutClicked {
                CustomDialog(type: .twoButton(
                    message: "로그아웃 하시겠습니까?",
                    leftButtonLabel: "취소",
                    leftButtonAction: {
                        isLogoutClicked.toggle()
                    },
                    rightButtonLabel: "로그아웃",
                    rightButtonAction: {
                        // 로그아웃 - AppStorage 에서 변경
                        authService.signOut()
                        isLogoutClicked.toggle()
                        // MainView 로 보내기
                        selectedTabIndex = 0
                    })
                )
            }
            
            // 회원탈퇴 - CustomAlert
            // TODO: - 탈퇴 문구 수정하기
            if isDeletAccount {
                CustomDialog(type: .twoButton(
                    message: "탈퇴 하시겠습니까?",
                    leftButtonLabel: "취소",
                    leftButtonAction: {
                        isDeletAccount.toggle()
                    },
                    rightButtonLabel: "탈퇴하기",
                    rightButtonAction: {
                        Task {
                            authService.isLoading = true
                            if await authService.deleteAccount() {
                                authService.isLoading = false
                                isDeletAccount.toggle()
                                navigationRouter.back()
                                // 메인 화면으로 이동
                                selectedTabIndex = 0
                            }
                        }
                    })
                )
            }
		}
//        .onDisappear {
//            navigationRouter.back()
//        }
        // 회원탈퇴 시, 생기는 로딩
        .loadingView($authService.isLoading)
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
				Text("설정")
					.font(.medium16)
					.foregroundStyle(.mainBlack)
			}
        }
        
    }
    
    // '기기 설정 - 주다' 페이지 이동
    func openAppSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsURL) {
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
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

