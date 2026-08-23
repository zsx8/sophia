//
//  Message.swift
//  sophia
//
//  Created by zs on 23.08.26.
//

import Foundation

struct Message: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool // user or AI
    let correction: String? // AI correction
    
    init(text: String, isUser: Bool, correction: String? = nil) {
        self.text = text
        self.isUser = isUser
        self.correction = correction
    }
}
