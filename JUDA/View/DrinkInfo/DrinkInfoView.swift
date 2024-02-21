//
//  DrinkInfoView.swift
//  JUDA
//
//  Created by 홍세희 on 2024/01/24.
//

import SwiftUI

// MARK: - 술장 탭
struct DrinkInfoView: View {
    @EnvironmentObject private var appViewModel: AppViewModel

	@State private var isShowingSheet: Bool = false
	@State private var selectedSortingOption: String = "인기순"
	// 세그먼트 선택 - isGridView ? 그리드 뷰 : 리스트 뷰
	@State private var isGridView = true
    @State private var selectedDrinkTypeIndex = 0
    @State private var searchText = ""
    
    @State private var drinks: [Drink] = Drinks.sampleData
    
	// UITest - Drink 종류 DummyData
    private let typesOfDrink: [DrinkType] = [
        .all, .korean, .wine, .whiskey, .beer
	]
    private let optionNameList = ["인기순", "도수 높은 순", "도수 낮은 순", "가격 높은 순", "가격 낮은 순"]
    
	var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    // 서치바
                    SearchBar(inputText: $searchText) {  }
                    
                    ScrollViewReader { value in
                        Group {
                            // 술 종류 *(종류 추가 시, scrollview 로 감싸서 사용)
                            // TODO: 각 탭의 결과에 맞춰 보여줄 리스트 변경 필요
                            CustomTextSegment(segments: typesOfDrink.map {$0.rawValue},
                                              selectedSegmentIndex: $selectedDrinkTypeIndex)
                            .padding(.bottom, 14)
                            .padding([.top, .horizontal], 20)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            // 세그먼트 + 필터링
                            DrinkInfoSegment(optionNameList: optionNameList, selectedSortingOption: $selectedSortingOption, isShowingSheet: $isShowingSheet, isGridView: $isGridView)
                            // 술 뷰 - DrinkSelectHorizontalScrollBar 의 선택에 따라 자연스럽게 페이징으로 화면 전환
                            TabView(selection: $selectedDrinkTypeIndex) {
                                // TODO: 각 술 타입에 맞는 리스트를 grid 와 list 에 뿌려줘야 함
                                ForEach(typesOfDrink.indices, id: \.self) { _ in
                                    ScrollViewReader { proxy in
                                        Group {
                                            // 그리드
                                            if isGridView {
                                                DrinkInfoGrid(drinks: drinks)
                                                // 리스트
                                            } else {
                                                DrinkInfoList(drinks: drinks)
                                            }
                                        }
                                        .onChange(of: selectedDrinkTypeIndex) { newValue in
                                            proxy.scrollTo(0, anchor: .center) // 술 종류 이동 시, 스크롤 상단 고정
                                        }
                                    }
                                }
                            }
                            .tabViewStyle(.page(indexDisplayMode: .never))
                            .onChange(of: selectedDrinkTypeIndex) { newValue in
                                withAnimation {
                                    getDrinks(newValue)
                                    value.scrollTo(newValue, anchor: .center)
                                }
                            }
                            .animation(.spring, value: selectedDrinkTypeIndex)
                        }
                    }
                }
                // 정렬 방식 선택 CustomBottomSheet (.drinkInfo)
                .sheet(isPresented: $isShowingSheet) {
                    CustomBottomSheetContent(optionNameList: optionNameList, isShowingSheet: $isShowingSheet, selectedSortingOption: $selectedSortingOption, bottomSheetTypeText: BottomSheetType.drinkInfo)
                        .presentationDetents([.drinkInfo])
                        .presentationDragIndicator(.hidden) // 시트 상단 인디케이터 비활성화
                        .interactiveDismissDisabled() // 내려서 닫기 비활성화
                }
            }
            .onAppear {
                appViewModel.tabBarState = .visible
            }
        }
        .toolbar(appViewModel.tabBarState, for: .tabBar)
	}
    
    @MainActor
    private func getDrinks(_ index: Int) {
        switch typesOfDrink[index] {
        case .all:
            drinks = Drinks.sampleData
        case .korean:
            drinks = Drinks.koreanSample
        case .wine:
            drinks = Drinks.wineSample
        case .whiskey:
            drinks = Drinks.whiskeySample
        case .beer:
            drinks = Drinks.beerSample
        }
    }
}

#Preview {
	DrinkInfoView()
}
