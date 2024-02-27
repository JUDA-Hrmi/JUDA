//
//  AiWellMatchViewModel.swift
//  JUDA
//
//  Created by 백대홍 on 2/14/24.
//

import SwiftUI
import OpenAI
import Firebase
import FirebaseFirestore

struct AiWellMatchModel: Decodable {
    let openai: String
}


class AiWellMatchViewModel: ObservableObject {
    var openAI: OpenAI?
    @Published var respond = ""
    @State private var lastAPICallTimestamp: Date? = nil
    @State private var isLoading = false
    
    init() {
        guard let url = Bundle.main.url(forResource: "APIKEYS", withExtension: "plist") else { return }
        do {
            let data = try Data(contentsOf: url)
            let keys = try PropertyListDecoder().decode(AiWellMatchModel.self, from: data)
            openAI = OpenAI(apiToken: keys.openai)
        } catch {
            //"Decoding error: \(error)".debug()
            print("Decoding error")
        }
    }
    
    @MainActor
    func request(prompt: String) async throws -> String {
        let query = ChatQuery(model: .gpt3_5Turbo_16k, messages: [
            Chat(role: .system, content: "Please recommend various kinds of snacks from around the world to match the alcohol. Please three answer in one word using Korean. if you Don't know about drink then just recommend commonly food"),
            Chat(role: .assistant, content: "피자, 갈릭 쉬림프, 타코"),
            Chat(role: .assistant, content: "찜닭, 감바스, 소고기 구이"),
            Chat(role: .user, content: prompt),
        ])

        do {
            let result = try await openAI?.chats(query: query)
            respond = result?.choices.first?.message.content ?? ""
            return respond

        } catch {
            print("AI error: \(error)")
            throw error
        }

    }
    
    @MainActor
    func fetchRecommendationsIfNeeded(prompt: String) {
           guard fetchTimeInterval() else { return }
           Task {
               do {
                   isLoading = true
                   respond = try await request(prompt: prompt)
                   lastAPICallTimestamp = Date()
               } catch {
                   print("Error fetching recommendations: \(error)")
               }
               isLoading = false
           }
       }
       
       private func fetchTimeInterval() -> Bool {
           guard let lastTimestamp = lastAPICallTimestamp else {
               return true
           }
           
           let currentTime = Date()
           let timeDifference = currentTime.timeIntervalSince(lastTimestamp)
           let minimumTimeDifference: TimeInterval = 300
           
           return timeDifference >= minimumTimeDifference
       }
}

