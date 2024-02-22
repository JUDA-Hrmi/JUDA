//
//  AiViewModel.swift
//  FinalHrmiProjects
//
//  Created by 백대홍 on 2/7/24.
//

import SwiftUI
import OpenAI


struct AiModel: Decodable {
    let openai: String
}

class AiViewModel: ObservableObject {
    var openAI: OpenAI?
    var respond = ""
    
    init() {
        guard let url = Bundle.main.url(forResource: "APIKEYS", withExtension: "plist") else { return }
        
        do {
            let data = try Data(contentsOf: url)
            let keys = try PropertyListDecoder().decode(AiModel.self, from: data)
            openAI = OpenAI(apiToken: keys.openai)
        } catch {
            //"Decoding error: \(error)".debug()
            print("Decoding error")
        }
    }
    
    // 프롬프트 request 함수
    func request(prompt: String) async throws -> String {
        let query = ChatQuery(model: .gpt3_5Turbo_16k, messages: [
            Chat(role: .system, content: "Please be sure to give recommendation answer in one word using Korean, only from each given list.And please print them out as 술 + 안주"),
            Chat(role: .assistant, content: "카스 + 계란찜"),
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
    
    
    

    // 술 + 안주 respond 분리 함수
    private func parseAndSetResponse(_ response: String) {
        let components = response.components(separatedBy: " ")
        guard components.count == 4 else {
            print("Invalid response format")
            return
        }
        
        let drink = components[1]
        let dish = components[3]
        
        respond = "술: \(drink) + 안주: \(dish)"
        print(respond)
    }

}



class AiTodayViewModel: ObservableObject {
    var openAI: OpenAI?
    @Published var respondToday = ""
    
    init() {
        guard let url = Bundle.main.url(forResource: "APIKEYS", withExtension: "plist") else { return }
        
        do {
            let data = try Data(contentsOf: url)
            let keys = try PropertyListDecoder().decode(AiModel.self, from: data)
            openAI = OpenAI(apiToken: keys.openai)
        } catch {
            //"Decoding error: \(error)".debug()
            print("Decoding error")
        }
    }
    // Firebase에서 가져온 음료 정보를 AI 모델에 전달
    // 프롬프트 request 함수
    @MainActor
    func requestToday (prompt: String) async throws -> String {
        let query = ChatQuery(model: .gpt3_5Turbo_16k, messages: [
            Chat(role: .system, content: "Please be sure to give recommendation answer in three word using Korean in once, only from each given list.And please print them out as three alcohol drink"), // with json type
            Chat(role: .assistant, content: "카스, 블랑, 경복궁"),
            Chat(role: .assistant, content: "카발란 셰리, 구미호, 카스"),
            Chat(role: .user, content: prompt),
        ])
        
        do {
            let result = try await openAI?.chats(query: query)
            respondToday = result?.choices.first?.message.content ?? ""
            return respondToday
        } catch {
            print("AI error: \(error)")
            throw error
        }
    }
    
//    func parseAndSetResponse(_ response: String) {
//          let components = response.components(separatedBy: " ")
//          guard components.count == 3 else {
//              print("Invalid response format")
//              return
//          }
//          
//          respondToday = response
//      }
}

    
    
    
    

