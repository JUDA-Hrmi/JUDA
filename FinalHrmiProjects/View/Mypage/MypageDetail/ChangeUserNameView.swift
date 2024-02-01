//
//  ChangeUserNameView.swift
//  FinalHrmiProjects
//
//  Created by 백대홍 on 1/31/24.
//

import SwiftUI

struct ChangeUserNameView: View {
	@Environment(\.dismiss) var dismiss
	@FocusState var isFocused: Bool
	@Binding var userNickName: String
	@State private var userChangeNickName: String = ""
	@State private var isCompleted: Bool = true
	
	var body: some View {
		ZStack {
			VStack(alignment: .center, spacing: 15) {
				Text("수정할 닉네임을 작성해주세요")
					.font(.medium16)
					.frame(maxWidth: .infinity, alignment: .leading)
				HStack {
					TextField(userNickName, text: $userChangeNickName)
						.font(.medium16)
						.focused($isFocused)
						.textInputAutocapitalization(.never)
						.onChange(of: userChangeNickName) { _ in
							isCompleted = userChangeNickName.count >= 2
						}
				}
				.padding(.vertical, 15)
				.padding(.horizontal, 10)
				.background(.gray05)
				.clipShape(.rect(cornerRadius: 10))
				
				if isFocused && (userChangeNickName.count <= 1 || userChangeNickName.count > 10) {
					Text("닉네임을 2자~10자 이내로 적어주세요.")
						.font(.light14)
						.foregroundStyle(.mainAccent01)
						.frame(maxWidth: .infinity, alignment: .leading)
				}
				
				Spacer()
				
				CustomDivider()
				
				Button(action: {
					userNickName = userChangeNickName
					dismiss()
				}, label: {
					Text("변경 완료")
						.font(.medium20)
						.frame(maxWidth: .infinity)
						.padding(.vertical, 5)
					
				})
				.disabled(userChangeNickName.isEmpty || userNickName == userChangeNickName)
				.foregroundColor(userChangeNickName.isEmpty || userNickName == userChangeNickName ? .gray01 : .white)
				.buttonStyle(.borderedProminent)
				.tint(.mainAccent03)
			}
			.padding(.vertical, 10)
		}
		.onAppear(perform: UIApplication.shared.addTapGestureRecognizer)
		.padding(.horizontal, 20)
		.navigationBarBackButtonHidden()
		.toolbar {
			ToolbarItem(placement: .topBarLeading) {
				Button {
					dismiss()
				} label: {
					Image(systemName: "chevron.left")
				}
			}
			ToolbarItem(placement: .principal) {
				Text("닉네임 수정")
					.font(.regular16)
			}
		}
		.tint(.mainBlack)
	}
}
