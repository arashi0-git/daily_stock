import 'package:flutter/foundation.dart';
import '../models/daily_item.dart';
import '../services/api_service.dart';

class ItemsProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<DailyItem> _items = [];
  bool _isLoading = false;
  String? _error;

  List<DailyItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _items = await _apiService.getItems();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addItem(DailyItemCreate item) async {
    try {
      final newItem = await _apiService.createItem(item);
      _items.add(newItem);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateItem(int itemId, DailyItemUpdate itemUpdate) async {
    try {
      final updatedItem = await _apiService.updateItem(itemId, itemUpdate);
      final index = _items.indexWhere((i) => i.id == itemId);
      if (index != -1) {
        _items[index] = updatedItem;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteItem(int itemId) async {
    try {
      await _apiService.deleteItem(itemId);
      _items.removeWhere((item) => item.id == itemId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
} 