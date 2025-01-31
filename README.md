# notion_task_app

## Directory Structure
```
lib/
 ┣ models/
 ┃   ┗ task.dart          // タスクオブジェクトのモデル
 ┣ services/
 ┃   ┗ notion_service.dart // Notion APIとのやりとりを行うサービスクラス
 ┣ providers/
 ┃   ┗ task_provider.dart  // タスク状態の管理 (RiverpodやProviderなど)
 ┣ ui/
 ┃   ┣ screens/
 ┃   ┃   ┗ task_list_screen.dart // タスク一覧表示画面
 ┃   ┃   ┗ task_detail_screen.dart // タスク詳細・編集画面
 ┃   ┗ widgets/
 ┗ main.dart
```