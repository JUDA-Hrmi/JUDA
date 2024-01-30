//
//  PostCell.swift
//  FinalHrmiProjects
//
//  Created by Minjae Kim on 1/25/24.
//

import SwiftUI

struct PostCell: View {
	
	@Binding var isLike: Bool
	@Binding var likeCount: Int
	
	var body: some View {
		// VStack에 기본적인 spacing이 들어가기 때문에 0으로 설정
		VStack(spacing: 0) {
			ZStack(alignment: .topTrailing) {
				// 게시글 사진리스트의 첫 번째 사진
				Image("foodEx3")
					.resizable()
                    .aspectRatio(1.0, contentMode: .fill)
					.frame(maxWidth: 170)
				
				// 게시글 사진이 2장 이상일 경우, 상자 아이콘이 사진의 trailing 상단에 보여짐
				Image(systemName: "square.on.square.fill")
					.frame(width: 18, height: 18)
					.foregroundStyle(.white)
					.padding([.top, .trailing], 10)
			}
			HStack {
				HStack {
					// 사용자의 프로필 사진
					Image("appIcon")
						.resizable()
						.frame(width: 20, height: 20)
						.clipShape(.circle)
					
					// 사용자의 닉네임
					Text("hrmi")
						.lineLimit(1)
						.font(.regular14)
				}
				.padding(.leading, 10)
				
				Spacer()
				
				// 좋아요 버튼
				HStack {
					// 좋아요를 등록 -> 빨간색이 채워진 하트
					// 좋아요를 해제 -> 테두리가 회색인 하트
					Image(systemName: isLike ? "heart.fill" : "heart")
						.foregroundStyle(isLike ? .mainAccent01 : .gray01)
					Text("\(likeCount)")
						.foregroundStyle(.gray01)
				}
				.font(.regular14)
				.padding(.trailing, 10)
				.onTapGesture {
					likeButtonAction()
				}
			}
			.frame(height: 30)
		}
        .frame(maxHeight: 200)
	}
	
	// 좋아요 버튼 액션 메서드
	private func likeButtonAction() {
		// 좋아요 등록 -> 좋아요 수에 + 1
		// 좋아요 해제 -> 좋아요 수에 - 1
		if isLike {
			likeCount -= 1
		} else {
			likeCount += 1
		}
		isLike.toggle()
	}
}

#Preview {
	PostCell(isLike: .constant(true), likeCount: .constant(45))
}
