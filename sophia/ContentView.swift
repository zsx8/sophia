//
//  ContentView.swift
//  sophia
//
//  Created by zs on 23.08.26.
//

import SwiftUI

struct ContentView: View {

    @State private var messages: [Message] = [
        Message(
            text: "Hallo! Ich bin dein Deutschlehrer. Wie geht es dir heute?",
            isUser: false
        ),
        Message(
            text: "Hallo! Mir geht es gut, und dir?",
            isUser: true
        ),
        Message(
            text: "Mir geht es auch gut! Was hast du heute gemacht?",
            isUser: false
        )
    ]

    @State private var inputText: String = ""
    @State private var isSending = false

    var body: some View {
        VStack(spacing: 0) {
            // Header Bar
            HStack {
                Text("sophia")
                    .font(.headline)
                    .fontWeight(.bold)
                    .italic()
                Spacer()
            }
            .padding()
            .background(Color(.systemGroupedBackground))

            Divider()

            // Chat Messages List
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(messages) { message in
                            ChatBubbleView(message: message)
                                .id(message.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: messages.count) { _ in
                    if let lastMessage = messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }

            Divider()

            // Bottom Input Controls Bar
            HStack(spacing: 12) {
                
                // Text Field for input msg
                TextField("Write in German or English...", text: $inputText)
                    .textFieldStyle(.roundedBorder)

                // Send Button
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
    }

    private func sendMessage() {
        let trimmedText = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }

        // Add user message
        let newMessage = Message(text: trimmedText, isUser: true)
        messages.append(newMessage)
        inputText = ""
        isSending = true

        Task {
            do {
                let replyText = try await HuggingFaceService.shared.sendMessage(history: messages)
                await MainActor.run {
                    messages.append(Message(text: replyText, isUser: false))
                    isSending = false
                }
            } catch {
                await MainActor.run {
                    messages.append(Message(text: "Entschuldigung.", isUser: false))
                    isSending = false
                    print("HF error:", error)
                }
            }
        }
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

#Preview {
    ContentView()
}
