//
//  DrinkInfoView.swift
//  JUDA
//
//  Created by 홍세희 on 2024/01/24.
//

import SwiftUI

// MARK: - 그리드 or 리스트 enum
enum DrinkInfoLayoutOption: String, CaseIterable {
    case grid = "grid.style"
    case list = "list.style"
}

// MARK: - 술 정렬 Option enum
enum DrinkSortType: String, CaseIterable {
    case popularity = "인기순"
    case highAlcoholContent = "도수 높은 순"
    case lowAlcoholContent = "도수 낮은 순"
    case highPrice = "가격 높은 순"
    case lowPrice = "가격 낮은 순"
}

// MARK: - 술장 탭
struct DrinkInfoView: View {
    @StateObject private var searchDrinkViewModel = SearchDrinkViewModel()
    @EnvironmentObject private var appViewModel: AppViewModel
    @EnvironmentObject private var drinkViewModel: DrinkViewModel

	@State private var isShowingSortSheet: Bool = false

    @State private var drinkSearchText = ""
    @FocusState private var isFocused: Bool

    // 정렬옵션 이름이 담겨진 리스트
    private let optionNameList = DrinkSortType.allCases.map { $0.rawValue }
    
	var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    // 서치바
                    SearchBar(inputText: $drinkSearchText, isFocused: $isFocused) {
                        Task {
                            await searchDrinkViewModel.fetchSearchDrinks(from: drinkSearchText)
                            print(searchDrinkViewModel.searchDrinks)
                        }
                    }
                    // 서치바 Text가 없을 때, 술 검색 결과 비워주기
                    .onChange(of: drinkSearchText) { _ in
                        if drinkSearchText == "" {
                            searchDrinkViewModel.searchDrinks = []
                        }
                    }
                    // MARK: 검색어 입력 중
                    if isFocused == true {
                        VStack {
                            Rectangle()
                                .fill(.background)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            Text("술 이름을 검색해보세요.")
                                .font(.regular16)
                                .foregroundStyle(.gray01)
                            Rectangle()
                                .fill(.background)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    // MARK: 검색 중
                    } else if searchDrinkViewModel.isLoading {
                        VStack {
                            Rectangle()
                                .fill(.background)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            CircularLoaderView(size: 40)
                            Rectangle()
                                .fill(.background)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    // MARK: 검색 완료 / 결과 X
                    } else if !drinkSearchText.isEmpty,
                              searchDrinkViewModel.searchDrinks.isEmpty,
                              isFocused == false {
                        VStack {
                            Rectangle()
                                .fill(.background)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            Text("검색된 술이 없어요.")
                                .font(.regular16)
                                .foregroundStyle(.gray01)
                            Rectangle()
                                .fill(.background)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    // MARK: 검색 완료 / 결과 O
                    } else if !drinkSearchText.isEmpty,
                              !searchDrinkViewModel.searchDrinks.isEmpty,
                              isFocused == false {
                        DrinkInfoList(searchInDrinkInfo: true) // 검색 중
                            .environmentObject(searchDrinkViewModel)
                    // MARK: 검색 X
                    } else {
                        ScrollViewReader { value in
                            Group {
                                // 술 종류 *(종류 추가 시, horizontal scrollview 로 감싸서 사용)
                                CustomTextSegment(segments: drinkViewModel.typesOfDrink.map { $0.rawValue },
                                                  selectedSegmentIndex: $drinkViewModel.selectedDrinkTypeIndex)
                                .padding(.bottom, 14)
                                .padding([.top, .horizontal], 20)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                // 세그먼트 + 필터링
                                DrinkInfoSegment(optionNameList: optionNameList,
                                                 selectedSortingOption: drinkViewModel.selectedSortedTypeString,
                                                 isShowingSheet: $isShowingSortSheet)
                                // 술 뷰 - DrinkSelectHorizontalScrollBar 의 선택에 따라 자연스럽게 페이징으로 화면 전환
                                TabView(selection: $drinkViewModel.selectedDrinkTypeIndex) {
                                    // 각 술 타입에 맞는 리스트를 grid 와 list 에 뿌려줘야 함
                                    ForEach(drinkViewModel.typesOfDrink.indices, id: \.self) { _ in
                                        ScrollViewReader { proxy in
                                            Group {
                                                // 그리드
                                                if drinkViewModel.selectedViewType == .grid {
                                                    DrinkInfoGrid()
                                                    // 리스트
                                                } else {
                                                    DrinkInfoList()
                                                        .environmentObject(searchDrinkViewModel)
                                                }
                                            }
                                            .onChange(of: drinkViewModel.selectedDrinkTypeIndex) { newValue in
                                                proxy.scrollTo(0, anchor: .center) // 술 종류 이동 시, 스크롤 상단 고정
                                            }
                                            .onChange(of: drinkViewModel.selectedSortedTypeString) { newValue in
                                                proxy.scrollTo(0, anchor: .center) // 술 정렬 변경 시, 스크롤 상단 고정
                                            }
                                        }
                                    }
                                }
                                .tabViewStyle(.page(indexDisplayMode: .never))
                                .onChange(of: drinkViewModel.selectedDrinkTypeIndex) { newValue in
                                    withAnimation {
                                        // 선택 카테고리 변경 시, 데이터 받아오기
                                        drinkViewModel.selectedDrinkTypeIndex = newValue
                                        value.scrollTo(newValue, anchor: .center)
                                    }
                                    Task {
                                        // 술 데이터 받아오기
                                        await drinkViewModel.loadDrinksFirstPage()
                                    }
                                }
                                .animation(.spring, value: drinkViewModel.selectedDrinkTypeIndex)
                            }
                        }
                    }
                }
                // 키보드 내리기
                .onTapGesture {
                    isFocused = false
                }
                // 정렬 방식 선택 CustomBottomSheet (.drinkInfo)
                .sheet(isPresented: $isShowingSortSheet) {
                    CustomBottomSheetContent(optionNameList: optionNameList,
                                             isShowingSheet: $isShowingSortSheet,
                                             selectedSortingOption: $drinkViewModel.selectedSortedTypeString,
                                             bottomSheetTypeText: BottomSheetType.drinkInfo)
                        .presentationDetents([.drinkInfo])
                        .presentationDragIndicator(.hidden) // 시트 상단 인디케이터 비활성화
                        .interactiveDismissDisabled() // 내려서 닫기 비활성화
                }
                // 술 정렬 타입 변경 시, 데이터 받아오기
                .onChange(of: drinkViewModel.selectedSortedTypeString) { _ in
                    Task {
                        await drinkViewModel.loadDrinksFirstPage()
                    }
                }
            }
            // 시작할 때, 데이터 받아오기
            .task {
                await drinkViewModel.loadDrinksFirstPage()
            }
            .onAppear {
                appViewModel.tabBarState = .visible
            }
        }
        .toolbar(appViewModel.tabBarState, for: .tabBar)
	}
}

#Preview {
	DrinkInfoView()
}
