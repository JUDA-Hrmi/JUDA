//
//  Bundle +.swift
//  JUDA
//
//  Created by 백대홍 on 2/27/24.
//

import Foundation

extension Bundle {
    
    var apiKey: String {
        guard let filePath = Bundle.main.path(forResource: "APIKEYS", ofType: "plist"),
              let plistDict = NSDictionary(contentsOfFile: filePath) else {
            fatalError("Couldn't find file 'APIKEYS.plist'.")
        }
        guard let value = plistDict.object(forKey: "API_KEY") as? String else {
            fatalError("Couldn't find key 'API_Key' in 'APIKEYS.plist'.")
        }
        
        return value
    }
}
