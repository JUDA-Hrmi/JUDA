//
//  PostsView.swift
//  FinalHrmiProjects
//
//  Created by 홍세희 on 2024/01/24.
//

import SwiftUI

import SwiftUI

struct PostsView: View {
	
	@State private var segmentIndex = 0
	
	@State private var isLike = false
	@State private var likeCount = 45
	
	var body: some View {
		NavigationStack {
			VStack {
				// 상단 태그 검색바
				SearchBar()
				
				HStack {
					// 인기, 최신 순으로 선택하여 정렬하기 위한 CustomSegment
					CustomTextSegment(segments: PostOrLiked.post,
									  selectedSegmentIndex: $segmentIndex)
					.frame(width: 88)
					
					Spacer()
					
					// TODO: navigationLink 및 navigationDestination을 통한 RecordView 전환 구현
					NavigationLink {
						Text("새글 작성하기")
					} label: {
						Text("새글 작성하기")
							.font(.medium16)
							.foregroundStyle(.mainBlack)
					}
				}
				.padding(20)
				
				// TODO: navigationLink 및 navigationDestination을 통한 RecordDetailView 전환 구현
				ScrollView {
					LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
						ForEach(0..<12, id: \.self) { _ in
							NavigationLink {
//								PostDetailView(isLike: $isLike, likeCount: $likeCount)
							} label: {
								PostCell(isLike: $isLike, likeCount: $likeCount)
							}
							.buttonStyle(EmptyActionStyle())
						}
					}
				}
				.padding(.horizontal, 20)
				.scrollIndicators(.hidden)
				.refreshable {
					// TODO: write post data refresh code
				}
			}
		}
	}
}

#Preview {
	PostsView()
}
