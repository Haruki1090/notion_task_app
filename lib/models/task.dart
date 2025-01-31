import 'package:freezed_annotation/freezed_annotation.dart';

part 'task.freezed.dart';
part 'task.g.dart';

@freezed
class Task with _$Task {
  // コンストラクタ
  const factory Task({
    required String id,
    required String title,
    required String status,
    DateTime? dueDate,
  }) = _Task;

  // JSONからTaskオブジェクトを生成
  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);

  // Notionのレスポンス構造をパースする独自ファクトリ
  factory Task.fromNotionJson(Map<String, dynamic> notionJson) {
    final properties = notionJson['properties'] as Map<String, dynamic>? ?? {};

    // タイトルを取得
    final titleProperty = properties['Name']?['title'] as List<dynamic>?;
    final titleString = (titleProperty != null && titleProperty.isNotEmpty)
        ? titleProperty.first['plain_text'] as String?
        : '';

    // ステータスを取得
    final statusString =
        properties['Status']?['select']?['name'] as String? ?? '';

    // 期限を取得
    final dateProperty = properties['Due Date']?['date']?['start'] as String?;
    final dueDate =
        dateProperty != null ? DateTime.tryParse(dateProperty) : null;

    return Task(
      id: notionJson['id'] as String,
      title: titleString ?? '',
      status: statusString,
      dueDate: dueDate,
    );
  }
}
