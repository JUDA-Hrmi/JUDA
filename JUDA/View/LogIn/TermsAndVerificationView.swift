//
//  TermsAndVerificationView.swift
//  JUDA
//
//  Created by phang on 2/14/24.
//

import SwiftUI

// MARK: - 개인 정보 활용 동의 체크 or 본인 인증 화면 enum
enum TermsOrVerification {
    case TermsOfService
    case IdentityVerification
}

// MARK: - 신규 회원: 개인 정보 활용 동의 체크 or 본인 인증 화면
struct TermsAndVerificationView: View {
    @State private var viewType: TermsOrVerification = .TermsOfService
    
    var body: some View {
        switch viewType {
        case .TermsOfService:
            UserAgreementView(viewType: $viewType)
        case .IdentityVerification:
            IdentityVerificationView(viewType: $viewType)
        }
    }
}

#Preview {
    TermsAndVerificationView()
}
