//
//  LogInView.swift
//  FinalHrmiProjects
//
//  Created by 홍세희 on 2024/01/24.
//


import SwiftUI

struct LogInView: View {
    @Environment(\.colorScheme) var scheme  //다크모드 + 라이트모드 동시 대응
        //Components -> Theme 파일 참고
    var body: some View {
        // MARK: - 상위 뷰
        ZStack {
            Theme.backgroundColor(scheme: scheme)
            VStack {
                VStack {
                    Image("appIcon")
                        .resizable()
                        .frame(width: 289, height: 250)
                    
                    Text("HrMi")
                        .font(.regular20)
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 70)
                
                // MARK: - 로그인 버튼 나열뷰
                VStack(spacing: 30) {
                    
                    Image("applelogin")
                        .resizable()
                        .frame(width: 300, height: 48)
                        .aspectRatio(contentMode: .fit)
                    
                    Image("Google")
                        .resizable()
                        .frame(width: 300, height: 48)
                        .aspectRatio(contentMode: .fit)
                    
                    Image("Kakao")
                        .resizable()
                        .frame(width: 300, height: 48)
                        .aspectRatio(contentMode: .fit)
                }
                Spacer()
                
                // MARK: - 하위뷰
                Text("2024, HrMi all rights reserved.\nPowered by PJ3T7_HrMi")
                    .font(.medium14)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

#Preview {
    LogInView()
}
