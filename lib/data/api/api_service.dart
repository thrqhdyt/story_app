import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:story_app/data/model/auth_response.dart';
import 'package:story_app/data/model/detail_story_response.dart';
import 'package:story_app/data/model/list_story_response.dart';
import 'package:story_app/data/model/upload_repsonse.dart';
import 'package:story_app/preferences/preferences_helper.dart';

class ApiService {
  static const String _baseUrl = 'https://story-api.dicoding.dev/v1';
  final PreferencesHelper preferencesHelper;

  ApiService({required this.preferencesHelper});

  Future<RegisterResponse> register(
      String name, String email, String password) async {
    final response = await http.post(
      Uri.parse("$_baseUrl/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": name, "email": email, "password": password}),
    );
    if (response.statusCode == 201) {
      return RegisterResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to register');
    }
  }

  Future<LoginResponse> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$_baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      return LoginResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<ListStoryResponse> listStory() async {
    final token = await preferencesHelper.getToken;
    final response = await http.get(
      Uri.parse("$_baseUrl/stories"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
    );

    if (response.statusCode == 200) {
      return ListStoryResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load list story');
    }
  }

  Future<DetailStoryResponse> detailStory(String id) async {
    final token = await preferencesHelper.getToken;
    final response = await http
        .get(Uri.parse("$_baseUrl/stories/$id"), headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token'
    });

    if (response.statusCode == 200) {
      return DetailStoryResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load detail story');
    }
  }

  Future<UploadResponse> addNewStory(
    List<int> bytes,
    String fileName,
    String description,
  ) async {
    final token = await preferencesHelper.getToken;
    final uri = Uri.parse("$_baseUrl/stories");
    var request = http.MultipartRequest('POST', uri);

    final multiPartFile = http.MultipartFile.fromBytes(
      "photo",
      bytes,
      filename: fileName,
    );

    final Map<String, String> fields = {
      "description": description,
    };

    final Map<String, String> headers = {
      "Content-type": "multipart/form-data",
      'Authorization': 'Bearer $token'
    };

    request.files.add(multiPartFile);
    request.fields.addAll(fields);
    request.headers.addAll(headers);

    final http.StreamedResponse streamedResponse = await request.send();
    final int statusCode = streamedResponse.statusCode;

    final Uint8List responseList = await streamedResponse.stream.toBytes();
    final String responseData = String.fromCharCodes(responseList);

    if (statusCode == 201) {
      final UploadResponse uploadResponse = UploadResponse.fromJson(
        responseData,
      );
      return uploadResponse;
    } else {
      throw Exception("Upload file error");
    }
  }
}
