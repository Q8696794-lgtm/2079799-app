import Foundation

nonisolated struct DeepSeekMessage: Codable, Sendable {
    let role: String
    let content: String
}

nonisolated struct DeepSeekRequest: Codable, Sendable {
    let model: String
    let messages: [DeepSeekMessage]
    let stream: Bool
    let temperature: Double
    let max_tokens: Int
}

nonisolated struct DeepSeekChoice: Codable, Sendable {
    let message: DeepSeekMessage?
    let delta: DeepSeekDelta?
    let finish_reason: String?
}

nonisolated struct DeepSeekDelta: Codable, Sendable {
    let role: String?
    let content: String?
}

nonisolated struct DeepSeekResponse: Codable, Sendable {
    let choices: [DeepSeekChoice]
}

class DeepSeekService {
    static let shared = DeepSeekService()
    private let baseURL = "https://api.deepseek.com/chat/completions"

    private var apiKey: String {
        Config.DEEPSEEK_API_KEY
    }

    func streamChat(messages: [DeepSeekMessage]) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task.detached { [baseURL, apiKey] in
                guard !apiKey.isEmpty else {
                    continuation.finish(throwing: NSError(domain: "DeepSeek", code: -1, userInfo: [NSLocalizedDescriptionKey: "API key not configured"]))
                    return
                }

                var request = URLRequest(url: URL(string: baseURL)!)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

                let body = DeepSeekRequest(
                    model: "deepseek-chat",
                    messages: messages,
                    stream: true,
                    temperature: 0.8,
                    max_tokens: 2048
                )
                request.httpBody = try? JSONEncoder().encode(body)

                do {
                    let (bytes, response) = try await URLSession.shared.bytes(for: request)
                    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                        continuation.finish(throwing: NSError(domain: "DeepSeek", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "API error: HTTP \(statusCode)"]))
                        return
                    }

                    for try await line in bytes.lines {
                        guard line.hasPrefix("data: ") else { continue }
                        let jsonStr = String(line.dropFirst(6))
                        if jsonStr == "[DONE]" { break }
                        guard let data = jsonStr.data(using: .utf8),
                              let chunk = try? JSONDecoder().decode(DeepSeekResponse.self, from: data),
                              let content = chunk.choices.first?.delta?.content else { continue }
                        continuation.yield(content)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    func chat(messages: [DeepSeekMessage]) async throws -> String {
        guard !apiKey.isEmpty else {
            throw NSError(domain: "DeepSeek", code: -1, userInfo: [NSLocalizedDescriptionKey: "API key not configured"])
        }

        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let body = DeepSeekRequest(
            model: "deepseek-chat",
            messages: messages,
            stream: false,
            temperature: 0.8,
            max_tokens: 2048
        )
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            throw NSError(domain: "DeepSeek", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "API error: HTTP \(statusCode)"])
        }

        let result = try JSONDecoder().decode(DeepSeekResponse.self, from: data)
        return result.choices.first?.message?.content ?? ""
    }
}
