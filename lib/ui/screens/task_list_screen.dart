import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/task.dart';
import '../../providers/task_provider.dart';

class TaskListScreen extends ConsumerStatefulWidget {
  const TaskListScreen({super.key});

  @override
  ConsumerState<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends ConsumerState<TaskListScreen> {
  @override
  void initState() {
    super.initState();
    // 画面作成時にTaskを取得
    Future.microtask(() {
      ref.read(taskListProvider.notifier).fetchTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(taskListProvider);

    return Scaffold(
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
                subtitle: Text('${task.status} | Due: ${task.dueDate}'),
                onTap: () async {
                  // タップしたらステータスを更新
                  await ref.read(taskListProvider.notifier).updateTask(
                        task.id,
                        status: 'Done',
                      );
                },
                trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      await ref
                          .read(taskListProvider.notifier)
                          .deleteTask(task.id);
                    }),
              );
            }),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await ref.read(taskListProvider.notifier).addTask('New Task');
        },
      ),
    );
  }
}
