//
//  ChatDetailView.swift
//  sophia
//
//  Created by zs on 26.08.26.
//

import Foundation
import SwiftUI

struct ChatDetailView: View {
    @Binding var chat: ChatSession
    @ObservedObject var store: ChatStore

    @State private var inputText: String = ""
    @State private var isSending = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(chat.messages) { message in
                            ChatBubbleView(message: message)
                                .id(message.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: chat.messages.count) { _ in
                    if let lastMessage = chat.messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }

            Divider()

            HStack(spacing: 12) {
                TextField("Write in German or English...", text: $inputText)
                    .textFieldStyle(.roundedBorder)

                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .font(.title2)
                        .foregroundStyle(inputText.trimmingCharacters(in: .whitespaces).isEmpty ? .gray : .blue)
                }
                .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding()
            .background(Color(.systemBackground))
        }
        .navigationTitle(chat.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func sendMessage() {
        let trimmedText = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }

        let chatID = chat.id
        let newMessage = Message(text: trimmedText, isUser: true)
        chat.messages.append(newMessage)
        store.autoTitleIfNeeded(chatID: chatID, from: trimmedText)
        store.save()

        let historySnapshot = chat.messages
        inputText = ""
        isSending = true

        Task {
            do {
                let replyText = try await HuggingFaceService.shared.sendMessage(history: historySnapshot)
                await MainActor.run {
                    appendReply(replyText, to: chatID)
                    isSending = false
                }
            } catch {
                await MainActor.run {
                    appendReply("Entschuldigung.", to: chatID)
                    isSending = false
                    print("HF error:", error)
                }
            }
        }
    }

    private func appendReply(_ text: String, to chatID: UUID) {
        guard let index = store.chats.firstIndex(where: { $0.id == chatID }) else { return }
        store.chats[index].messages.append(Message(text: text, isUser: false))
        store.save()
    }
}

// Custom View for Individual Chat Bubbles
struct ChatBubbleView: View {
    let message: Message

    var body: some View {
        Text(message.text)
            .padding(12)
            .background(message.isUser ? Color.blue : Color(.secondarySystemBackground))
            .foregroundColor(message.isUser ? .white : .primary)
            .cornerRadius(16)
            .frame(maxWidth: .infinity, alignment: message.isUser ? .trailing : .leading)
    }
}
