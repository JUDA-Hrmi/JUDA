//
//  AIWellMatchViewModel.swift
//  JUDA
//
//  Created by 백대홍 on 2/14/24.
//

import SwiftUI
import OpenAI
import Firebase
import FirebaseFirestore

// MARK: - Drink Detail 에서 사용하는 AI Well Match View Model
@MainActor
final class AIWellMatchViewModel: ObservableObject {
    @Published var respond = ""
    @Published var isLoading = false
    private var openAI: OpenAI?
    
    init() {
        guard let url = Bundle.main.url(forResource: "APIKEYS", withExtension: "plist") else { return }
        do {
            let data = try Data(contentsOf: url)
            let keys = try PropertyListDecoder().decode(AIModel.self, from: data)
            openAI = OpenAI(apiToken: keys.openai)
        } catch {
            print("error :: AIWellMatchViewModel init", error.localizedDescription)
        }
    }
    
    func fetchRecommendationsIfNeeded(drinkName: String) async {
        let prompt = "Please recommend three foods that go well with drinks. Only food except drinks. List below --- Beverages List: \(drinkName)"
        isLoading = true
        do {
            respond = try await request(prompt: prompt)
        } catch {
            print("error :: fetchRecommendationsIfNeeded", error.localizedDescription)
        }
        isLoading = false
    }
    
    private func request(prompt: String) async throws -> String {
        let query = ChatQuery(
            model: .gpt3_5Turbo_16k,
            messages: [
                Chat(role: .system, content: "Please recommend various kinds of snacks from around the world to match the alcohol. Please three answer in one word using Korean. if you Don't know about drink then just recommend commonly food"),
                Chat(role: .assistant, content: "피자, 갈릭 쉬림프, 타코"),
                Chat(role: .assistant, content: "찜닭, 감바스, 소고기 구이"),
                Chat(role: .user, content: prompt),
            ]
        )
        do {
            let result = try await openAI?.chats(query: query)
            respond = result?.choices.first?.message.content ?? ""
            return respond
        } catch {
            print("error :: AIWellMatchViewModel request", error.localizedDescription)
            throw error
        }
    }
}

