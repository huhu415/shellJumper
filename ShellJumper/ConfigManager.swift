import Combine
import Foundation
import SwiftUI

@MainActor
class ConfigManager: ObservableObject {
    static let shared = ConfigManager()

    @Published var terminal: Terminal {
        didSet { save() }
    }

    private let configURL = FileManager.default
        .homeDirectoryForCurrentUser
        .appendingPathComponent(".config/shelljumper/config.yaml")

    private init() {
        // 加载配置，失败就用默认值
        if let data = try? Data(contentsOf: configURL),
           let yaml = String(data: data, encoding: .utf8),
           let saved = Terminal(rawValue: yaml.trimmingCharacters(in: .whitespacesAndNewlines))
        {
            terminal = saved
        } else {
            terminal = .terminal
        }
    }

    private func save() {
        try? FileManager.default.createDirectory(
            at: configURL.deletingLastPathComponent(),
            withIntermediateDirectories: true,
        )
        try? terminal.rawValue.write(to: configURL, atomically: true, encoding: .utf8)
    }
}
