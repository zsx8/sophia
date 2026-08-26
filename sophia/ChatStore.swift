//
//  ChatStore.swift
//  sophia
//
//  Created by zs on 26.08.26.
//

import Foundation
import Combine

final class ChatStore: ObservableObject {
    @Published var chats: [ChatSession] = []
    @Published var selectedChatID: UUID?

    private let fileURL: URL = {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return dir.appendingPathComponent("chats.json")
    }()

    init() {
        load()

        if chats.isEmpty {
            let starter = ChatSession(
                title: "New Chat",
                messages: [
                    Message(text: "Hallo! Ich bin dein Deutschlehrer. Wie geht es dir heute?", isUser: false),
                    Message(text: "Hallo! Mir geht es gut, und dir?", isUser: true),
                    Message(text: "Mir geht es auch gut! Was hast du heute gemacht?", isUser: false)
                ]
            )
            chats = [starter]
            selectedChatID = starter.id
            save()
        } else if selectedChatID == nil {
            selectedChatID = chats.first?.id
        }
    }

    func newChat() {
        let chat = ChatSession()
        chats.insert(chat, at: 0)
        selectedChatID = chat.id
        save()
    }

    func deleteChat(_ id: UUID) {
        chats.removeAll { $0.id == id }
        if selectedChatID == id {
            selectedChatID = chats.first?.id
        }
        save()
    }

    func renameChat(_ id: UUID, to newTitle: String) {
        let trimmed = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let index = chats.firstIndex(where: { $0.id == id }) else { return }
        chats[index].title = trimmed
        save()
    }

    func autoTitleIfNeeded(chatID: UUID, from text: String) {
        guard let index = chats.firstIndex(where: { $0.id == chatID }) else { return }
        guard chats[index].title == "New Chat" else { return }
        let words = text.split(separator: " ").prefix(5).joined(separator: " ")
        chats[index].title = words.isEmpty ? "New Chat" : words
    }

    func save() {
        do {
            let data = try JSONEncoder().encode(chats)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("ChatStore save error:", error)
        }
    }

    private func load() {
        do {
            let data = try Data(contentsOf: fileURL)
            chats = try JSONDecoder().decode([ChatSession].self, from: data)
        } catch {
            chats = []
        }
    }
}
