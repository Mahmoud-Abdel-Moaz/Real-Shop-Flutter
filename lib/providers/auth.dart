import 'package:flutter/material.dart';
import 'package:real_shop/models/http_exceptions.dart';
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  String? _userId;
  Timer? _authTimer;

  bool get isAuth {
    return _token != null;
  }

  String? get token {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token!;
    }
    return null;
  }

  String get userId {
    return _userId!;
  }

  Future<void> _authentication(
      String email, String password, String urlSegment) async {
    final url =
       'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyARPKIO0nF-E38Nvde93Ui5H-7GMVQxht4';
     //  'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyDJC15tnT_HcIei8m-rrhy1Y2YxXjjM5ts';
        //'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyDJC15tnT_HcIei8m-rrhy1Y2YxXjjM5ts';
    try {
      final res = await http.post(url,
          body: json.encode({
            'email': email,
            'password': password,
            "returnSecureToken": true
          }));
      final responceData = json.decode(res.body);
      if (responceData['error'] != null) {
        throw HttpException(responceData['error']['message']);
      }
      _token = responceData['idToken'];
      _userId = responceData['localId'];
      _expiryDate = DateTime.now()
          .add(Duration(milliseconds: int.parse(responceData['expiresIn'])));
      _autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      String userData = json.encode({
        'token': _token,
        'userId': userId,
        'expiryDate': _expiryDate!.toIso8601String(),
      });
      prefs.setString('userData', userData);
    } catch (e) {
      throw e;
    }
  }

  Future<void> signUp(String? email, String? password) async {
    return _authentication(email!, password!, "SignUp");
  }

  Future<void> login(String? email, String? password) async {
    return _authentication(email!, password!, "signInWithPassword");
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) return false;

    final Map<String, Object> extractedData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;

    final expiryData = DateTime.parse(extractedData['expiryDate'].toString());

    if (expiryData.isBefore(DateTime.now())) return false;

    _token = extractedData['token'].toString();
    _userId = extractedData['userId'].toString();
    _expiryDate = expiryData;
    notifyListeners();
      _autoLogout();

    return true;
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      prefs.clear();
    }

    notifyListeners();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }
    final timeToExpiry = _expiryDate!.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}
