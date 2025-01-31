import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/task.dart';
import '../../providers/task_provider.dart';

class TaskDetailScreen extends ConsumerStatefulWidget {
  /// 既存タスクを受け取る (nullなら新規)
  final Task? initialTask;

  const TaskDetailScreen({
    super.key,
    this.initialTask,
  });

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _statusController;
  DateTime? _dueDate;

  // 例: ステータス候補リスト (Notion側で実際に設定している名前に合わせる)
  final List<String> _statusOptions = ['To do', 'In progress', 'Done'];

  @override
  void initState() {
    super.initState();

    // 受け取った既存タスクがあるなら、その値を初期表示に使う
    _titleController = TextEditingController(
      text: widget.initialTask?.title ?? '',
    );

    // ステータスの初期値をセット (存在しない場合は 'To do')
    _statusController = TextEditingController(
      text: widget.initialTask?.status ?? 'To do',
    );

    // 期日の初期値
    _dueDate = widget.initialTask?.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate(BuildContext context) async {
    final now = DateTime.now();
    final initialDate = _dueDate ?? now;
    final newDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 5), // 5年前まで
      lastDate: DateTime(now.year + 5), // 5年後まで
    );
    if (newDate != null) {
      setState(() {
        _dueDate = newDate;
      });
    }
  }

  Future<void> _saveTask() async {
    final title = _titleController.text.trim();
    final status = _statusController.text.trim();

    if (title.isEmpty) {
      // タイトル必須にしたい場合などはバリデーション
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('タイトルを入力してください')),
      );
      return;
    }

    final notifier = ref.read(taskListProvider.notifier);

    if (widget.initialTask == null) {
      // 新規作成
      await notifier.addTask(
        title,
        status: status.isNotEmpty ? status : 'To do',
        dueDate: _dueDate,
      );
    } else {
      // 既存編集
      await notifier.updateTask(
        widget.initialTask!.id,
        title: title,
        status: status,
        dueDate: _dueDate,
      );
    }

    // 保存完了したら前の画面に戻る
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialTask != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'タスクを編集' : '新規タスク'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // タイトル入力
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'タイトル',
              ),
            ),
            const SizedBox(height: 16),

            // ステータス選択: Dropdown か TextField のどちらか好きな方でOK
            // ここでは例としてDropdownButtonを使う
            Row(
              children: [
                const Text('ステータス: '),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<String>(
                    value: _statusOptions.contains(_statusController.text)
                        ? _statusController.text
                        : _statusOptions.first,
                    onChanged: (newValue) {
                      if (newValue != null) {
                        setState(() {
                          _statusController.text = newValue;
                        });
                      }
                    },
                    items: _statusOptions
                        .map((status) => DropdownMenuItem<String>(
                              value: status,
                              child: Text(status),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 期日 (DueDate) の選択ボタン
            Row(
              children: [
                const Text('期日: '),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _dueDate != null
                        ? _dueDate!.toString().split(' ')[0]
                        : '未設定',
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _pickDueDate(context),
                  child: const Text('選択'),
                ),
              ],
            ),

            const Spacer(),

            // 保存ボタン
            ElevatedButton(
              onPressed: _saveTask,
              child: Text(isEditing ? '更新する' : '作成する'),
            ),
          ],
        ),
      ),
    );
  }
}
