import 'dart:convert';
import 'dart:io';
import 'dart:typed_data'; // Import dart:typed_data
import 'package:flutter/foundation.dart'; // Required for kIsWeb
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:url_launcher/url_launcher.dart';

class ApiService {
  // final String baseUrl = 'http://192.168.93.182:8000';
  final String baseUrl = 'http://192.168.57.182:8000';
  final String apiUrl = 'http://192.168.57.182:8000/api';
  // final String baseUrl = 'http://192.168.186.182:8000';
  // final String apiUrl = 'http://192.168.186.182:8000/api';

  String getPasswordResetUrl() {
    return '$baseUrl/password/reset';
  }

  Future<void> openPasswordResetUrl() async {
    final url = getPasswordResetUrl();
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<Map<String, dynamic>> register(
    Map<String, dynamic> userData,
    File? profileImage,
    String? fileName,
    String accessToken,
  ) async {
    // Debug statements
    print('User Data: $userData');
    print('Profile Image: $profileImage');
    print('File Name: $fileName');
    print('Access Token: $accessToken');

    // Validate accessToken
    if (accessToken.isEmpty) {
      throw Exception('Access token is missing');
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$apiUrl/user-update'),
    )..headers['Authorization'] = 'Bearer $accessToken';

    // Validate and add userData fields
    request.fields.addAll(
      userData.map((key, value) => MapEntry(
            key,
            value?.toString() ?? '', // Convert null values to empty strings
          )),
    );

    // Add file to the request if not in web environment
    if (!kIsWeb) {
      if (profileImage == null) {
        throw Exception('Profile image is missing');
      }
      request.files.add(await http.MultipartFile.fromPath(
        'profile',
        profileImage.path,
        contentType: MediaType('image', 'jpeg'),
      ));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    // Debug response details
    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    // Handle the response based on status code
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 302) {
      // Handle redirection response
      throw Exception('Redirect detected: ${response.headers['location']}');
    } else {
      // Handle other response statuses
      throw Exception('Failed to register user');
    }
  }

  Future<Map<String, dynamic>> login(String userId, String password) async {
    final response = await http.post(
      Uri.parse('$apiUrl/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'userId': userId,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Invalid Credentials');
    }
  }

  Future<Map<String, dynamic>> fetchSelf(String token) async {
    final response = await http.get(
      Uri.parse('$apiUrl/self'), // Replace with your actual user info endpoint
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseBody = jsonDecode(response.body);
      if (responseBody.containsKey('user') &&
          responseBody.containsKey('access_token')) {
        return {
          'user': responseBody['user'],
          'details': responseBody['user']['details'],
        };
      } else {
        throw Exception('User data or access token not found in response');
      }
    } else {
      throw Exception('Failed to fetch user data');
    }
  }

  // Create
  Future<Map<String, dynamic>> createItem(
      String token, Map<String, dynamic> item) async {
    final response = await http.post(
      Uri.parse(
          '$apiUrl/items'), // Replace with your actual create item endpoint
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(item),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create item');
    }
  }

  // Read
  Future<Map<String, dynamic>> readItem(String token, int itemId) async {
    final response = await http.get(
      Uri.parse(
          '$apiUrl/items/$itemId'), // Replace with your actual read item endpoint
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch item');
    }
  }

  // Update
  Future<Map<String, dynamic>> updateItem(
      String token, int itemId, Map<String, dynamic> item) async {
    final response = await http.put(
      Uri.parse(
          '$apiUrl/items/$itemId'), // Replace with your actual update item endpoint
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(item),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update item');
    }
  }

  // Delete
  Future<void> deleteItem(String token, int itemId) async {
    final response = await http.delete(
      Uri.parse(
          '$apiUrl/items/$itemId'), // Replace with your actual delete item endpoint
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete item');
    }
  }

  Future<List<String>> fetchMealImages(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/get-today'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> todayMealsData = jsonDecode(response.body)['today'];

        List<String> mealImageUrls = todayMealsData.map((todayMealData) {
          String imageUrl =
              '$baseUrl/meal/${todayMealData['todaymeal']['image']}';
          return imageUrl;
        }).toList();

        return mealImageUrls;
      } else {
        throw Exception('Failed to fetch meal images');
      }
    } catch (e) {
      throw Exception('Failed to fetch meal images: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchTodayMeals(String token) async {
    try {
      final url = Uri.parse('$apiUrl/get-today');
      print('Requesting URL: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        List<dynamic> todayMeals = jsonResponse['today'] ?? [];

        if (todayMeals.isEmpty) {
          // Return an empty list instead of throwing an error
          return [];
        }

        List<Map<String, dynamic>> meals = todayMeals.map((meal) {
          return {
            'id': meal['id'],
            'meal_id': meal['meal_id'],
            'date_available': meal['date_available'],
            'todaymeal': {
              'id': meal['todaymeal']['id'],
              'name': meal['todaymeal']['name'],
              'image': '$baseUrl/meal/${meal['todaymeal']['image']}',
              'description': meal['todaymeal']['description'],
              'price': meal['todaymeal']['price'],
              'created_at': meal['todaymeal']['created_at'],
              'updated_at': meal['todaymeal']['updated_at'],
            },
          };
        }).toList();

        return meals;
      } else {
        // Optionally handle non-200 responses differently if needed
        return [];
      }
    } catch (e) {
      print('Error fetching today meals: $e');
      return []; // Return an empty list on error as well
    }
  }

  Future<Map<String, dynamic>> submitOrder(
      String token, Map<String, dynamic> item) async {
    final response = await http.post(
      Uri.parse(
          '$apiUrl/order-store'), // Replace with your actual create item endpoint
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(item),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create item');
    }
  }

  Future<Map<String, dynamic>> fetchOrders(String token) async {
    final response = await http.get(
      Uri.parse('$apiUrl/orders'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // Return the whole response as a Map
    } else {
      throw Exception('Failed to load orders: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> fetchOrderDetails(
      String token, int orderId) async {
    final response = await http.get(
      Uri.parse('$apiUrl/order-item/$orderId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Add bearer token here
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load order');
    }
  }

  Future<Map<String, dynamic>> updatePassword(
      String token, Map<String, dynamic> userData) async {
    final response = await http.put(
      Uri.parse(
          '$apiUrl/update-password'), // Replace with your actual update password endpoint
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(userData),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          'Failed to update password. Status code: ${response.statusCode}. Response body: ${response.body}');
    }
  }

  Future<bool> validateToken(String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/validate-token'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> addRequest(
      String token, Map<String, dynamic> item) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/add-request'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(item),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Failed to create item: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw e;
    }
  }

  Future<List<Map<String, dynamic>>> getEntities(String? token) async {
    print('test');
    final response = await http.get(
      Uri.parse('$apiUrl/entity'), // Update the endpoint as needed
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['entity'];
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load entities');
    }
  }

  Future<Map<String, dynamic>> getRequests(String token) async {
    final response = await http.get(
      Uri.parse('$apiUrl/get-my-request'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // Return the whole response as a Map
    } else {
      throw Exception('Failed to load orders: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getToMeRequests(String token) async {
    final response = await http.get(
      Uri.parse('$apiUrl/get-to-me-request'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // Return the whole response as a Map
    } else {
      throw Exception('Failed to load orders: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> changeStatus(
    String accessToken,
    int requestId,
    int status,
  ) async {
    final url = Uri.parse(
        '$apiUrl/requests/$requestId/status'); // Adjust URL as necessary
    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'status': status}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      return {
        'status': response.statusCode == 404 ? 'not_found' : 'error',
        'error_code': response.statusCode,
        'message': response.body, // Include response body for more details
      };
    }
  }
}
