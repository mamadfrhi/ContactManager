import 'dart:convert';
import 'package:contact_manager_v4/data/model.dart';
import 'package:http/http.dart' as http;

abstract class APIScheme {
  Future<String> fetchContacts();
  Future<bool> deleteContact(String id);
  Future<bool> addContact(Contact ctc);
  Future<bool> updateContact(Contact ctc);
}

class API extends APIScheme {
  static API instance = API();
  final timeOut = Duration(seconds: 15);
  String _baseURL = 'https://mock-rest-api-server.herokuapp.com/api/v1';
  Map<String, String> header = {"Content-Type": "application/json"};

  @override
  Future<String> fetchContacts() async {
    final url = _baseURL + '/user';
    print('Sending Get Request');
    final response = await http.get(url).timeout(timeOut);
    if (response.statusCode == 200) {
      print('Sending Get Request -Done-');
      return response.body;
    } else {
      throw NetworkError();
    }
  }

  @override
  Future<bool> deleteContact(String id) async {
    final url = _baseURL + '/user' + '/$id';
    final response = await http.delete(url).timeout(timeOut);
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseID = json.decode(response.body);
      print(responseID);
      final convertedID = responseID['data'].toString();
      if (convertedID == id) {
        return true;
      } else {
        throw NetworkError();
      }
    } else {
      throw NetworkError();
    }
  }

  @override
  Future<bool> addContact(Contact ctc) async {
    if (ctc == null) {
      return false;
    }
    final url = _baseURL + '/user';

    Map<String, String> body = {
      "id": ctc.id,
      "first_name": ctc.firstname,
      "last_name": ctc.lastname,
      "email": ctc.email,
      "gender": ctc.gender,
      "date_of_birth": ctc.dateOfBirth,
      "phone_no": ctc.phoneNo
    };
    final bodyJson = json.encode(body);
    final response = await http.post(url, body: bodyJson, headers: header).timeout(timeOut);
    if (response.statusCode == 200) {
      return true;
    } else {
      throw NetworkError();
    }
  }

  @override
  Future<bool> updateContact(Contact ctc) async {
    if (ctc == null) {
      return false;
    }
    final url = _baseURL + '/user' + '/' + ctc.id;
    Map<String, dynamic> body = {
      "id": ctc.id,
      "first_name": ctc.firstname,
      "last_name": ctc.lastname,
      "email": ctc.email,
      "gender": ctc.gender,
      "date_of_birth": ctc.dateOfBirth,
      "phone_no": ctc.phoneNo
    };
    final bodyJson = json.encode(body);
    final response = await http.put(url, body: bodyJson, headers: header).timeout(timeOut);

    if (response.statusCode == 200) {
      return true;
    } else {
      throw NetworkError();
    }
  }
}

class NetworkError extends Error {}


