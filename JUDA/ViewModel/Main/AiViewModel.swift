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
    
    let snacks = [
        "치즈 플래터", "혼합 견과류", "브루스케타", "카프레제 샐러드", "새우 칵테일", "스시", "안티파스토 플래터", "야채 봄롤", "시저 샐러드", "마르게리타 피자",
        "훔모스와 피타 브레드", "데블드 에그", "시금치 아티초크 딥", "치즈 퐁듀", "랍스터 비스크", "굴",
        "프레첼", "팝콘", "칩과 살사", "에다마메", "치킨 윙", "치즈버거 슬라이더", "피쉬 타코", "과아몰레와 토르티야 칩", "오징어 요리", "양파 링",
        "소고기 슬라이더", "슈아꼬테리 플래터", "데블드 에그", "시금치 아티초크 딥", "나쵸", "로드된 포테이토 스킨",
        "파전", "김치", "닭강정", "튀김", "떡볶이", "순대", "오뎅", "잡채", "김밥", "빈대떡", "족발",
        "혼합 견과류", "초콜릿 트러플", "연어 훈제", "소고기 저키", "숙성된 치즈", "다크 초콜릿", "베이컨 감자", "구운 아몬드", "캐비어", "구운 스테이크",
        "과일과 치즈 플래터", "카라멜 팝콘",
        "바비큐", "잡채", "떡볶이", "튀김", "김치전", "파전", "오징어 구이", "김밥", "매운 돼지 불고기", "찐만두", "매운 치킨 윙", "후라이드 치킨", "닭갈비",
        "새우 칵테일", "브루스케타", "치즈 플래터", "스테이크 버섯", "미니 퀴시", "세비체", "조개", "크랩 케이크", "고추 새우", "코코넛 새우", "과일 꼬치",
    ]
    
    let drinkNames = [
        "크로넨버그 1664 로제","말표 청포도 에일","막시모40","맥매니스, 캘리포니아 피노 누아","산토리","1000억유산균막걸리","글렌고인 25년","블루문","발베니 툰","스텔라","엘리자베스 로제 샤도네이","트리폴라 피에몬테 로쏘","맥캘란 10년","문경주조오미자생막걸리","구기홍주14","공주애오디와인","매실향기담은술","백하우스, 피노 누아","매실원주15","1000억걸리프리바이오","33J0","경복궁","내장산복분자주","아케시 로사토 브뤼","크로넨버그 1664 라거","크로넨버그 1664 블랑"
    ]
    
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
            Chat(role: .system, content: "Please be sure to give recommendation answer in one word using Korean, only from each given list."),
            Chat(role: .assistant, content: "계란찜 + 맥캘란 10년"),
            Chat(role: .assistant, content: "찜닭 + 산토리"),
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
}
