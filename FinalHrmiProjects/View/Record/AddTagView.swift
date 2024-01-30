//
//  AddTagView.swift
//  FinalHrmiProjects
//
//  Created by 홍세희 on 2024/01/24.
//

import SwiftUI

// 술 태그 데이터 모델
struct DrinkTag: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let rating: Double
}

struct AddTagView: View {
    // TODO: 데이터 타입 변경 필요
    // 이미지 배열
    @State private var selectedPhotos: [UIImage?] = Array(repeating: nil, count: 10)
    // SearchTagView sheet 프로퍼티
    @State private var isShowTagSearch = false
    // 술 태그 더미 데이터
    @State private var drinkTags: [DrinkTag] = [
        DrinkTag(name: "이름1", rating: 2.5),
        DrinkTag(name: "이름2", rating: 4.3),
        DrinkTag(name: "이름3", rating: 2.6),
        DrinkTag(name: "이름4", rating: 5.0),
        DrinkTag(name: "이름5", rating: 4.7),
        DrinkTag(name: "이름6", rating: 1.2)
    ]

    var body: some View {
        NavigationStack {
            // 사진 선택 및 선택된 사진을 보여주는 수평 스크롤 이미지 뷰
            // TODO: sheet로 올라오는 photopicker에 선택된 사진 체크 처리 및 이미지 뷰 수정
            PhotoSelectPagingTab(selectedPhotos: $selectedPhotos)
                .padding(.horizontal, 20)
            
            // 술 태그 추가 버튼
            Button {
                // 클릭 시 SearchTagView Sheet 띄워주기
                isShowTagSearch.toggle()
            } label: {
                Text("술 태그 추가하기")
                    .font(.medium20)
                    .foregroundStyle(.mainAccent03)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.mainAccent03, lineWidth: 1)
                    }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)

            // 술 태그가 없을 때, 텍스트 보여주기
            if drinkTags.isEmpty {
                Spacer()
                Text("태그를 추가해보세요")
                    .foregroundStyle(.gray01)
                    .font(.regular16)
                Spacer()
            } else {
                // 술 태그가 있을 때, DrinkTagCellScrollView 보여주기
                DrinkTagScroll(drinkTags: $drinkTags)
            }
        }
        .customNavigationBar(
            leadingView: {
                Button {
                    //
                } label: {
                    Image(systemName: "chevron.left")
                }
            }, trailingView: [
                .trailing: {
                    Button {
                        // TODO: 사진 없는 경우, 툴바 "다음" 못 누르게 하기
                        // WritingView 이동
                    } label: {
                        Text("다음")
                            .font(.semibold18)
                    }
                }
            ])
        .foregroundStyle(.mainBlack)
        // SearchTageView Sheet
        .sheet(isPresented: $isShowTagSearch) {
//            SearchTagView(isShowTagSearch: $isShowTagSearch)
        }
    }
}

#Preview {
    AddTagView()
}
