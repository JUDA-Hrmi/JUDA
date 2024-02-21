//
//  FoodTagAddTextField.swift
//  JUDA
//
//  Created by 정인선 on 1/30/24.
//

import SwiftUI

// MARK: - 음식 태그 추가 텍스트 필드
struct FoodTagAddTextField: View {
    @EnvironmentObject private var recordVM: RecordViewModel
	// TextField로 부터 입력받은 음식 태그 이름
	@State private var foodTagName: String = ""
	// VStack에 부여된 id 값 바인딩
	var textField: Namespace.ID
	// TextField focus 상태 프로퍼티 바인딩
    var isFocusedTextField: FocusState<Bool>.Binding
	// RecordView의 ScrollView porxy 바인딩
	let proxy: ScrollViewProxy
    // 음식 태그 10개를 넘어가는지 체크
    @State private var isTagsCountAboveTen: Bool = false
	
	var body: some View {
        HStack {
            Text("#")
                .font(.regular16)
                .opacity(0.7)
            // 텍스트 필드
            TextField("음식 이름", text: $foodTagName)
                .font(.regular16)
                .focused(isFocusedTextField)
                .textInputAutocapitalization(.never) // 자동 대문자 설정 기능 비활성화
                .autocorrectionDisabled()
                .onChange(of: isFocusedTextField.wrappedValue) { newValue in
                    if newValue {
                        // focusState의 Scroll 우선순위로 인하여 시간차를 두고 실행
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            withAnimation {
                                // RecordView의 ScrollView가 음식 태그 Vstack에 포커싱되도록 하기
                                proxy.scrollTo(textField, anchor: .center)
                            }
                        }
                    }
                }
            // 추가하기 버튼
            Button {
                // 입력된 음식 태그 이름을 음식 태그 배열에 추가
                addFoodTag()
            } label: {
                Text("추가하기")
                    .font(.regular14)
                    .opacity(isTagsCountAboveTen ? 0 : 0.7)
            }
            // tint color 안 들어가게 버튼 스타일 변경
            .buttonStyle(.plain)
            .disabled(isTagsCountAboveTen)
        }
        // 초기 화면 구성 시, 받아온 음식 태그의 개수가 10개 넘는지 확인 ( 수정의 경우 이미 10개 일수도 있음 )
        .onAppear {
            calculateIsFoodTagsCountAboveTen()
        }
        // 음식 태그 리스트에 변화가 있을때마다, 10개가 넘는지 확인
        .onChange(of: recordVM.foodTags) { _ in
            calculateIsFoodTagsCountAboveTen()
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 20)
        .background(.mainAccent03.opacity(0.2))
        .clipShape(.rect(cornerRadius: 10))
        .padding(.horizontal, 20)
	}
	
    // 음식 태그가 10개가 넘는지 확인하는 함수
    private func calculateIsFoodTagsCountAboveTen() {
        self.isTagsCountAboveTen = recordVM.foodTags.count >= 10
    }
    
	// 입력된 음식 태그 이름을 음식 태그 배열 foodTags에 추가해주는 함수
	private func addFoodTag() {
		// 중복 추가 불가
        if !foodTagName.isEmpty && !recordVM.foodTags.contains(where: { $0 == foodTagName }) {
            recordVM.foodTags.append(foodTagName)
		}
		// TextField 비워주기
		foodTagName = ""
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
			withAnimation {
				// RecordView의 ScrollView가 음식 태그 Vstack에 포커싱
				proxy.scrollTo(textField, anchor: .center)
			}
		}
	}
}
