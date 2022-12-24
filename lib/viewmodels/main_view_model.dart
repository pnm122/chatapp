import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/service/database_service.dart';

class MainViewModel with ChangeNotifier {
  String _currentUserName = "";
  String _selectedGroupId = "";
  String _selectedGroupName = "";
  // Store in viewmodel in the hopes that this reduces reads
  Stream? _selectedGroupMembers;
  Stream<QuerySnapshot<Object?>>? _messages;

  String get currentUserName => _currentUserName;
  String get selectedGroupId => _selectedGroupId;
  String get selectedGroupName => _selectedGroupName;
  Stream? get selectedGroupMembers => _selectedGroupMembers;
  Stream? get messages => _messages;

  set currentUserName(name) {
    _currentUserName = name;
  }

  set selectedGroupId(id) {
    _selectedGroupId = id;
    _messages = DatabaseService().getMessages(_selectedGroupId);
    notifyListeners();
  }

  set selectedGroupName(name) {
    _selectedGroupName = name;
    notifyListeners();
  }

  setSelectedGroupMembers(List members) {
    _selectedGroupMembers = DatabaseService().getGroupUsers(selectedGroupId);
    notifyListeners();
  }
}