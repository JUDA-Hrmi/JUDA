//
//  AIService.swift
//  FinalHrmiProjects
//
//  Created by 백대홍 on 2/7/24.
//

import SwiftUI
import OpenAI

// MARK: - AI Service
@MainActor
final class AIService {
    private var openAI: OpenAI?
    
    init() {
        guard let url = Bundle.main.url(forResource: "APIKEYS", withExtension: "plist") else { return }
        do {
            let data = try Data(contentsOf: url)
            let keys = try PropertyListDecoder().decode(AIModel.self, from: data)
            openAI = OpenAI(apiToken: keys.openai)
        } catch {
            print("error :: Decoding error", error.localizedDescription)
        }
    }
    
    // 프롬프트 request 함수
    func request(weatherString: String) async throws -> String {
        let prompt = "\(weatherString) Please recommend some snacks and alcoholic beverages that go well with this weather. Please refer to the list that already exists and recommend them in it. I have additional notes on the list. You can recommend one that goes well with the weather from each list. snackslist: \(AIResponseExample.snacks), drink List:\(AIResponseExample.drinkNames)"
        
        let query = ChatQuery(
            model: .gpt3_5Turbo_16k,
            messages: [
                Chat(role: .system, content: "Please be sure to give recommendation answer in one word using Korean, only from each given list. The answer type it must be snack + drink"),
                Chat(role: .assistant, content: "계란찜 + 맥캘란 10년"),
                Chat(role: .assistant, content: "찜닭 + 산토리"),
                Chat(role: .user, content: prompt)
            ]
        )
        do {
            let result = try await openAI?.chats(query: query)
            let respond = result?.choices.first?.message.content ?? ""
            return respond
        } catch {
            print("error :: ai request", error.localizedDescription)
            throw error
        }
    }
}
