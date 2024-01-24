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
		VStack {
			ZStack(alignment: .topTrailing) {
				Image("foodEx3")
					.resizable()
					.frame(height: 170)
					.padding(.bottom, -8)
				
				Image(systemName: "square.on.square.fill")
					.frame(width: 18, height: 18)
					.foregroundStyle(.white)
					.padding([.top, .trailing], 10)
			}
			HStack {
				HStack {
					Image("appIcon")
						.resizable()
						.frame(width: 20, height: 20)
						.clipShape(.circle)
					Text("hrmi")
						.lineLimit(1)
						.font(.regular14)
				}
				.padding(.leading, 10)
				
				Spacer()
				
				Button {
					likeButtonAction()
				} label: {
					HStack {
						Image(systemName: isLike ? "heart.fill" : "heart")
							.foregroundStyle(isLike ? .mainAccent01 : .gray01)
						Text("\(likeCount)")
							.foregroundStyle(.gray01)
					}
					.font(.regular14)
					.padding(.trailing, 10)
				}
			}
			.frame(height: 30)
			.border(.black)
		}
		.frame(width: 170, height: 200)
		.border(.black)
	}
	
	private func likeButtonAction() {
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
