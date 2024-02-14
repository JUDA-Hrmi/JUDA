import SwiftUI

struct WellMatched: View {
    @EnvironmentObject var aiWellMatchViewModel: AiWellMatchViewModel
    let drink = [
        "트리폴라 피에몬테 로쏘"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Well Matched
            HStack(alignment: .lastTextBaseline, spacing: 10) {
                Text("잘 어울리는 음식")
                    .font(.semibold18)
                Text("AI 추천 ✨")
                    .font(.semibold16)
                    .foregroundStyle(.mainAccent05)
            }
            // 추천 받은 음식
            HStack(alignment: .center, spacing: 16) {
                if let wellMatchedResponse = UserDefaults.standard.string(forKey: "WellMatchedResponse") {
                    Text("\(wellMatchedResponse)")
                    
                } else {
                    Text(aiWellMatchViewModel.respond)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .onAppear {
            Task {
                do {
                    aiWellMatchViewModel.respond = try await aiWellMatchViewModel.request(prompt: "Please recommend 3 foods that go well with you. Only food except drinks. List below --- Beverages List: \(drink)")
                    print("\(aiWellMatchViewModel.respond)")
                    
                    // Save the response to UserDefaults
                    UserDefaults.standard.set(aiWellMatchViewModel.respond, forKey: "WellMatchedResponse")
                } catch {
                    print("Error fetching recommendations: \(error)")
                }
            }
            
            // Retrieve the saved response from UserDefaults
            if let wellMatchedResponse = UserDefaults.standard.string(forKey: "WellMatchedResponse") {
                // Use the retrieved response if needed
                print("WellMatched Response: \(wellMatchedResponse)")
            }
            
            print("onappear call")
        }
    }
}
