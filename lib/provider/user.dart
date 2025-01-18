import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  dynamic _data;
  String _userId = "";

  void setData(var data) {
    _userId = data.id;
    _data = data;
    notifyListeners();
  }

  getData() => _data;
  getUserId() => _userId;
}
