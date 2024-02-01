//
//  CustomRatingDialog.swift
//  FinalHrmiProjects
//
//  Created by 정인선 on 2/1/24.
//

import SwiftUI

struct CustomRatingDialog: View {
    let drinkName: String               // 술 이름
    let leftButtonLabel: String         // 왼쪽 버튼 라벨
    let leftButtonAction: () -> Void    // 왼쪽 버튼 액션
    let rightButtonLabel: String        // 오른쪽 버튼 라벨
    let rightButtonAction: () -> Void // 오른쪽 버튼 액션
    // 점수
    @Binding var rating: Double
    
    var body: some View {
        ZStack {
            Color.gray01
                .opacity(0.5)
                .ignoresSafeArea()
            VStack {
                VStack {
                    Text(drinkName)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(10)
                        .frame(width: 224)
						.font(.medium18)

                    // MARK: 별점 매기는 부분
                    HStack(spacing: 0) {
                        ForEach(1...5, id: \.self) { number in
                            Image(systemName: "star.fill")
                                .font(.system(size: 32))
                                // 선택된 이미지까지 색 변경
                                .foregroundStyle(Double(number) > rating ? .gray01 : .mainAccent03)
                                .onTapGesture {
                                    // 첫번째 별만 채워져 있을 때, 한 번 더 탭하면 0점이 됨
                                    if rating == 1 && number == 1 {
                                        rating = 0
                                    } else {
                                        // 선택된 별의 개수만큼 점수를 바꿔줌
                                        rating = Double(number)
                                    }
                                }
                        }
                    }
                    .padding(.vertical, 5)
                }
                .padding(.vertical, 10)

                Divider()

                HStack(spacing: 65) {
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
                .padding(.vertical,5)
            }
            .frame(width: 264, alignment: .top) //height 값은 따로 제약 X
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background()
            .cornerRadius(10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    CustomRatingDialog(
        drinkName: "술 이름",
        leftButtonLabel: "취소",
        leftButtonAction: {},
        rightButtonLabel: "평가",
        rightButtonAction: {},
        rating: .constant(0))
}
