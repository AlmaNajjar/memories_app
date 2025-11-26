import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/memory.dart';

class MemoriesProvider with ChangeNotifier {
  final List<Memory> _memories = [];
  String? _userEmail;

  List<Memory> get memories {
    _memories.sort((a, b) => b.date.compareTo(a.date));
    return [..._memories];
  }

  Future<void> loadUserMemories(String email) async {
    _userEmail = email;
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString('memories_$email');

    if (savedData != null) {
      final decoded = jsonDecode(savedData) as List;
      _memories
        ..clear()
        ..addAll(
          decoded.map((e) => Memory.fromMap(Map<String, dynamic>.from(e))),
        );
      notifyListeners();
    }
  }

  Future<void> _saveMemories() async {
    if (_userEmail == null) return;
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_memories.map((m) => m.toMap()).toList());
    await prefs.setString('memories_$_userEmail', encoded);
  }

  void addMemory(Memory memory) {
    _memories.add(memory);
    _saveMemories();
    notifyListeners();
  }

  void updateMemory(Memory updatedMemory) {
    final index = _memories.indexWhere((mem) => mem.id == updatedMemory.id);
    if (index >= 0) {
      _memories[index] = updatedMemory;
      _saveMemories();
      notifyListeners();
    }
  }

  void deleteMemory(String id) {
    _memories.removeWhere((mem) => mem.id == id);
    _saveMemories();
    notifyListeners();
  }

  void clearMemories() {
    _memories.clear();
    notifyListeners();
  }
}
