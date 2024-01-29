//
//  WritingView.swift
//  FinalHrmiProjects
//
//  Created by 정인선 on 1/29/24.
//

import SwiftUI

// 음식 태그 데이터 모델
struct FoodTag: Identifiable, Hashable, Equatable {
    let id = UUID()
    let name: String
}

struct WritingView: View {
    // 선택된 사진들을 담은 배열 (더미 데이터는 Assets을 사용하기 위해 작성)
    @State private var images: [String] = ["foodEx1", "foodEx2", "foodEx3", "foodEx4", "foodEx5"]
    // TextEditor으로 작성될 글 내용
    @State private var content: String = ""
    // 음식 태그 배열
    @State private var foodTags: [FoodTag] = []
    // 화면 너비
    @State private var windowWidth: CGFloat = 0
    // TextEditor에서 사용되는 placeholder
    private let placeholder = """
                    사진에 대해 설명해주세요.
                    음식과 함께 마신 술은 어땠나요?
                    """
    
    var body: some View {
        NavigationStack {
            // 선택된 사진들 보여주는 스크롤뷰
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack {
                    ForEach(0..<images.count, id: \.self) { index in
                        ZStack(alignment: .topTrailing) {
                            Image(images[index])
                                .resizable()
                                // TODO: frame 가변으로 변경
                                .frame(width: 100, height: 100)
                                .clipShape(.rect(cornerRadius: 10))
                            Button {
                                // 사진 배열에서 해당 사진 삭제
                                images.remove(at: index)
                            } label: {
                                // TODO: XmarkOnGrayCircle 변경
                                Image(systemName: "xmark.circle.fill")
                                    // 심볼 레이어별로 색상 지정할 수 있게 렌더링모드 .palette 설정
                                    // xmark 색상 gray06, circle 색상 gray01
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(.gray06, .gray01.opacity(0.6))
                                    .font(.title3)
                                    .padding(3)
                            }
                        }
                    }
                }
            }
            // TODO: frame 가변으로 변경
            .frame(height: 100)
            .padding(.leading, 20)
            
            // 글 내용 적는 TextEditor
            TextEditor(text: $content)
                // TextEditor에 Text를 오버레이하여 placeholder로 보여줌
                .overlay(alignment: .topLeading) {
                    // content가 입력됐을 때, placeholder "" 처리
                    Text(content.isEmpty ? placeholder : "")
                        .padding(.leading, 6)
                        .padding(.top, 10)
                        .foregroundStyle(.gray01)
                    
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
            
            CustomDivider()
            
            HStack {
                Text("음식 태그")
                    .font(.semibold18)
                Spacer()
            }
            .padding(.horizontal, 20)
            // TODO: DrinkInfoDetail 참고하여 Divider와 HStack 사이 패딩 변경 필요
            .padding(.vertical, 5)
            
            // 음식 태그 추가 TextField
            FoodTagAddTextField(foodTags: $foodTags)
            // 추가된 음식 태그를 보여주는 Scroll View
            FoodTagVerticalScroll(foodTags: $foodTags, windowWidth: windowWidth)

        }
        .task {
            let scenes = UIApplication.shared.connectedScenes
            let windowScene = scenes.first as? UIWindowScene
            let window = windowScene?.windows.first
            windowWidth = (window?.screen.bounds.width ?? 0) - 40
        }
        .customNavigationBar(
            leadingView: {
                Button {
                    //
                } label: {
                    Image(systemName: "chevron.left")
                }
            }, trailingView: [.trailing: {
                Button {
                    // TODO: 데이터 저장
                } label: {
                    Text("완료")
                        .font(.semibold18)
                }
            }
            ])
        .foregroundStyle(.mainBlack)
    }
}

// 음식 태그 추가하는 TextField
struct FoodTagAddTextField: View {
    // 음식 태그 배열
    @Binding var foodTags: [FoodTag]
    // TextField로 부터 입력받은 음식 태그 이름
    @State private var foodTagName: String = ""
    
    var body: some View {
        HStack {
            Text("#")
                .font(.regular16)
                .opacity(0.7)
            
            TextField("음식 이름", text: $foodTagName)
            Button {
                // 중복 추가 불가
                if !foodTagName.isEmpty && !foodTags.contains(where: { $0.name == foodTagName }) {
                    foodTags.append(FoodTag(name: foodTagName))
                }
                // TextField 비워주기
                foodTagName = ""
            } label: {
                Text("추가하기")
                    .font(.regular14)
                    .opacity(0.7)
                
            }
            // tint color 안 들어가게 버튼 스타일 변경
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(.mainAccent03.opacity(0.2))
        .clipShape(.rect(cornerRadius: 10))
        .padding(.horizontal, 20)
    }
}

// 추가된 음식 태그를 보여주는 Scroll View
struct FoodTagVerticalScroll: View {
    // 음식 태그 배열
    @Binding var foodTags: [FoodTag]
    // 태그 결과를 보여주는 이차원 배열
    @State private var foodTagRows: [[String]] = []
    // 화면 너비
    let windowWidth: CGFloat
    
    var body: some View {
        // TODO: 스크롤 뷰 하단 포커싱
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 15) {
                    ForEach(foodTagRows, id: \.self) { row in                        HStack(spacing: 20) {
                            ForEach(row, id: \.self) { tag in
                                // "X 음식태그" 형태를 가진 버튼
                                FoodTagXmarkButton(foodTags: $foodTags, foodTag: tag)
                            }
                        }
                    }
                }
                .padding(.vertical, 10)
            }
            .frame(width: windowWidth, height: 150, alignment: .leading)
            .padding(.top, 10)
            .padding(.bottom, 5)
            // 음식 태그 배열에 변경사항이 있을 때마다 width에 맞게 2차원 배열로 매핑
            .onChange(of: foodTags) { newValue in
                foodTagRows = getRows(tags: foodTags, spacing: 35, fontSize: 14, windowWidth: windowWidth)
            }
        }
    }
    
    private func getScreenWidthWithoutPadding(padding: CGFloat) -> CGFloat {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        let windowWidth = (window?.screen.bounds.width ?? 0) - (padding * 2)
        return windowWidth
    }
    
    private func getFontSize(tag: String, fontSize: CGFloat) -> CGFloat {
        let font = UIFont.systemFont(ofSize: fontSize)
        let attributes = [NSAttributedString.Key.font: font]
        let size = (tag as NSString).size(withAttributes: attributes)
        return size.width
    }
    
    // MARK: tags 데이터 타입 [String] -> [FoodTag]로 변경
    private func getRows(tags: [FoodTag], spacing: CGFloat, fontSize: CGFloat, windowWidth: CGFloat, tagString: String = "") -> [[String]] {
        var rows: [[String]] = [] // tag 값을 담아주기 위한 2차원 배열 프로퍼티
        var currentRow: [String] = [] // 화면상의 width에 맞게 tag 배열을 잘라 2차원 배열에 담아줄 프로퍼티
        var totalWidth: CGFloat = 0 // 화면상의 width와 비교하여 계산하기 위한 1차원 배열의 총 width를 계산해서 담아줄 저장 프로퍼티
        
        tags.forEach { tag in
            let fontSize = getFontSize(tag: tagString + tag.name, fontSize: fontSize) + spacing // size = tagString 문자열 + tag 문자열 + spacing
            totalWidth += fontSize
            
            // 1. 총합 width가 화면 상의 width 보다 클 경우
            if totalWidth > windowWidth {
                // 2. 잘라주며 담아준 1차원 배열을 2차원 배열에 append
                rows.append(currentRow)
                // 3. 1차원 배열의 데이터를 다 지워주면서
                currentRow.removeAll()
                // 4. 최근 tag값을 1차원 배열에 append
                currentRow.append(tag.name)
                // 5. 총합 width에 계산된 최근 tag에 대한 width값을 담아준다.
                totalWidth = fontSize
            } else {
                // 1. 총합 width가 화면 상의 width 보다 작을 경우
                // 2. 1차원 배열에 tag 값을 append
                currentRow.append(tag.name)
            }
        }
        
        // 1. tag값이 담긴 1차원 배열에 데이터가 남아있는 경우
        if !currentRow.isEmpty {
            // 2. 2차원 배열에 1차원 배열을 append
            rows.append(currentRow)
            // 3. tag값이 담긴 1차원 배열의 데이터를 다 지워준다
            currentRow.removeAll()
        }
        
        return rows
    }
}

// "X 음식태그" 형태를 가진 버튼
struct FoodTagXmarkButton: View {
    // 추가된 음식 태그 배열
    @Binding var foodTags: [FoodTag]
    // 음식 태그 이름
    let foodTag: String
    
    var body: some View {
        Button {
            // 버튼 클릭 시, foodTag 삭제
            // foodTags = foodTagRows.flatMap { $0 }
            foodTags.removeAll(where: { $0.name == foodTag })
        } label : {
            HStack(spacing: 2) {
                Image(systemName: "xmark")
                    .font(.regular14)
                    .foregroundStyle(.mainAccent04)
                // MARK: 태그 보여주는 순서 고민
                Text("\(foodTag)")
                    .font(.semibold14)
                    .foregroundStyle(Color.mainAccent04)
            }
        }
    }
}

#Preview {
    WritingView()
}
