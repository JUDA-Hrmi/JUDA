//
//  DrinkTagScroll.swift
//  JUDA
//
//  Created by 정인선 on 1/29/24.
//

import SwiftUI

// MARK: - 기록 시, 태그 된 술 리스트
struct DrinkTagScroll: View {
    // 술 태그 배열
    @Binding var drinkTags: [DrinkTag]
    // 선택된 술 태그의 정보를 담는 프로퍼티
    @Binding var selectedTagDrink: DrinkTag
    // CustomRatingDialog를 띄워주는 상태 프로퍼티
    @Binding var isShowRatingDialog: Bool
    
    var body: some View {
        // MARK: iOS 16.4 이상
        if #available(iOS 16.4, *) {
            ScrollView {
                DrinkTagContent(drinkTags: $drinkTags,
                                selectedTagDrink: $selectedTagDrink,
                                isShowRatingDialog: $isShowRatingDialog)
            }
            .scrollBounceBehavior(.basedOnSize, axes: .vertical)
        // MARK: iOS 16.4 미만
        } else {
            ViewThatFits(in: .vertical) {
                DrinkTagContent(drinkTags: $drinkTags,
                                selectedTagDrink: $selectedTagDrink,
                                isShowRatingDialog: $isShowRatingDialog)
                    .frame(maxHeight: .infinity, alignment: .top)
                ScrollView {
                    DrinkTagContent(drinkTags: $drinkTags,
                                    selectedTagDrink: $selectedTagDrink,
                                    isShowRatingDialog: $isShowRatingDialog)
                }
            }
        }
    }
}

// MARK: - DrinkTagScroll 로 보여줄 내용
struct DrinkTagContent: View {
    // 술 태그 배열
    @Binding var drinkTags: [DrinkTag]
    // 선택된 술 태그의 정보를 담는 프로퍼티
    @Binding var selectedTagDrink: DrinkTag
    // CustomRatingDialog를 띄워주는 상태 프로퍼티
    @Binding var isShowRatingDialog: Bool
    
    var body: some View {
        LazyVStack {
            ForEach(drinkTags) { drinkTag in
                DrinkTagCell(drinkTags: $drinkTags, drinkTag: drinkTag)
                    .onTapGesture {
                        // 현재 선택된 DrinkTagCell의 술 태그 정보 받아오기
                        selectedTagDrink = drinkTag
                        // CustomRatingDialog 띄우기
                        isShowRatingDialog.toggle()
                    }
            }
        }
    }
}

// MARK: - 태그된 술 리스트 셀
struct DrinkTagCell: View {
    // 술 태그 배열
    @Binding var drinkTags: [DrinkTag]
    // 술 태그
    let drinkTag: DrinkTag
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 10) {
                HStack {
                    // 술 이름
                    Text(drinkTag.name)
                        .font(.semibold16)
                        .lineLimit(1)
                        .padding(.trailing, 40)
                    Spacer()
                }
                // 술 태그에 대한 사용자 평가
                HStack(alignment: .center) {
                    Text("나의 평가")
                        .font(.regular16)
                    StarRating(rating: Double(drinkTag.rating),
                               color: .mainAccent03,
                               starSize: .regular20,
                               fontSize: nil,
                               starRatingType: .none)
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity)
            // Xmark 버튼
            Button {
                // 클릭 시, 술 태그 배열에서 해당 술 태그 삭제
                drinkTags.removeAll { $0.id == drinkTag.id }
            } label: {
                Image(systemName: "xmark")
                    .foregroundStyle(.gray01)
                    .font(.regular14)
            }
        }
        .padding(.vertical)
        .padding(.horizontal, 30)
        //
        CustomDivider()
    }
}
