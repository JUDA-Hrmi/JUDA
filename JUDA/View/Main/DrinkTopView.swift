//
//  DrinkTopView.swift
//  JUDA
//
//  Created by 백대홍 on 2/25/24.
//

import SwiftUI

struct DrinkTopView: View {
    @Binding var selectedTabIndex: Int
    
    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Text("술상 TOP3")
                    .font(.semibold18)
                
                Spacer()
                
                Button {
                    selectedTabIndex = 1
                } label: {
                    Text("더보기")
                        .foregroundStyle(.gray01)
                        .font(.semibold14)
                }
            }
            Rectangle()
                .frame(height: 138)
                .foregroundStyle(.gray)
        }
    }
}

