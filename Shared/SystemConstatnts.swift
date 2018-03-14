//
//  SystemConstatnts.swift
//  Multipeer
//
//  Created by Luiz Felipe Albernaz Pio on 14/03/18.
//  Copyright © 2018 Luiz Felipe Albernaz Pio. All rights reserved.
//

import Foundation

var applicationUUID: String = {
    let uuidKey = "UUID_KEY"
    guard let uuid = UserDefaults.standard.string(forKey: uuidKey) else {
        
        let generatedUUID = UUID().uuidString
        UserDefaults.standard.set(generatedUUID, forKey: uuidKey)
        return generatedUUID
    }
    return uuid
}()
