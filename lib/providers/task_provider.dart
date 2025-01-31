import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/task.dart';
import '../services/notion_service.dart';

final notionServiceProvider = Provider<NotionService>((ref) {
  var integrationToken = dotenv.env['INTEGRATION_TOKEN']!;
  var databaseId = dotenv.env['DATABASE_ID']!;

  return NotionService(
    integrationToken: integrationToken,
    databaseId: databaseId,
  );
});

// タスクリストを管理するNotifier
class TaskListNotifier extends StateNotifier<List<Task>> {
  TaskListNotifier(this._notionService) : super([]);

  final NotionService _notionService;

  // Notionからタスク一覧を取得してstateを更新
  Future<void> fetchTasks() async {
    try {
      final tasks = await _notionService.fetchTasks();
      state = tasks;
    } catch (e) {
      rethrow;
    }
  }

  // タスク追加
  Future<void> addTask(String title,
      {String? status, DateTime? dueDate}) async {
    try {
      final newTask = await _notionService.createTask(
          title: title, status: status, dueDate: dueDate);
      // イミュータブルなListなので新Listを作成
      state = [...state, newTask];
    } catch (e) {
      rethrow;
    }
  }

  // タスク更新
  Future<void> updateTask(
    String pageId, {
    String? title,
    String? status,
    DateTime? dueDate,
  }) async {
    try {
      final updatedTask = await _notionService.updateTask(
        pageId: pageId,
        title: title,
        status: status,
        dueDate: dueDate,
      );
      // 該当タスクだけを差し替えたListを作成
      state = state.map((t) => t.id == pageId ? updatedTask : t).toList();
    } catch (e) {
      rethrow;
    }
  }

  // タスク削除
  Future<void> deleteTask(String pageId) async {
    try {
      await _notionService.archiveTask(pageId);
      // 該当タスクを除いたListを作成
      state = state.where((t) => t.id != pageId).toList();
    } catch (e) {
      rethrow;
    }
  }
}

// タスクリストを監視・操作できるProvider
final taskListProvider =
    StateNotifierProvider<TaskListNotifier, List<Task>>((ref) {
  final notionService = ref.watch(notionServiceProvider);
  return TaskListNotifier(notionService);
});
