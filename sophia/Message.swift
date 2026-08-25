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

    init(text: String, isUser: Bool) {
        self.text = text
        self.isUser = isUser
    }
}
