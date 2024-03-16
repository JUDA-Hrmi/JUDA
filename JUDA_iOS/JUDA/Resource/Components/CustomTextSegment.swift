//
//  CustomTextSegment.swift
//  JUDA
//
//  Created by Minjae Kim on 1/25/24.
//

import SwiftUI

// MARK: - 텍스트 형태 세그먼트
struct CustomTextSegment: View {
	let segments: [String]
	@Binding var selectedSegmentIndex: Int
	
	@Namespace private var animation // 애니메이션을 주기위해 뷰에 대한 이름을 지정하는 속성 프로퍼티
	private let id = "CustomTextSegment" // 애니메이션을 주고싶은 뷰에 대한 id값 지정
	
	var body: some View {
		HStack(alignment: .center, spacing: 20) {
			ForEach(0..<segments.count, id: \.self) { index in
				// 세그먼트 텍스트
				Text(segments[index])
                    .font(index == selectedSegmentIndex ? .semibold16 : .medium16)
					.foregroundColor(selectedSegmentIndex == index ? .mainBlack : .gray01)
					.onTapGesture {
						// 세그먼트 전환 시, 부드럽게 전환하기위한 애니메이션
						withAnimation {
							selectedSegmentIndex = index
						}
					}
					.id(index)
					.padding(.horizontal, 4)
					.padding(.bottom, 6)
					// 세그먼트 텍스트 하단 바
					.overlay(alignment: .bottom) {
						if selectedSegmentIndex == index {
							Rectangle()
								// 좌우 전환하는 과정에서 생기는 뷰 사이에 애니메이션을 주기위한 수정자 추가
								.matchedGeometryEffect(id: id, in: animation)
								.frame(height: 2)
						}
					}
			}
		}
	}
}

#Preview {
    CustomTextSegment(segments: ["인기", "최신"],
                      selectedSegmentIndex: .constant(1))
}
