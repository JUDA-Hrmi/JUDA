//
//  SearchTagView.swift
//  JUDA
//
//  Created by 정인선 on 1/30/24.
//

import SwiftUI

// 술 리스트 셀에 들어가는 더미데이터
struct DrinkInfo: Identifiable, Hashable {
    let id = UUID()
    let name: String
    
    static let drinkInfos: [DrinkInfo] = [
        DrinkInfo(name: "술 이름 1"),
        DrinkInfo(name: "술 이름 2"),
        DrinkInfo(name: "술 이름 3"),
        DrinkInfo(name: "술 이름 4"),
        DrinkInfo(name: "술 이름 5")
    ]
}

// MARK: - 술 태그 서치 시트 화면
// Defualt로 술찜 목록 보여주기
struct SearchTagView: View {
    // TODO: 데이터 타입 변경 필요
    // DrinkListCell 선택 시 DrinkInfo 데이터를 받는 프로퍼티
    @State private var selectedDrink: DrinkInfo? = nil
    // CostomRatingDialog를 띄워주는 상태 프로퍼티
    @State private var isShowRatingDialog: Bool = false
    // 추가된 술 태그 배열
    @Binding var drinkTags: [DrinkTag]
    // SearchTagView Sheet를 띄워주는 상태 프로퍼티
    @Binding var isShowSearchTag: Bool
    // 점수
    @State private var rating: Double = 0
    // 찜 목록 배열 ( 더미데이터를 넣어서 테스트 함 )
    private let likeds: [DrinkInfo] = DrinkInfo.drinkInfos

	@State private var tagSearchText = ""
	
    var body: some View {
        ZStack {
            VStack {
                // 서치바 + 시트 닫기 버튼
                HStack(alignment: .center, spacing: 0) {
					SearchBar(inputText: $tagSearchText)
                    // Sheet 내려주기
                    Button {
                        isShowSearchTag.toggle()
                    } label: {
                        XmarkOnGrayCircle()
                            .font(.title)
                            .padding(.trailing, 15)
                    }
                }
                .padding(.top, 20)
                // 찜 목록이 없을 때, 임의의 리스트 보여주기
                if likeds.isEmpty {
                    Spacer()
                    // TODO: 텍스트 대신 리스트로 변경
                    Text("술찜 없을 때 리스트")
                        .font(.regular14)
                        .foregroundStyle(.gray01)
                    Spacer()
                } else {
                    // 찜 목록이 있을 때, DrinkListCell 리스트로 보여주기
                    // MARK: iOS 16.4 이상
                    if #available(iOS 16.4, *) {
                        ScrollView() {
                            SearchTagListContent(selectedDrink: $selectedDrink,
                                                 isShowRatingDialog: $isShowRatingDialog)
                        }
                        .scrollBounceBehavior(.basedOnSize, axes: .vertical)
                        .scrollIndicators(.hidden)
                        .scrollDismissesKeyboard(.immediately)
                    // MARK: iOS 16.4 미만
                    } else {
                        ViewThatFits(in: .vertical) {
                            SearchTagListContent(selectedDrink: $selectedDrink,
                                                 isShowRatingDialog: $isShowRatingDialog)
                                .frame(maxHeight: .infinity, alignment: .top)
                            ScrollView {
                                SearchTagListContent(selectedDrink: $selectedDrink,
                                                     isShowRatingDialog: $isShowRatingDialog)
                            }
                            .scrollIndicators(.hidden)
                            .scrollDismissesKeyboard(.immediately)
                        }
                    }
                }
            }
            // CustomDialog - .rating
            if isShowRatingDialog {
                // 선택된 Cell의 술 정보 데이터를 잘 받아왔을 때
                if let selectedDrink = selectedDrink {
                    CustomDialog(type: .rating(
                        // 선택된 술 정보의 술 이름
                        drinkName: selectedDrink.name,
                        leftButtonLabel: "취소",
                        leftButtonAction: {
                            // CustomRatingDialog 사라지게 하기
                            isShowRatingDialog.toggle()
                        },
                        rightButtonLabel: "평가",
                        rightButtonAction: {
                            // 0보다 큰 점수를 매겼을 때 수정 버튼 동작
                            if rating > 0 {
                                // 동일한 술 id를 가진 술 태그 데이터가 배열에 존재할 때 - 수정
                                if drinkTags.contains(where: { $0.id == selectedDrink.id }),
                                   // 해당 요소의 인덱스를 받아, 점수만 수정
                                   let index = drinkTags.firstIndex(where: { $0.id == selectedDrink.id }) {
                                    drinkTags[index].rating = rating
                                } else {
                                    // 동일한 술 id를 가진 술 태그 데이터가 배열에 존재하지 않을 때 - 추가
                                    // 술 태그 배열에 추가
                                    drinkTags.append(DrinkTag(id: selectedDrink.id, name: selectedDrink.name, rating: rating))
                                }
                                // 변경 후 CustomRatingDialog, SearchTagView 사라지게 하기
                                isShowRatingDialog.toggle()
                                isShowSearchTag.toggle()
                            }
                        },
                        rating: $rating)
                    )
                }
            }
        }
    }
}

// MARK: - 스크롤 뷰 or 뷰 로 보여질 태그 추가 시, 찜 목록이 있을 때 DrinkListCell 리스트
struct SearchTagListContent: View {
    // DrinkListCell 선택 시 DrinkInfo 데이터를 받는 프로퍼티
    @Binding var selectedDrink: DrinkInfo?
    // CostomRatingDialog를 띄워주는 상태 프로퍼티
    @Binding var isShowRatingDialog: Bool
    // 찜 목록 배열 ( 더미데이터를 넣어서 테스트 함 )
    private let likeds: [DrinkInfo] = DrinkInfo.drinkInfos
    
    var body: some View {
        LazyVStack {
            ForEach(likeds, id: \.self) { drinkInfo in
                DrinkListCell()
                    .onTapGesture {
                        // 현재 선택된 DrinkListCell의 술 정보를 받아오기
                        selectedDrink = drinkInfo
                        // CustomRatingDialog 띄우기
                        isShowRatingDialog.toggle()
                    }
            }
        }
    }
}

#Preview {
    SearchTagView(drinkTags: .constant([]), isShowSearchTag: .constant(true))
}
