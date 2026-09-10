#!/usr/bin/env swift
//
// macos-defaults
//
// macOS の `defaults write` 設定を Swift で宣言的に管理する。
// bash の一行 `defaults write ...` の羅列だと差分が読みにくいので、
// 「どのドメインの、どのキーを、どんな値にするか」を配列で一覧化し、
// 適用後に対象アプリ（Dock/Finder等）を再起動するところまでまとめて行う。
//
// 実行: bin/macos-defaults
// (bin/setup から自動で呼ばれる)

import Foundation

enum DefaultsType: String {
    case bool = "-bool"
    case int = "-int"
    case float = "-float"
    case string = "-string"
}

struct Setting {
    let domain: String   // 例: "com.apple.dock", "NSGlobalDomain"
    let key: String
    let type: DefaultsType
    let value: String
    let comment: String
}

// --- 設定一覧 -----------------------------------------------------------
// ここに追記していく。値を変えたら再実行すれば上書きされる（冪等）。

let settings: [Setting] = [
    // Dock
    Setting(domain: "com.apple.dock", key: "autohide", type: .bool, value: "true",
             comment: "Dockを自動的に隠す"),
    Setting(domain: "com.apple.dock", key: "show-recents", type: .bool, value: "false",
             comment: "最近使った項目をDockに表示しない"),
    Setting(domain: "com.apple.dock", key: "tilesize", type: .int, value: "44",
             comment: "Dockのアイコンサイズ"),

    // Finder
    Setting(domain: "com.apple.finder", key: "AppleShowAllExtensions", type: .bool, value: "true",
             comment: "すべてのファイル拡張子を表示"),
    Setting(domain: "com.apple.finder", key: "ShowPathbar", type: .bool, value: "true",
             comment: "パスバーを表示"),
    Setting(domain: "com.apple.finder", key: "ShowStatusBar", type: .bool, value: "true",
             comment: "ステータスバーを表示"),
    Setting(domain: "com.apple.finder", key: "FXEnableExtensionChangeWarning", type: .bool, value: "false",
             comment: "拡張子変更時の警告を無効化"),

    // Keyboard
    Setting(domain: "NSGlobalDomain", key: "KeyRepeat", type: .int, value: "2",
             comment: "キーリピート速度を最速に近づける"),
    Setting(domain: "NSGlobalDomain", key: "InitialKeyRepeat", type: .int, value: "15",
             comment: "キーリピート開始までの待ち時間を短縮"),
    Setting(domain: "NSGlobalDomain", key: "ApplePressAndHoldEnabled", type: .bool, value: "false",
             comment: "長押しでのアクセント候補ではなくキーリピートを優先"),

    // Screenshot
    Setting(domain: "com.apple.screencapture", key: "disable-shadow", type: .bool, value: "true",
             comment: "スクリーンショットにウィンドウの影を含めない"),
]

// 設定適用後に再起動が必要なアプリ（domain -> 再起動対象プロセス名）
let restartTargets: [String: String] = [
    "com.apple.dock": "Dock",
    "com.apple.finder": "Finder",
]

// --- 適用処理 -------------------------------------------------------------

func run(_ command: String, _ args: [String]) {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: command)
    process.arguments = args
    do {
        try process.run()
        process.waitUntilExit()
    } catch {
        print("  ✗ failed to run \(command) \(args.joined(separator: " ")): \(error)")
    }
}

print("==> Applying macOS defaults...")

var touchedDomains = Set<String>()

for setting in settings {
    run("/usr/bin/defaults", ["write", setting.domain, setting.key, setting.type.rawValue, setting.value])
    print("  ✓ \(setting.domain) \(setting.key) = \(setting.value)  # \(setting.comment)")
    touchedDomains.insert(setting.domain)
}

let processesToRestart = touchedDomains.compactMap { restartTargets[$0] }

if !processesToRestart.isEmpty {
    print("==> Restarting affected apps: \(processesToRestart.joined(separator: ", "))")
    for process in Set(processesToRestart) {
        run("/usr/bin/killall", [process])
    }
}

print("==> Done.")
