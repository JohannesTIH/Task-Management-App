import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/tasks.dart';

class TaskApiService {
  final String baseUrl;
  TaskApiService({String? baseUrl}) : baseUrl = baseUrl ?? ApiConfig.baseUrl;

  String _parseHttpError(http.Response response) {
    final status = response.statusCode;
    if (status == 400) {
      return 'Client-Side Issue: Invalid task details provided. Please check your input.';
    } else if (status == 401 || status == 403) {
      return 'Client-Side Issue: Access denied by server.';
    } else if (status == 404) {
      return 'Client-Side Issue: The requested task could not be found.';
    } else if (status >= 400 && status < 500) {
      return 'Client-Side Issue (Code $status): Request error. Please verify input.';
    } else if (status >= 500) {
      return 'Server-Side Issue (Code $status): The server encountered a problem. Please try again later.';
    }
    return 'Server Issue (Code $status): Unexpected response received.';
  }

  Never _handleException(dynamic e) {
    final errorStr = e.toString();
    // 1. Check for precise mobile offline status via string matching
    if (errorStr.contains('SocketException') || errorStr.contains('Failed host lookup')) {
      throw Exception('Network connection error. Please connect to the internet.');
    }

    // 2. Generic client/web errors
    else if (errorStr.contains('ClientException') || errorStr.contains('XMLHttpRequest')) {
      throw Exception('Network communication failed. Please check your connection.');
    }

    // 3. Timeout errors
    else if (e is TimeoutException || errorStr.contains('TimeoutException')) {
      throw Exception(
        'Server took too long to respond. Please retry your operation.',
      );
    } else {
      throw Exception('Unexpected Issue: $errorStr');
    }
  }

  // GET /api/Tasks
  Future<List<Tasks>> fetchTasks() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/Tasks'))
          .timeout(ApiConfig.timeoutDuration);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((data) => Tasks.fromJson(data)).toList();
      } else {
        throw Exception(_parseHttpError(response));
      }
    } catch (e) {
      if (e is Exception && e.toString().contains('Issue')) {
        rethrow;
      }
      _handleException(e);
    }
  }

  // POST /api/Tasks
  Future<Tasks> createTask(Tasks task) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/Tasks'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(task.toJson()),
          )
          .timeout(ApiConfig.timeoutDuration);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Tasks.fromJson(json.decode(response.body));
      } else {
        throw Exception(_parseHttpError(response));
      }
    } catch (e) {
      if (e is Exception && e.toString().contains('Issue')) {
        rethrow;
      }
      _handleException(e);
    }
  }

  // PUT /api/Tasks/{id}
  Future<void> updateTask(int id, Tasks task) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/Tasks/$id'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(task.toJson()),
          )
          .timeout(ApiConfig.timeoutDuration);

      if (response.statusCode == 204 || response.statusCode == 200) {
        return;
      } else {
        throw Exception(_parseHttpError(response));
      }
    } catch (e) {
      if (e is Exception && e.toString().contains('Issue')) {
        rethrow;
      }
      _handleException(e);
    }
  }

  // DELETE /api/Tasks/{id}
  Future<void> deleteTask(int id) async {
    try {
      final response = await http
          .delete(Uri.parse('$baseUrl/Tasks/$id'))
          .timeout(ApiConfig.timeoutDuration);

      if (response.statusCode == 204 || response.statusCode == 200) {
        return;
      } else {
        throw Exception(_parseHttpError(response));
      }
    } catch (e) {
      if (e is Exception && e.toString().contains('Issue')) {
        rethrow;
      }
      _handleException(e);
    }
  }
}
