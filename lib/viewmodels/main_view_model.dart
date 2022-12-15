import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/service/database_service.dart';

class MainViewModel with ChangeNotifier {
  String _selectedGroupId = "";
  String _selectedGroupName = "";
  Stream<QuerySnapshot<Object?>>? _messages;

  String get selectedGroupId => _selectedGroupId;
  String get selectedGroupName => _selectedGroupName;
  Stream? get messages => _messages;

  setSelectedGroupId(id) {
    _selectedGroupId = id;
    _messages = DatabaseService().getMessages(_selectedGroupId);
    notifyListeners();
  }

  setSelectedGroupName(name) {
    _selectedGroupName = name;
    notifyListeners();
  }
}