#!/usr/bin/env swift
//
// doctor.swift
//
// dotfiles でセットアップした環境が意図した状態になっているかを確認する。
// 元は bin/doctor (bash, eval ベースの check 関数) だったものを Swift に移植。
// check() の羅列を「名前 + 条件クロージャ」の配列にして、文字列 eval を排除している。
//
// 実行: bin/doctor.swift

import Foundation

let home = FileManager.default.homeDirectoryForCurrentUser.path

// --- ヘルパー ---------------------------------------------------------

/// 実行ファイルを絶対パスで呼ぶ。Process.executableURL は PATH 検索をしないため、
/// 絶対パスでない場合は /usr/bin/which で解決してから起動する。
@discardableResult
func run(_ executable: String, _ args: [String]) -> (status: Int32, output: String) {
    let resolvedPath: String
    if executable.hasPrefix("/") {
        resolvedPath = executable
    } else {
        let which = _rawRun("/usr/bin/which", [executable])
        guard which.status == 0, !which.output.isEmpty else {
            return (-1, "")
        }
        resolvedPath = which.output
    }
    return _rawRun(resolvedPath, args)
}

private func _rawRun(_ executablePath: String, _ args: [String]) -> (status: Int32, output: String) {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: executablePath)
    process.arguments = args
    let pipe = Pipe()
    process.standardOutput = pipe
    process.standardError = Pipe() // 捨てる
    do {
        try process.run()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()
        let output = String(data: data, encoding: .utf8) ?? ""
        return (process.terminationStatus, output.trimmingCharacters(in: .whitespacesAndNewlines))
    } catch {
        return (-1, "")
    }
}

func commandExists(_ name: String) -> Bool {
    _rawRun("/usr/bin/which", [name]).status == 0
}

func fileExists(_ path: String) -> Bool {
    FileManager.default.fileExists(atPath: path)
}

func dirExists(_ path: String) -> Bool {
    var isDir: ObjCBool = false
    return FileManager.default.fileExists(atPath: path, isDirectory: &isDir) && isDir.boolValue
}

func isSymlink(_ path: String) -> Bool {
    (try? FileManager.default.destinationOfSymbolicLink(atPath: path)) != nil
}

/// ~/Library/Fonts や /Library/Fonts 配下で、ファイル名が prefix で始まり
/// "Nerd" を含むフォントが1つでもあるか (bash の `ls Prefix*Nerd*` 相当)
func fontInstalled(prefix: String) -> Bool {
    for dir in ["\(home)/Library/Fonts", "/Library/Fonts"] {
        guard let entries = try? FileManager.default.contentsOfDirectory(atPath: dir) else { continue }
        if entries.contains(where: { $0.hasPrefix(prefix) && $0.contains("Nerd") }) {
            return true
        }
    }
    return false
}

let brewPrefix: String = run("/opt/homebrew/bin/brew", ["--prefix"]).output

var pass = 0
var fail = 0

func check(_ name: String, _ condition: @autoclosure () -> Bool) {
    if condition() {
        print("  ✓ \(name)")
        pass += 1
    } else {
        print("  ✗ \(name)")
        fail += 1
    }
}

// --- Environment -------------------------------------------------------

print("==> Checking environment...")

check("Homebrew installed", commandExists("brew"))
check("mise installed", commandExists("mise"))
check("Starship prompt available", commandExists("starship"))
check("zsh-abbr installed", fileExists("\(brewPrefix)/share/zsh-abbr/zsh-abbr.zsh"))
check("zsh-syntax-highlighting installed", dirExists("\(brewPrefix)/share/zsh-syntax-highlighting"))
check("zsh-autosuggestions installed", dirExists("\(brewPrefix)/share/zsh-autosuggestions"))
check("Catppuccin theme installed", dirExists("\(home)/.zsh/catppuccin-zsh-syntax-highlighting"))
check("FiraCode Nerd Font installed", fontInstalled(prefix: "FiraCode"))

if fontInstalled(prefix: "MonoLisa") {
    print("  ✓ MonoLisa Nerd Font installed (preferred)")
    pass += 1
} else {
    print("  · MonoLisa Nerd Font not found (using FiraCode as fallback)")
}

print("")
print("==> Language toolchains...")

check("Ruby available", run("mise", ["which", "ruby"]).status == 0)
check("Go available", run("mise", ["which", "go"]).status == 0)
check("Node available", run("mise", ["which", "node"]).status == 0)
check("Java available", run("mise", ["which", "java"]).status == 0)
check("Rust available", run("mise", ["which", "rustc"]).status == 0)

print("")
print("==> Dotfile symlinks...")

check("~/.zshrc linked", isSymlink("\(home)/.zshrc"))
check("~/.zshenv linked", isSymlink("\(home)/.zshenv"))
check("~/.gitconfig linked", isSymlink("\(home)/.gitconfig"))
check("~/.config/mise/config.toml linked", isSymlink("\(home)/.config/mise/config.toml"))
check("~/.config/alacritty/alacritty.toml linked", isSymlink("\(home)/.config/alacritty/alacritty.toml"))
check("~/.config/nvim linked", isSymlink("\(home)/.config/nvim"))
check("~/.config/yabai/yabairc linked", isSymlink("\(home)/.config/yabai/yabairc"))
check("~/.config/skhd/skhdrc linked", isSymlink("\(home)/.config/skhd/skhdrc"))
check("Ghostty config linked", isSymlink("\(home)/Library/Application Support/com.mitchellh.ghostty/config"))
check("Ghostty installed", dirExists("/Applications/Ghostty.app") || commandExists("ghostty"))

print("")
print("==> CLI tools...")

check("delta installed", commandExists("delta"))
check("fzf installed", commandExists("fzf"))
check("fd installed", commandExists("fd"))
check("bat installed", commandExists("bat"))
check("eza installed", commandExists("eza"))
check("ghq installed", commandExists("ghq"))
check("lazygit installed", commandExists("lazygit"))
check("gh installed", commandExists("gh"))

let ghExtensions = run("gh", ["extension", "list"]).output
check("gh-dash extension", ghExtensions.contains("gh-dash"))
check("gh-notify extension", ghExtensions.contains("gh-notify"))
check("gh-copilot extension", ghExtensions.contains("gh-copilot"))

print("")
print("==> Apps...")

check("Raycast installed", dirExists("/Applications/Raycast.app"))
check("1Password CLI installed", commandExists("op"))
check("Docker installed", commandExists("docker"))
check("Neovim installed", commandExists("nvim"))
check("VS Code installed", commandExists("code"))
check("Claude Code installed", commandExists("claude"))
check("yabai installed", commandExists("yabai"))
check("skhd installed", commandExists("skhd"))

print("")
print("==> Results: \(pass) passed, \(fail) failed")

if fail > 0 {
    print("    Run 'bin/setup' to fix issues.")
}

// --- Workspace staleness -------------------------------------------------

let devDir = "\(home)/dev"
let staleMonths = 6
let cutoff = Calendar.current.date(byAdding: .month, value: -staleMonths, to: Date()) ?? Date()
var stale = 0

if let entries = try? FileManager.default.contentsOfDirectory(atPath: devDir) {
    for name in entries {
        if name == "_archive" || name == "dotfiles" { continue }
        let repoPath = "\(devDir)/\(name)"
        guard dirExists("\(repoPath)/.git") else { continue }
        let result = run("/usr/bin/git", ["-C", repoPath, "log", "-1", "--format=%ct"])
        guard let epoch = Double(result.output) else { continue }
        let lastCommit = Date(timeIntervalSince1970: epoch)
        if lastCommit < cutoff {
            stale += 1
        }
    }
}

if stale > 0 {
    print("")
    print("==> Workspace: \(stale) stale projects (no commits in \(staleMonths)+ months)")
    print("    Run 'ws archive' to clean up.")
}

exit(fail > 0 ? 1 : 0)
