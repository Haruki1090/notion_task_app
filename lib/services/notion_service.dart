import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/task.dart';

class NotionService {
  static const String _baseUrl = 'https://api.notion.com/v1';

  final String integrationToken;
  final String databaseId;

  NotionService({
    required this.integrationToken,
    required this.databaseId,
  });

  Map<String, String> get _headers => {
        'Authorization': 'Bearer $integrationToken',
        'Notion-Version': '2022-06-28',
        'Content-Type': 'application/json',
      };

  // タスク一覧を取得
  Future<List<Task>> fetchTasks() async {
    final url = Uri.parse('$_baseUrl/databases/$databaseId/query');
    final response = await http.post(url, headers: _headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>;
      return results.map((page) => Task.fromNotionJson(page)).toList();
    } else {
      throw Exception(
        'Failed to fetch tasks. Status code: ${response.statusCode}, Body: ${response.body}',
      );
    }
  }

  // タスクを追加
  Future<Task> createTask({
    required String title,
    String? status,
    DateTime? dueDate,
  }) async {
    final url = Uri.parse('$_baseUrl/pages');
    final body = {
      'parent': {
        'database_id': databaseId,
      },
      'properties': {
        'Name': {
          'title': [
            {
              'text': {'content': title}
            }
          ]
        },
        'Status': {
          'select': {
            'name': status ?? 'Todo',
          },
        },
        if (dueDate != null)
          'Due  Date': {
            'date': {
              'start': dueDate.toIso8601String(),
            },
          },
      },
    };

    final response = await http.post(
      url,
      headers: _headers,
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return Task.fromNotionJson(data);
    } else {
      throw Exception(
          'Failed to create task. Status: ${response.statusCode}, Body: ${response.body}');
    }
  }

  // タスクを更新
  Future<Task> updateTask({
    required String pageId,
    String? title,
    String? status,
    DateTime? dueDate,
  }) async {
    final url = Uri.parse('$_baseUrl/pages/$pageId');

    final propertiesMap = <String, dynamic>{};
    if (title != null) {
      propertiesMap['Name'] = {
        'title': [
          {
            'text': {'content': title}
          }
        ]
      };
    }
    if (status != null) {
      propertiesMap['Status'] = {
        'select': {'name': status}
      };
    }
    if (dueDate != null) {
      propertiesMap['Due Date'] = {
        'date': {
          'start': dueDate.toIso8601String(),
        }
      };
    }

    final body = {
      'properties': propertiesMap,
    };

    final response = await http.patch(
      url,
      headers: _headers,
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return Task.fromNotionJson(data);
    } else {
      throw Exception(
          'Failed to update task. Status: ${response.statusCode}, Body: ${response.body}');
    }
  }

  /// タスク削除(アーカイブ) (pages/{pageId} にPATCH)
  Future<void> archiveTask(String pageId) async {
    final url = Uri.parse('$_baseUrl/pages/$pageId');
    final body = {
      'archived': true,
    };

    final response = await http.patch(
      url,
      headers: _headers,
      body: json.encode(body),
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to archive task. Status: ${response.statusCode}, Body: ${response.body}');
    }
  }
}
