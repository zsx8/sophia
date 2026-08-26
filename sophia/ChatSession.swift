//
//  ChatSession.swift
//  sophia
//
//  Created by zs on 26.08.26.
//

import Foundation

struct ChatSession: Identifiable, Codable {
    let id: UUID
    var title: String
    var messages: [Message]
    var createdAt: Date

    init(
        id: UUID = UUID(),
        title: String = "New Chat",
        messages: [Message] = [],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.messages = messages
        self.createdAt = createdAt
    }
}
