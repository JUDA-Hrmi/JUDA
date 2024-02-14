//
//  DrinkDummyData.swift
//  JUDA
//
//  Created by phang on 2/12/24.
//

import Foundation

// MARK: - 술의 카테고리
enum DrinkType: String {
    case all = "전체"
    case korean = "전통주"
    case beer = "맥주"
    case wine = "와인"
    case whiskey = "위스키"
}

// MARK: - Drink Dummy Data

// all
struct Drinks {
    static let sampleData: [Drink] = [
        Korean.koreanSample01, Korean.koreanSample02,
        Wine.wineSample01, Wine.wineSample02,
        Whiskey.whiskeySample01, Whiskey.whiskeySample02,
        Beer.beerSample01, Beer.beerSample02,
        Wine.wineSample01, Wine.wineSample02,
        Whiskey.whiskeySample01, Whiskey.whiskeySample02,
        Beer.beerSample01, Beer.beerSample02,
        Korean.koreanSample01, Korean.koreanSample02,
        Whiskey.whiskeySample01, Whiskey.whiskeySample02,
        Beer.beerSample01, Beer.beerSample02,
        Korean.koreanSample01, Korean.koreanSample02,
    ]
    
    static let koreanSample: [Korean] = [
        .koreanSample01, .koreanSample02, .koreanSample02, .koreanSample01,
        .koreanSample01, .koreanSample02, .koreanSample01, .koreanSample02,
        .koreanSample02, .koreanSample02, .koreanSample02, .koreanSample01,
    ]
    
    static let wineSample: [Wine] = [
        .wineSample01, .wineSample01, .wineSample02, .wineSample01,
        .wineSample02, .wineSample02, .wineSample01, .wineSample01,
        .wineSample02
    ]
    
    static let whiskeySample: [Whiskey] = [
        .whiskeySample02, .whiskeySample02, .whiskeySample01, .whiskeySample02
    ]
    
    static let beerSample: [Beer] = [
        .beerSample01, .beerSample02, .beerSample02, .beerSample01
    ]
}

// 술
protocol Drink {
    var id: UUID { get }
    var drinkType: DrinkType { get }
    var name: String { get }
    var image: String { get }
    var country: String { get }
    var type: String { get }
    var price: Int? { get }
    var abv: Double { get }
    var amount: String { get }
    var numberOfTagged: Int { get }
    var rating: Double { get }
    var wellMatched: [String]? { get }
}

// 전통주
struct Korean: Drink {
    let id = UUID()             // id
    let drinkType = DrinkType.korean
    let name: String            // 이름
    let image: String           // 이미지
    let country: String         // 제조사
    let type: String            // 세부 종류
    let abv: Double             // 도수
    let price: Int?             // 가격
    let amount: String          // 용량
    let rating: Double          // 평점
    let sweet: Int?             // 당도
    let sour: Int?              // 산도
    let refresh: Int?           // 청량감
    let body: Int?              // 바디감
    let carbonated: Int         // 탄산
    let material: [String]      // 재료
    let wellMatched: [String]?  // 어울리는 음식
    let numberOfTagged: Int     // 태그된 게시물 수
    
    static let koreanSample01 = Korean(
        name: "33JU", image: "jinro", country: "33가", type: "증류주", abv: 18,
        price: 30000, amount: "200ml", rating: 3.4,
        sweet: 3, sour: nil, refresh: nil, body: 1, carbonated: 0,
        material: ["산양산삼", "주정", "결정과당", "효소처리스테비아", "에리스리톨", "호박산", "꿀"], wellMatched: ["육사시미", "소고기구이", "회"], numberOfTagged: 10)
    
    static let koreanSample02 = Korean(
        name: "문경주조오미자생막걸리", image: "jipyeong", country: "문경주조", type: "탁주", abv: 6.5,
        price: 2500, amount: "750ml", rating: 3.8,
        sweet: 2, sour: 3, refresh: 2, body: 4, carbonated: 1,
        material: ["정제수", "백미", "입국", "올리고당", "물엿", "허브", "오미자", "정제효소", "아스파탐"], wellMatched: ["해산물 전골", "고기국수", "치즈 플레이터"], numberOfTagged: 14)
}

// 와인
struct Wine: Drink {
    let id = UUID()             // id
    let drinkType = DrinkType.wine
    let name: String            // 이름
    let image: String           // 이미지
    let country: String         // 국가
    let province: String        // 원산지
    let type: String            // 세부 종류
    let abv: Double             // 도수
    let price: Int?             // 가격
    let amount: String          // 용량
    let rating: Double          // 평점
    let wellMatched: [String]?  // 어울리는 음식
    let aroma: [String]?        // 향
    let taste: [String]?        // 맛
    let finish: [String]?       // 여운
    let numberOfTagged: Int     // 태그된 게시물 수

    static let wineSample01 = Wine(
        name: "트리폴라 피에몬테 로쏘", image: "jibibbo", country: "이탈리아", province: "피에몬테", type: "레드",
        abv: 13.5, price: 68000, amount: "750ml", rating: 4.2,
        wellMatched: ["피자", "파스타", "치즈 플레이트"], aroma: ["다채로운 꽃, 오디"], taste: ["낮은 산도와 당도, 부드러운 탄닌"], finish: nil, numberOfTagged: 34)
    
    static let wineSample02 = Wine(
        name: "엘리자베스 로제 샤도네이", image: "jibibbo", country: "미국", province: "캘리포니아", type: "화이트",
        abv: 13.5, price: 135000, amount: "750ml", rating: 4.4,
        wellMatched: ["치즈", "해산물", "샐러드"], aroma: ["하얀 배", "리치", "애플리콧", "시트러스"], taste: ["따뜻한 산미"], finish: ["깔끔한, 부드러운"], numberOfTagged: 124)
}

// 위스키
struct Whiskey: Drink {
    let id = UUID()             // id
    let drinkType = DrinkType.whiskey
    let name: String            // 이름
    let image: String           // 이미지
    let country: String         // 국가
    let type: String            // 세부 종류
    let abv: Double             // 도수
    let price: Int?             // 가격
    let amount: String          // 용량
    let rating: Double          // 평점
    let wellMatched: [String]?  // 어울리는 음식
    let aroma: [String]?        // 향
    let taste: [String]?        // 맛
    let finish: [String]?       // 여운
    let numberOfTagged: Int     // 태그된 게시물 수

    static let whiskeySample01 = Whiskey(
        name: "맥캘란 10년 Full Proof 57% 1980", image: "glenallachie", country: "스코틀랜드", type: "싱글몰트", abv: 57.0,
        price: 3516000, amount: "750ml", rating: 4.5,
        wellMatched: ["안티파스토", "카프레제", "갈비찜", "해산물", "캐비어"], aroma: ["드라이", "커피", "자두", "견과류"], taste: ["스파이시", "달콤한", "씁쓸한"], finish: ["스파이시", "크리미", "산미"], numberOfTagged: 33)
    
    static let whiskeySample02 = Whiskey(
        name: "발베니 툰 1401 all batches", image: "glenallachie", country: "스코틀랜드", type: "싱글몰트", abv: 50.3,
        price: 2868000, amount: "750ml", rating: 4.6,
        wellMatched: nil, aroma: ["꿀", "꽃", "오렌지 제스트", "나무 오일", "초콜릿 푸딩"], taste: ["꿀", "밀랍", "헤이즐넛 버터", "오렌지 오일"], finish: ["긴 여운", "드라이", "말린 잎", "달콤한"], numberOfTagged: 54)
}

// 맥주
struct Beer: Drink {
    let id = UUID()             // id
    let drinkType = DrinkType.beer
    let name: String            // 이름
    let image: String           // 이미지
    let country: String         // 국가
    let type: String            // 세부 종류
    let abv: Double             // 도수
    let price: Int?             // 가격
    let amount: String          // 용량
    let rating: Double          // 평점
    let wellMatched: [String]?  // 어울리는 음식
    let aroma: [String]?        // 향
    let taste: [String]?        // 맛
    let finish: [String]?       // 여운
    let numberOfTagged: Int     // 태그된 게시물 수

    static let beerSample01 = Beer(
        name: "크로넨버그 1664 블랑", image: "canuca", country: "프랑스", type: "에일", abv: 5.0,
        price: 4000, amount: "500ml", rating: 4.0,
        wellMatched: ["해산물 스튜", "아보카도 샐러드", "새우 알리오 올리오"], aroma: ["감귤", "레몬", "고수풀", "몰트"], taste: ["새콤한", "달콤한", "쌉쌀한"], finish: ["부드러운", "매콤한"], numberOfTagged: 72)
    
    static let beerSample02 = Beer(
        name: "말표 청포도 에일", image: "canuca", country: "한국", type: "과일", abv: 4.0,
        price: 3500, amount: "500ml", rating: 3.3,
        wellMatched: ["치즈 플레이터", "샐러드", "해산물 요리"], aroma: ["청포도", "몰트"], taste: ["가벼운", "달콤한", "쌉쌀한"], finish: ["달콤한", "가벼운"], numberOfTagged: 9)
}
