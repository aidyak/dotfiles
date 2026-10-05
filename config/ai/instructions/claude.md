# Global Settings

## モデル選択ルール
- セッションで最初のタスクを受けたら、実作業の前に `model-router` スキルを Skill ツールで呼び出すこと。
- **同一セッション内での再呼び出しは不要**（内容は既にコンテキストにあるので、以降はそれに従う）。毎ターンの再注入はコンテキストコスト>の無駄になる。
- ただし、タスクの性質が大きく変わりモデルの再検討が必要になったときは、スキルの指針に沿って再評価する（アップグレードのみ。途中のダウ>ングレード提案はしない）。
- サブエージェント（Agent / Workflow）を起動するときは、スキルの指針に従い model / effort を常に明示指定する。
- セッション内でユーザーから「使わないで」「スキップして」などの指示があった場合は、そのセッション限りでスキップしてよい。

# graphify
- **graphify** (`~/.claude/skills/graphify/SKILL.md`) - any input to knowledge graph. Trigger: `/graphify`
When the user types `/graphify`, use the installed graphify skill or instructions before doing anything else.
