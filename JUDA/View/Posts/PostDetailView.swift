//
//  PostDetailView.swift
//  JUDA
//
//  Created by Minjae Kim on 1/29/24.
//

import SwiftUI

enum PostUserType {
	case writter, reader
}

// MARK: - 술상 디테일 화면
struct PostDetailView: View {
	@Environment(\.dismiss) var dismiss
	
	let postUserType: PostUserType
	let nickName: String
	
	@Binding var isLike: Bool
	@Binding var likeCount: Int
	    
	@State private var currentPage = 0
	@State private var windowWidth: CGFloat = 0
	@State private var isReportPresented = false
	@State private var isDeleteDialogPresented = false
    private let postContent = """
                            방어는 다양한 방법으로 맛있게 조리할 수 있습니다. 다음은 몇 가지 방어를 맛있게 먹는 방법들입니다:

                            1. 구이나 튀김: 방어는 오븐이나 프라이팬에서 구워서 먹을 수 있습니다. 신선한 방어에 소금, 후추, 올리브 오일, 식초, 다양한 허브를 더해주면 풍부한 맛을 즐길 수 있습니다. 
                            2. 조림: 방어를 간장, 설탕, 다진 마늘, 생강과 함께 끓여서 조림으로 만들 수 있습니다. 이 방법은 방어의 부드러운 풍미를 강조해줍니다. 
                            3. 회: 신선한 방어를 얇게 썬 후 레몬 주스나 간장 소스와 함께 먹는 것도 맛있습니다. 신선한 재료로 만들어진 회는 풍부한 맛과 신선한 식감을 제공합니다. 
                            4. 구운 방어 김밥: 구운 방어를 김밥 속에 넣어 간단한 반찬 또는 간식으로 먹을 수 있습니다. 신선한 야채와 함께 감칠맛을 더할 수 있습니다.

                            양식과 한식, 다양한 조리법을 통해 방어를 다양하게 즐길 수 있으니 자신의 취향에 맞게 시도해보세요!
                            """
    
	var body: some View {
        ZStack {
            // 사용자, 글 정보 + 이미지 + 술 태그 + 글 내용 + 음식 태그
            // MARK: iOS 16.4 이상
            if #available(iOS 16.4, *) {
                ScrollView {
                    PostDetailContent(isLike: $isLike, likeCount: $likeCount, postContent: postContent, windowWidth: windowWidth)
                }
                .scrollBounceBehavior(.basedOnSize, axes: .vertical)
                .scrollIndicators(.hidden)
                // MARK: iOS 16.4 미만
            } else {
                ViewThatFits(in: .vertical) {
                    PostDetailContent(isLike: $isLike, likeCount: $likeCount, postContent: postContent, windowWidth: windowWidth)
                        .frame(maxHeight: .infinity, alignment: .top)
                    ScrollView {
                        PostDetailContent(isLike: $isLike, likeCount: $likeCount, postContent: postContent, windowWidth: windowWidth)
                    }
                    .scrollIndicators(.hidden)
                }
            }
            // 삭제 버튼 다이얼로그
            if isDeleteDialogPresented {
                CustomDialog(type: .twoButton(
                    message: "삭제하시겠습니까?",
                    leftButtonLabel: "취소",
                    leftButtonAction: {
                        isDeleteDialogPresented = false
                    },
                    rightButtonLabel: "삭제",
                    rightButtonAction: {
                        isDeleteDialogPresented = false
                        // TODO: write view dismiss code
                    })
                )
            }
		}
		.task {
			windowWidth = TagHandler.getScreenWidthWithoutPadding(padding: 20)
		}
		.navigationBarBackButtonHidden()
		.toolbar {
			ToolbarItem(placement: .topBarLeading) {
				Button {
					dismiss()
				} label: {
					Image(systemName: "chevron.left")
				}
			}
			switch postUserType {
			case .writter:
				ToolbarItem(placement: .topBarTrailing) {
					// 공유하기
					ShareLink(item: "Test", // TODO: 실제 공유하려는 내용으로 변경 필요
							  subject: Text("이 링크를 확인해보세요."),
							  message: Text("Hrmi 앱에서 술상 게시물을 공유했어요!"),
							  // 미리보기
							  preview: SharePreview(
								Text(postContent), // TODO: 해당 게시물 이름으로 변경
								image: Image("foodEx1")) // TODO: 해당 술상의 이미지로 변경
					) {
						Image(systemName: "square.and.arrow.up")
					}
				}
				ToolbarItem(placement: .topBarTrailing) {
                    // TODO: NavigationLink - value 로 수정
					NavigationLink {
                        RecordView(recordType: RecordType.edit)
					} label: {
						Image(systemName: "pencil")
					}
				}
				ToolbarItem(placement: .topBarTrailing) {
					Button {
						isDeleteDialogPresented = true
					} label: {
						Image(systemName: "trash")
					}
				}
			case .reader:
				ToolbarItem(placement: .topBarTrailing) {
					// 공유하기
					ShareLink(item: "Test", // TODO: 실제 공유하려는 내용으로 변경 필요
							  subject: Text("이 링크를 확인해보세요."),
							  message: Text("Hrmi 앱에서 술상 게시물을 공유했어요!"),
							  // 미리보기
							  preview: SharePreview(
								Text(postContent), // TODO: 해당 게시물 이름으로 변경
								image: Image("foodEx1")) // TODO: 해당 술상의 이미지로 변경
					) {
						Image(systemName: "square.and.arrow.up")
					}
				}
				ToolbarItem(placement: .topBarTrailing) {
					Button {
						// 버튼 탭 할 경우 신고뷰 출력
						isReportPresented = true
					} label: {
						Image(systemName: "light.beacon.max")
					}
				}
			}
		}
		.foregroundStyle(.mainBlack)
		// 신고뷰를 풀스크린커버로 아래에서 위로 올라오는 뷰
		.fullScreenCover(isPresented: $isReportPresented) {
			PostReportView(isReportPresented: $isReportPresented)
		}
	}
}

// MARK: - 술상 디테일에서, 스크롤 안에 보여줄 내용 부분
struct PostDetailContent: View {
    @Binding var isLike: Bool
    @Binding var likeCount: Int
    let postContent: String
    let windowWidth: CGFloat
    
    private let postPhotos = ["foodEx1", "foodEx2", "foodEx3", "foodEx4"]
    private let postDrinks: [String] = ["카누카 칵테일 700ml", "글렌알라키 10년 캐스크 스트래쓰 700ml", "카누카 칵테일 700ml"]
    private let postDrinksStarRating = [4.5, 4.0, 5.0]
    @State private var tags: [String] = ["대방어", "새우튀김", "광어", "우럭", "이거 한 줄에 몇개 넣어야 할까?", "정렬 문제도", "뭘까", "짬뽕", "짜장", "탕수육", "팔보채", "치킨", "피자", "족발", "콜라", "사이다", "맥콜", "데자와"]

    var body: some View {
        VStack {
            // Bar 형태로 된 게시글 정보를 보여주는 뷰
            PostInfo(userName: "hrmi",
                     profileImageName: "appIcon",
                     postUploadDate: "2023.12.08",
                     isLike: $isLike,
                     likeCount: $likeCount)
            // 게시글의 사진을 페이징 스크롤 형식으로 보여주는 뷰
            PostPhotoScroll(postPhotos: postPhotos)
            // 술 평가 + 글 + 음식 태그
            VStack(alignment: .leading, spacing: 20) {
                // 해당 게시글에 태그된 술이 있을 때,
                if !postDrinks.isEmpty {
                    // 술 평가
                    PostDrinkRating(userName: "hrmi",
                                    postDrinks: postDrinks,
                                    postDrinksStarRating: postDrinksStarRating)
                    //
                    CustomDivider()
                }
                // 술상 글 내용
                Text(postContent)
                    .font(.regular16)
                    .multilineTextAlignment(.leading)
                // 해당 게시글에 음식 태그가 있을 때,
                if !tags.isEmpty {
                    // 음식 태그
                    PostTags(tags: $tags, windowWidth: windowWidth)
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

#Preview {
	PostDetailView(postUserType: .writter, nickName: "hrmi", isLike: .constant(false), likeCount: .constant(45))
}

