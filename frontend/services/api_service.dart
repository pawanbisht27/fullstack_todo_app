import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.18.131.54:5000/api';

  // SIGNUP
  static Future<Map<String, dynamic>> signup(String fullName, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'fullName': fullName, 'email': email, 'password': password}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      print('Signup Error: $e');
      return {'error': e.toString()};
    }
  }

  // VERIFY OTP
  static Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': otp}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      print('Verify OTP Error: $e');
      return {'error': e.toString()};
    }
  }

  // LOGIN
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      print('Login Error: $e');
      return {'error': e.toString()};
    }
  }

  // GET TODOS
  static Future<List<dynamic>> getTodos(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/todo/all'),
        headers: {'Authorization': token},
      );
      if (response.statusCode == 200) return jsonDecode(response.body);
      return [];
    } catch (e) {
      print('Get Todos Error: $e');
      return [];
    }
  }

  // ADD TODO
  static Future<bool> addTodo(String token, String title) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/todo/add'),
        headers: {'Content-Type': 'application/json', 'Authorization': token},
        body: jsonEncode({
          'title': title,
          'createdAt': DateTime.now().toIso8601String(),
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Add Todo Error: $e');
      return false;
    }
  }

  // DELETE TODO
  static Future<bool> deleteTodo(String token, String todoId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/todo/delete/$todoId'),
        headers: {'Authorization': token},
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Delete Todo Error: $e');
      return false;
    }
  }

  // TOGGLE TODO
  static Future<bool> toggleTodo(String token, String todoId, bool completed) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/todo/toggle/$todoId'),
        headers: {'Content-Type': 'application/json', 'Authorization': token},
        body: jsonEncode({'completed': completed}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Toggle Todo Error: $e');
      return false;
    }
  }

  // UPDATE TODO
  static Future<bool> updateTodo(String token, String todoId, String newTitle) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/todo/update/$todoId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
        body: jsonEncode({'title': newTitle}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Update Todo Error: $e');
      return false;
    }
  }
}