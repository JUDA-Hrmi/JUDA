//
//  FoodTagVerticalScroll.swift
//  FinalHrmiProjects
//
//  Created by 정인선 on 1/30/24.
//

import SwiftUI

// 추가된 음식 태그를 보여주는 Scroll View
struct FoodTagVerticalScroll: View {
    // 음식 태그 배열
    @Binding var foodTags: [FoodTag]
    // 태그 결과를 보여주는 이차원 배열
    @State private var foodTagRows: [[FoodTag]] = []
    // 화면 너비
    let windowWidth: CGFloat
    // View를 식별하기 위해 부여
    @Namespace var lastHStack
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 15) {
                    ForEach(foodTagRows, id: \.self) { row in                        
                        HStack(spacing: 20) {
                            ForEach(row, id: \.self) { tag in
                                // foodTagRows의 마지막 줄의 첫번째일 때, FoodTagXmarkButtom에 id 부여
                                if tag == foodTagRows.last?.first {
                                    // "X 음식태그" 형태를 가진 버튼
                                    FoodTagXmarkButton(foodTags: $foodTags, foodTag: tag)
                                        .id(lastHStack)
                                } else {
                                    FoodTagXmarkButton(foodTags: $foodTags, foodTag: tag)
                                }
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
            .onChange(of: foodTags) { _ in
                foodTagRows = getRows(tags: foodTags, spacing: 35, fontSize: 14, windowWidth: windowWidth)
                // Scroll View 포커싱에 애니메이션 추가
                withAnimation {
                    // Scroll View가 마지막 줄에 포커싱 되도록 하기
                    proxy.scrollTo(lastHStack, anchor: .center)
                }
            }
        }
    }
    
    // TODO: 핸들러 사용
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
    private func getRows(tags: [FoodTag], spacing: CGFloat, fontSize: CGFloat, windowWidth: CGFloat, tagString: String = "") -> [[FoodTag]] {
        var rows: [[FoodTag]] = [] // tag 값을 담아주기 위한 2차원 배열 프로퍼티
        var currentRow: [FoodTag] = [] // 화면상의 width에 맞게 tag 배열을 잘라 2차원 배열에 담아줄 프로퍼티
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
                currentRow.append(tag)
                // 5. 총합 width에 계산된 최근 tag에 대한 width값을 담아준다.
                totalWidth = fontSize
            } else {
                // 1. 총합 width가 화면 상의 width 보다 작을 경우
                // 2. 1차원 배열에 tag 값을 append
                currentRow.append(tag)
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


//#Preview {
//    FoodTagVerticalScroll()
//}
