//
//  PeferenceChart.swift
//  JUDA
//
//  Created by phang on 1/30/24.
//

import SwiftUI

// MARK: - 원형 차트 구조체
struct PieModel: Identifiable {
    var type: String
    var count: Double
    var color: Color
    var id = UUID()
}

// MARK: - 선호도 차트
struct PeferenceChart: View {
    let ageGroupPieData: [PieModel]
    let genderGroupPieData: [PieModel]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Preferences
            Text("선호도 차트")
                .font(.semibold18)
                .frame(maxWidth: .infinity, alignment: .leading)
            // 차트
            HStack(alignment: .center) {
                // 연령별
                HStack(alignment: .bottom, spacing: 10) {
                    // 차트 설명
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(ageGroupPieData) { data in
                            HStack(alignment: .center, spacing: 4) {
                                ZStack {
                                    // DarkMode 에서 color opacity 로 인해 색이 어두워지는 것을 방지
                                    Circle()
                                        .fill(.white)
                                        .frame(width: 10)
                                    Circle()
                                        .fill(data.color)
                                        .frame(width: 10)
                                }
                                Text(data.type)
                                    .font(.light12)
                            }
                        }
                    }
                    // 차트
                    ZStack {
                        // DarkMode 에서 color opacity 로 인해 색이 어두워지는 것을 방지
                        Circle()
                            .fill(.white)
                            .frame(width: 100 * 0.96) // 0.48 로 설정 된 길이에 맞춰 0.96 으로 프레임 설정
                        Canvas { context, size in
                            let total = ageGroupPieData.reduce(0) { $0 + $1.count }
                            context.translateBy(x: size.width * 0.5, y: size.height * 0.5)
                            var pieContext = context
                            pieContext.rotate(by: .degrees(-90))
                            let radius = min(size.width, size.height) * 0.48
                            var startAngle = Angle.zero
                            for model in ageGroupPieData {
                                let angle = Angle(degrees: 360 * (model.count / total))
                                let endAngle = startAngle + angle
                                let path = Path { p in
                                    p.move(to: .zero)
                                    p.addArc(center: .zero, radius: radius,
                                             startAngle: startAngle, endAngle: endAngle, clockwise: false)
                                    p.closeSubpath()
                                }
                                pieContext.fill(path, with: .color(model.color))
                                startAngle = endAngle
                            }
                        }
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                    }
                }
                Spacer()
                // 성별
                HStack(alignment: .bottom, spacing: 10) {
                    // 차트 설명
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(genderGroupPieData) { data in
                            HStack(alignment: .center, spacing: 4) {
                                ZStack {
                                    // DarkMode 에서 color opacity 로 인해 색이 어두워지는 것을 방지
                                    Circle()
                                        .fill(.white)
                                        .frame(width: 10)
                                    Circle()
                                        .fill(data.color)
                                        .frame(width: 10)
                                }
                                Text(data.type)
                                    .font(.light12)
                            }
                        }
                    }
                    // 차트
                    ZStack {
                        // DarkMode 에서 color opacity 로 인해 색이 어두워지는 것을 방지
                        Circle()
                            .fill(.white)
                            .frame(width: 100 * 0.96) // 0.48 로 설정 된 길이에 맞춰 0.96 으로 프레임 설정
                        Canvas { context, size in
                            let total = genderGroupPieData.reduce(0) { $0 + $1.count }
                            context.translateBy(x: size.width * 0.5, y: size.height * 0.5)
                            var pieContext = context
                            pieContext.rotate(by: .degrees(-90))
                            let radius = min(size.width, size.height) * 0.48
                            var startAngle = Angle.zero
                            for model in genderGroupPieData {
                                let angle = Angle(degrees: 360 * (model.count / total))
                                let endAngle = startAngle + angle
                                let path = Path { p in
                                    p.move(to: .zero)
                                    p.addArc(center: .zero, radius: radius,
                                             startAngle: startAngle, endAngle: endAngle, clockwise: false)
                                    p.closeSubpath()
                                }
                                pieContext.fill(path, with: .color(model.color))
                                startAngle = endAngle
                            }
                        }
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
}
