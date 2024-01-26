//
//  CustomAlert.swift
//  FinalHrmiProjects
//
//  Created by 백대홍 on 1/26/24.
//

import SwiftUI

struct CustomAlertView: View {
    var message: String                 //제목
    var leftButtonLabel: String      //왼쪽 버튼 라벨
    var leftButtonAction: () -> Void    //왼쪽 버튼 액션
    var rightButtonLabel: String        //오른쪽 버튼 라벨
    var rightButtonAction: (() -> Void) //오른쪽 버튼 액션
    
    var body: some View {
        VStack {
            VStack(spacing: 12) {
                Text(message)
                    .font(Font.custom("Pretendard", size: 16))
                    .multilineTextAlignment(.center)
                    .lineSpacing(10)
                    .foregroundColor(.black)
                    .frame(width: 224)
                    
            }
            
            Divider()
                .padding(.vertical)
            
            HStack(spacing: 75 ) {
                Button(action: {
                    self.leftButtonAction()
                }, label: {
                    Text(leftButtonLabel)
                        .font(
                        Font.custom("Pretendard", size: 14)
                        .weight(.medium)
                        )
                        .foregroundColor(.gray01)
                        .padding(.horizontal,16)
                })
                Button(action: {
                    self.rightButtonAction()
                }, label: {
                    Text(rightButtonLabel)
                        .font(
                        Font.custom("Pretendard", size: 14)
                        .weight(.medium)
                        )
                        .foregroundColor(.mainAccent03)
                        .padding(.horizontal,16)
                })
            }
            .padding(.horizontal, 16)
        }
        .frame(width: 264, height: 137 )
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Color.white)
        .cornerRadius(5)
        .shadow(radius: 10)
    }
}


#Preview {
    CustomAlertView(message: "로그인이 필요한 기능이에요.\n더 많은 기능을 사용할 수 있어요.", leftButtonLabel: "취소", leftButtonAction: {}, rightButtonLabel: "로그인", rightButtonAction: {})
}

