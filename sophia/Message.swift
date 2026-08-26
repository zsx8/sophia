//
//  Message.swift
//  sophia
//
//  Created by zs on 23.08.26.
//

import Foundation

struct Message: Identifiable, Codable {
    let id: UUID
    let text: String
    let isUser: Bool // user or AI

    init(id: UUID = UUID(), text: String, isUser: Bool) {
        self.id = id
        self.text = text
        self.isUser = isUser
    }
}
