import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/service/database_service.dart';

class MainViewModel with ChangeNotifier {
  String _selectedGroupId = "";
  String _selectedGroupName = "";
  List _selectedGroupMembers = [];
  Stream<QuerySnapshot<Object?>>? _messages;

  String get selectedGroupId => _selectedGroupId;
  String get selectedGroupName => _selectedGroupName;
  List get selectedGroupMembers => _selectedGroupMembers;
  Stream? get messages => _messages;

  set selectedGroupId(id) {
    _selectedGroupId = id;
    _messages = DatabaseService().getMessages(_selectedGroupId);
    notifyListeners();
  }

  set selectedGroupName(name) {
    _selectedGroupName = name;
    notifyListeners();
  }

  set selectedGroupMembers(members) {
    _selectedGroupMembers = members;
    notifyListeners();
  }
}