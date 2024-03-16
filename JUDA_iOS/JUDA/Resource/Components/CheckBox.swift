//
//  CheckBox.swift
//  JUDA
//
//  Created by phang on 2/9/24.
//

import SwiftUI

// MARK: - 술상 신고하는 화면 체크 박스
struct CheckBox: View {
    let isCheck: Bool
    
    var body: some View {
        Image(systemName: "checkmark.square.fill")
            .font(.medium26)
            .foregroundStyle(isCheck ? .mainAccent03 : .gray04)
    }
}

#Preview {
    CheckBox(isCheck: true)
}
