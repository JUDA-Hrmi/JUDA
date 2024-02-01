//
//  AddTagView.swift
//  FinalHrmiProjects
//
//  Created by 홍세희 on 2024/01/24.
//

import SwiftUI

// 술 태그 데이터 모델
struct DrinkTag: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var rating: Double
}

struct AddTagView: View {
    // TODO: 데이터 타입 변경 필요
    // 이미지 배열
    @State private var selectedPhotos: [UIImage?] = Array(repeating: nil, count: 10)
    // 추가된 술 태그 배열
    @State private var drinkTags: [DrinkTag] = []
    // DrinkTagCell의 술 태그의 정보를 담는 프로퍼티
    @State private var selectedTagDrink: DrinkTag = DrinkTag(id: UUID(), name: "", rating: 0)
    // SearchTagView Sheet를 띄워주는 상태 프로퍼티
    @State private var isShowSearchTag = false
    // CustomRatingDialog를 띄워주는 상태 프로퍼티
    @State private var isShowRatingDialog: Bool = false
    // Navigation을 위한 환경 프로퍼티
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    // 사진 선택 및 선택된 사진을 보여주는 수평 스크롤 이미지 뷰
                    // TODO: sheet로 올라오는 photopicker에 선택된 사진 체크 처리 및 이미지 뷰 수정
                    PhotoSelectPagingTab(selectedPhotos: $selectedPhotos)
                        .padding(.horizontal, 20)
                        .padding(.top, 5)
                    
                    // 술 태그 추가 버튼
                    Button {
                        // 클릭 시 SearchTagView Sheet 띄워주기
                        isShowSearchTag.toggle()
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
                        // DrinkTagScroll 내부 Cell을 탭하면 CustomRatingDialog 띄워주기 위한 상태 프로퍼티 파라미터로 넘기기
                        DrinkTagScroll(drinkTags: $drinkTags,
                                       selectedTagDrink: $selectedTagDrink,
                                       isShowRatingDialog: $isShowRatingDialog)
                    }
                }
                // 상태 프로퍼티에 따라 CustomRatingDialog 띄워주기
                if isShowRatingDialog {
                    CustomRatingDialog(
                        // 선택된 술 태그의 술 이름
                        drinkName: selectedTagDrink.name,
                        leftButtonLabel: "취소",
                        leftButtonAction: {
                            // CustomRatingDialog 사라지게 하기
                            isShowRatingDialog = false
                        },
                        rightButtonLabel: "수정",
                        rightButtonAction: {
                            // 0보다 큰 점수를 매겼을 때 수정 버튼 동작
                            if selectedTagDrink.rating > 0 {
                                // 술 태그 배열에서 해당 술 태그의 점수를 변경
                                if let index = drinkTags.firstIndex(where: { $0.id == selectedTagDrink.id }) {
                                    drinkTags[index].rating = selectedTagDrink.rating
                                }
                                // 점수 변경 후 CustomRatingDialog 사라지게 하기
                                isShowRatingDialog = false
                            }
                        },
                        // 선택된 술 태그의 점수를 CustomDialog에 반영해서 띄워주기 위함
                        rating: $selectedTagDrink.rating
                    )
                    
                }

            }
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        // PostsView로 돌아가기
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.backward")
                    }
                    .tint(.mainBlack)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        // TODO: WritingView 이동
                        // WritingView()
                    } label: {
                        Text("다음")
                    }
                }
            }
            .foregroundStyle(.mainBlack)
            // SearchTageView Sheet 띄워주기
            .sheet(isPresented: $isShowSearchTag) {
                SearchTagView(drinkTags: $drinkTags,
                              isShowSearchTag: $isShowSearchTag)
            }
            
        }
    }
}

#Preview {
    AddTagView()
}
