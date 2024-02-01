//
//  FoodTagAddTextField.swift
//  FinalHrmiProjects
//
//  Created by 정인선 on 1/30/24.
//

import SwiftUI

struct FoodTagAddTextField: View {
    // TextField로 부터 입력받은 음식 태그 이름
    @State private var foodTagName: String = ""
    // 음식 태그 배열
    @Binding var foodTags: [FoodTag]
    // VStack에 부여된 id 값 바인딩
    var textField: Namespace.ID
    // TextField focus 상태 프로퍼티 바인딩
    var isFocusedTextField: FocusState<Bool>.Binding
    // WritingView의 ScrollView porxy 바인딩
    let proxy: ScrollViewProxy
    
    var body: some View {
        HStack {
            Text("#")
                .font(.regular16)
                .opacity(0.7)
            
            TextField("음식 이름", text: $foodTagName)
                .focused(isFocusedTextField)
                .onChange(of: isFocusedTextField.wrappedValue) { newValue in
                    if newValue {
                        // focusState의 Scroll 우선순위로 인하여 시간차를 두고 실행
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            withAnimation {
                                // WritingView의 ScrollView가 음식 태그 Vstack에 포커싱되도록 하기
                                proxy.scrollTo(textField, anchor: .center)
                            }
                        }
                    }
                }
            
            Button {
                // 입력된 음식 태그 이름을 음식 태그 배열에 추가
                addFoodTag()
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
    
    // 입력된 음식 태그 이름을 음식 태그 배열 foodTags에 추가해주는 함수
    private func addFoodTag() {
        // 중복 추가 불가
        if !foodTagName.isEmpty && !foodTags.contains(where: { $0.name == foodTagName }) {
            foodTags.append(FoodTag(name: foodTagName))
        }
        // TextField 비워주기
        foodTagName = ""
        
        withAnimation {
            // WritingView의 ScrollView가 음식 태그 Vstack에 포커싱
            proxy.scrollTo(textField, anchor: .center)
        }
    }
}

//#Preview {
//    FoodTagAddTextField()
//}
