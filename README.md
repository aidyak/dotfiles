# dotfiles

Personal dotfiles for macOS.

## Setup

Clone the repository and run:

```sh
bin/setup
```

The setup script installs the Homebrew dependencies, links the dotfiles, applies
macOS defaults, and starts yabai and skhd.
=======
## 新しいPCのセットアップ

Gitを用意してdotfilesを取得した後、`bin/setup` を実行します。

```sh
mkdir -p "$HOME/.config/ghq/github.com/aidyak"
git clone https://github.com/aidyak/dotfiles.git "$HOME/.config/ghq/github.com/aidyak/dotfiles"
cd "$HOME/.config/ghq/github.com/aidyak/dotfiles"
bin/setup
```

`bin/setup` はHomebrewの依存関係を入れた後、ghqのルートと
`github.com/aidyak/` を作成します。別の場所にdotfilesを取得した場合は、
ghq配下からそのチェックアウトへのリンクを作ります。既存の別チェックアウトは上書きしません。

`config/ghq/repositories.txt` に `github.com/owner/repo` を1行ずつ書くと、
セットアップ時に `ghq get` で取得します。取得済みのリポジトリは更新しません。
初期の一覧は空です。プライベートリポジトリはGit/SSHの認証を先に用意してください。
ghq部分だけ再実行する場合は `bin/setup-ghq` を使えます。

`zshenv` で `XDG_CONFIG_HOME` と `GHQ_ROOT` を設定するため、シェルの再起動前でも
セットアップと普段のghqが同じ場所を使います。既定値は `~/.config/ghq` です。
変更する場合は `GHQ_ROOT=/path/to/repos bin/setup` のように指定し、
普段の環境にも同じ変数を設定してください。Git設定にも既定のghqルートを収録しています。
ghqの配置規則・環境変数は [公式README](https://github.com/x-motemen/ghq#configuration) を参照してください。

## キーボード設定（Karabiner）

[karabiner.ts](https://github.com/evan-liu/karabiner.ts) を使い、
`config/karabiner/index.ts` でこのMacのキーマッピングを管理します。
Node.js 22.18以降とpnpmが必要です。`bin/setup` でKarabiner-Elementsを導入し、
`bin/install` で設定を適用します。

```sh
# キーボード設定だけインストール・適用
bin/setup-karabiner

# JSON生成のみ（Macの設定は変更しない）
cd config/karabiner
pnpm build
```

Caps Lock → Control、左右Command単押しによる英数・かな切り替え（100ms）、
3種類のキーボード固有のキー置換を収録しています。
生成結果は `config/karabiner/dist/karabiner.json` です。
適用時は `Default profile` のキー置換を更新し、他のプロファイル、
未管理のデバイスや環境設定は保持します。
既存設定は `karabiner.json.backup-<日時>` に退避します。
Karabiner-Elementsは設定ファイルの更新を自動で読み込みます。
新しいMacではKarabiner-Elementsを開き、必要な権限を許可してください。
検証用の設定ファイルには `KARABINER_CONFIG_PATH=/tmp/karabiner.json bin/setup-karabiner` で適用できます。

## AI設定

Claude CodeとCodexの持ち運びたい設定を `config/ai/` で管理します。
Python 3.11以降が必要です。通知・Claude hooks・ステータス表示には `jq` を使います。

```sh
# 変更予定を確認（ファイル内容や認証情報は表示しない）
bin/sync-ai --check

# AI設定だけ適用
bin/sync-ai

# 他のdotfilesも含めて適用
bin/install
```

| 編集先 | 反映先・用途 |
| --- | --- |
| `config/ai/instructions/common.md` | 両ツールに共通の指示 |
| `config/ai/instructions/claude.md` | Claude固有の指示 |
| `config/ai/instructions/codex.md` | Codex固有の指示 |
| `config/ai/skills/<name>/` | `~/.claude/skills/<name>` と `~/.agents/skills/<name>` へのリンク |
| `config/ai/claude/settings.json` | Claudeの個人設定にマージ |
| `config/ai/claude/hooks/`・`statusline.sh` | Claudeの各スクリプトへのリンク |
| `config/ai/codex/config.toml` | Codexの基本設定にマージ |
| `config/ai/codex/notify_macos.sh` | Codexの通知スクリプトへのリンク |

指示は共通＋固有を結合して `~/.claude/CLAUDE.md` と `~/.codex/AGENTS.md` に生成します。
原本を編集したら `bin/sync-ai` を再実行してください。生成先への直接編集は次回同期で上書きされます。
スキルとスクリプトはリンクなので原本の変更が直接反映されます。

現在は共通のReactスキルとInertia Rails関連スキルを収録しています。
Claude専用のモデルルーター・graphifyなど、既存の未収録スキルはそのまま残します。
新しい端末でそれらを使う場合は別途インストールしてください。
プラグインも設定の有効化情報のみを管理し、本体やキャッシュは収録しません。

### ローカル設定との共存

- Claudeのオブジェクトは再帰的にマージし、配列（権限・hooksなど）は重複を除いて追加します。
  既存のHerdr連携など未管理の設定は保持します。配列項目を原本から削除しても、適用先からは削除しません。
- Codexは原本にあるトップレベルのキーだけを更新します。MCP、プロジェクトの信頼設定、
  プラグイン、アプリ固有のパスなどのテーブルは保持します。`@HOME@` は適用先のホームに置換します。
- 既存の同名スキルはdotfilesの原本に切り替えます。
  `~/.codex/skills/` に同名の旧スキルがある場合はバックアップへ移動し、重複読み込みを避けます。
- 置き換えるファイル・ディレクトリ・リンクは
  `~/.local/state/dotfiles-ai/backups/<日時>/` に元の相対パスで退避します。
  復元する場合は該当バックアップを元の場所へ戻してください。
- 認証情報、履歴、メモリ、キャッシュ、Herdrが生成するスクリプトは同期対象外です。
  `~/.claude/` や `~/.codex/` 全体をGit管理しません。

適用後はClaude Code・Codexのセッションを再起動してください。
検証用のホームへ適用するには `bin/sync-ai --home /tmp/ai-test-home` を使えます。
