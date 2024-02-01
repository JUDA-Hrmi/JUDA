//
//  CustomDialog.swift
//  FinalHrmiProjects
//
//  Created by 백대홍 on 1/30/24.
//

import SwiftUI

// MARK: - 세팅뷰에서 사용될 다이얼로그
struct CustomSettingDialog: View {
    let message: String                 //제목
    let leftButtonLabel: String      //왼쪽 버튼 라벨
    let leftButtonAction: () -> Void    //왼쪽 버튼 액션
    let rightButtonLabel: String        //오른쪽 버튼 라벨
    let rightButtonAction: (() -> Void) //오른쪽 버튼 액션
    var body: some View {
        ZStack {
            Color.gray01
                .opacity(0.3)     // 본인이 쓰는 뷰에 맞게 opacity를 조정해서 사용해주세요.
                .ignoresSafeArea()
            VStack {
                VStack {
                    Text(message)
                        .font(.medium16)
                        .multilineTextAlignment(.center)
                        .lineSpacing(10)
                        .frame(width: 224)
                }
                Divider()
                    .padding(.vertical)
                
                HStack(spacing: 75) {
                    Button(action: {
                        self.leftButtonAction()
                    }, label: {
                        Text(leftButtonLabel)
                            .font(.medium16)
                            .foregroundColor(.gray01)
                            .padding(.horizontal, 16)
                    })
                    Button(action: {
                        self.rightButtonAction()
                    }, label: {
                        Text(rightButtonLabel)
                            .font(.medium16)
                            .foregroundColor(.mainAccent03)
                            .padding(.horizontal, 16)
                    })
                }
                .padding(.horizontal, 16)
            }
            .frame(width: 264, height: 137)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background()
            .cornerRadius(10)
        }
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    CustomSettingDialog(message: "로그아웃하시겠습니까?", leftButtonLabel: "취소", leftButtonAction: {}, rightButtonLabel: "확인", rightButtonAction: {})
}
