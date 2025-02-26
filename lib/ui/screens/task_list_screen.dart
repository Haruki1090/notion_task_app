import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/task.dart';
import '../../providers/task_provider.dart';
import 'task_detail_screen.dart';

class TaskListScreen extends ConsumerStatefulWidget {
  const TaskListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends ConsumerState<TaskListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(taskListProvider.notifier).fetchTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(taskListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notion Tasks'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(taskListProvider.notifier).fetchTasks();
        },
        child: ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final Task task = tasks[index];
            return ListTile(
              title: Text(task.title),
              subtitle: Text('${task.status} | ${task.dueDate ?? '期日なし'}'),
              onTap: () {
                // タスク詳細画面へ遷移
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => TaskDetailScreen(initialTask: task),
                  ),
                );
              },
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  // タスクを削除(アーカイブ)
                  await ref.read(taskListProvider.notifier).deleteTask(task.id);
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          // 新規作成モードでTaskDetailScreenを開く
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const TaskDetailScreen(),
            ),
          );
        },
      ),
    );
  }
}
