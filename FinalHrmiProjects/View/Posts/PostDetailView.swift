//
//  PostDetailView.swift
//  FinalHrmiProjects
//
//  Created by Minjae Kim on 1/29/24.
//

import SwiftUI

enum PostUserType {
	case writter, reader
}

struct PostDetailView: View {
	
	let postUserType: PostUserType
	
	let nickName: String
	
	@Binding var isLike: Bool
	@Binding var likeCount: Int
	
	private let postPhotos = ["foodEx1", "foodEx2", "foodEx3", "foodEx4"]
	
	private let postDrinks = ["카누카 칵테일 700ml", "글렌알라키 10년 캐스크 스트래쓰 700ml", "카누카 칵테일 700ml"]
	private let postDrinksStarRating = [4.5, 4.0, 5.0]
	
	private let postContent = """
방어는 다양한 방법으로 맛있게 조리할 수 있습니다. 다음은 몇 가지 방어를 맛있게 먹는 방법들입니다:

1. 구이나 튀김: 방어는 오븐이나 프라이팬에서 구워서 먹을 수 있습니다. 신선한 방어에 소금, 후추, 올리브 오일, 식초, 다양한 허브를 더해주면 풍부한 맛을 즐길 수 있습니다. 
2. 조림: 방어를 간장, 설탕, 다진 마늘, 생강과 함께 끓여서 조림으로 만들 수 있습니다. 이 방법은 방어의 부드러운 풍미를 강조해줍니다. 
3. 회: 신선한 방어를 얇게 썬 후 레몬 주스나 간장 소스와 함께 먹는 것도 맛있습니다. 신선한 재료로 만들어진 회는 풍부한 맛과 신선한 식감을 제공합니다. 
4. 구운 방어 김밥: 구운 방어를 김밥 속에 넣어 간단한 반찬 또는 간식으로 먹을 수 있습니다. 신선한 야채와 함께 감칠맛을 더할 수 있습니다.

양식과 한식, 다양한 조리법을 통해 방어를 다양하게 즐길 수 있으니 자신의 취향에 맞게 시도해보세요!
"""
	
	private let tags = ["대방어", "새우튀김", "광어", "우럭", "이거 한 줄에 몇개 넣어야 할까?", "정렬 문제도", "뭘까", "짬뽕", "짜장", "탕수육", "팔보채", "치킨", "피자", "족발"]
	
	@State private var currentPage = 0
	
	@State private var windowWidth: CGFloat = 0
	
	var body: some View {
		NavigationStack {
			VStack {
				ScrollView {
					PostInfo(userName: "hrmi",
							 profileImageName: "appIcon",
							 postUploadDate: "2023.12.08",
							 isLike: $isLike,
							 likeCount: $likeCount)
					
					PostPhotoScroll(postPhotos: postPhotos)
					
					VStack(spacing: 20) {
						PostDrinkRating(userName: "hrmi",
										postDrinks: postDrinks,
										postDrinksStarRating: postDrinksStarRating)
						CustomDivider()
						
						Text(postContent)
							.font(.regular16)
						
						PostTags(tags: tags, windowWidth: windowWidth)
					}
					.padding(.horizontal, 20)
				}
			}
		}
		.task {
			windowWidth = TagHandler.getScreenWidth(padding: 20)
		}
	}
}

#Preview {
	PostDetailView(postUserType: .writter, nickName: "hrmi", isLike: .constant(false), likeCount: .constant(45))
}

