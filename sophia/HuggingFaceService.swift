//
//  HuggingFaceService.swift
//  sophia
//

import Foundation

enum HuggingFaceError: Error {
    case invalidResponse
    case apiError(String)
}

private struct ChatCompletionResponse: Codable {
    struct Choice: Codable {
        struct Msg: Codable { let content: String }
        let message: Msg
    }
    let choices: [Choice]
}

final class HuggingFaceService {
    static let shared = HuggingFaceService()
    private init() {}

    private let endpoint = URL(string: "https://router.huggingface.co/v1/chat/completions")!
    private let model = "meta-llama/Llama-3.1-8B-Instruct"

    private let systemPrompt = """
    You are Sophia, a warm, encouraging German tutor chatting with a learner. \
    Continue the conversation naturally in simple, level-appropriate German.
    """

    func sendMessage(history: [Message]) async throws -> String {
        var apiMessages: [[String: String]] = [["role": "system", "content": systemPrompt]]
        for message in history {
            apiMessages.append([
                "role": message.isUser ? "user" : "assistant",
                "content": message.text
            ])
        }

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("Bearer \(Secrets.huggingFaceToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": model,
            "messages": apiMessages,
            "temperature": 0.7,
            "max_tokens": 300
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let errorText = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw HuggingFaceError.apiError(errorText)
        }

        let decoded = try JSONDecoder().decode(ChatCompletionResponse.self, from: data)
        guard let content = decoded.choices.first?.message.content else {
            throw HuggingFaceError.invalidResponse
        }

        return content.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
