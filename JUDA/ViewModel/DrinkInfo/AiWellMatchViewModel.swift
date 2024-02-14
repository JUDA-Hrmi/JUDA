//
//  AiWellMatchViewModel.swift
//  JUDA
//
//  Created by 백대홍 on 2/14/24.
//

import SwiftUI
import OpenAI


struct AiWellMatchModel: Decodable {
    let openai: String
}


class AiWellMatchViewModel: ObservableObject {
    var openAI: OpenAI?
    @Published var respond = ""
    
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
            Chat(role: .system, content: "Please be sure to give recommendation Three answer in one word using Korean"),
            Chat(role: .assistant, content: "피자, 갈릭 쉬림프, 타코"),
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
        print("WellMatched API")
        
    }
}


