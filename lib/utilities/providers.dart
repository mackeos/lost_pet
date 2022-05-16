import 'package:flutter/material.dart';
import 'package:lost_pet/models/user.dart';
import 'package:lost_pet/resources/auth_methods.dart';

class UserProvider with ChangeNotifier {
  User? _user;

  User get getUser => _user!;

  Future<void> refreshUser() async {
    User user = await AuthMethods().getUserDetails();
    _user = user;
    notifyListeners();
  }
}
