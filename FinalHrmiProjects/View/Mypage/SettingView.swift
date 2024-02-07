//
//  SettingView.swift
//  FinalHrmiProjects
//
//  Created by 홍세희 on 2024/02/01.
//

import SwiftUI
import WebKit

struct SettingView: View {
	private let optionNameList = ["라이트 모드", "다크 모드", "시스템 모드"] // 화면 모드 설정 옵션 이름 리스트
	private let webViewNameList = ["서비스 이용약관", "개인정보 처리방침", "위치정보 처리방침"] // 웹뷰로 보여줘야하는 항목 이름 리스트
	private let webViewurlList = [ "https://bit.ly/HrmiService", "https://bit.ly/HrmiPrivacyPolicy", "https://bit.ly/HrmiLocationPolicy"] // webViewNameList에 해당하는 url 주소
	
	@Environment(\.dismiss) private var dismiss
	
	@State private var isAlarmOn: Bool = true // 알람 설정 toggle
	@State private var isShowingSheet: Bool = false // CustomBottomSheet 올라오기
	@State private var selectedSortingOption: String = "시스템 모드"
	@State private var isLogoutClicked = false // 로그아웃 버튼 클릭 시
	@State private var isDeletAccount = false // 회원탈퇴 버튼 클릭 시
	
	var body: some View {
		ZStack {
			VStack(alignment: .leading) {
				// MARK: 알림 설정
				Toggle(isOn: $isAlarmOn) {
					Text("알림 설정: \(String(isAlarmOn) == "true" ? "켜기" : "끄기")")
				}
				.tint(.mainAccent03)
				.modifier(CustomText())
				
				// MARK: 화면 모드 설정
				// 버튼 클릭 시 반짝이는 애니메이션 제거 코드 추가하기
				Button(action: {
					isShowingSheet.toggle()
				}, label: {
					HStack {
						Text("화면 모드 설정")
						Spacer()
						// TODO: SettingView -> develop에 merge 후 커스텀 바텀 시트와 관련된 컴포넌트 수정 예정
						// TODO: 선택 버튼 - gray01로 하기
						// TODO: CustomBottomSheet -> contents 길이에 맞게 가변적으로 변경
						CustomSortingButton(optionNameList: optionNameList, selectedSortingOption: $selectedSortingOption, isShowingSheet: $isShowingSheet)
					}
					.modifier(CustomText())
				})
				
				// MARK: 로그아웃
				Button(action: {
					isLogoutClicked.toggle() // 버튼 클릭 시, 커스텀 다이얼로그 활성화
				}, label: {
					Text("로그아웃")
						.font(.regular16)
						.foregroundStyle(.mainAccent02)
						.padding(.horizontal, 20)
						.padding(.vertical, 10)
				})
				.buttonStyle(EmptyActionStyle())
				
				// MARK: 회원탈퇴
				Button(action: {
					isDeletAccount.toggle() // 버튼 클릭 시, 커스텀 다이얼로그 활성화
				}, label: {
					Text("회원탈퇴")
						.font(.regular16)
						.foregroundStyle(.mainAccent02)
						.padding(.horizontal, 20)
						.padding(.vertical, 10)
				})
				.buttonStyle(EmptyActionStyle())
				
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
				
				CustomDivider()
				
				// MARK: 이용약관 및 정보 처리 방침
				ForEach(0..<webViewNameList.count, id: \.self) { index in
					AppServiceInfoView(text: webViewNameList[index], urlString: webViewurlList[index])
				}
				
				// MARK: 버전 정보
				Text("버전 정보 0.0.1")
					.font(.regular16)
					.foregroundStyle(.gray01)
					.padding(.horizontal, 20)
					.padding(.vertical, 10)
				
				CustomDivider()
				Spacer()
			}
			// 화면 모드 설정 클릭 시 띄워지는 CustomBottomSheet
			// BottomSheetType -> .displaySetting
            .sheet(isPresented: $isShowingSheet) {
                CustomBottomSheetContent(optionNameList: optionNameList, isShowingSheet: $isShowingSheet, selectedSortingOption: $selectedSortingOption, bottomSheetTypeText: BottomSheetType.displaySetting)
                    .presentationDetents([.displaySetting])
                    .presentationDragIndicator(.hidden) // 시트 상단 인디케이터 비활성화
                    .interactiveDismissDisabled() // 내려서 닫기 비활성화
            }
    
			// 로그아웃 버튼 클릭 시 띄워지는 CustomAlert
			if isLogoutClicked {
                CustomDialog(type: .twoButton(
                    message: "로그아웃 하시겠습니까?",
                    leftButtonLabel: "취소",
                    leftButtonAction: {
                        isLogoutClicked.toggle()
                    },
                    rightButtonLabel: "로그아웃",
                    rightButtonAction: {
                        // TODO: 로그아웃 기능 추가하기
                    })
                )
			}
			
			// 회원탈퇴 버튼 클릭 시 띄워지는 CustomAlert
			// TODO: - 1. 탈퇴 문구 수정하기
			if isDeletAccount {
                CustomDialog(type: .twoButton(
                    message: "탈퇴 하시겠습니까?",
                    leftButtonLabel: "취소",
                    leftButtonAction: {
                        isDeletAccount.toggle()
                    },
                    rightButtonLabel: "탈퇴하기",
                    rightButtonAction: {
                        // 회원탈퇴: 로그아웃 기능 추가하기
                    })
                )
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
				Text("설정")
					.font(.medium18)
					.foregroundStyle(.mainBlack)
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
