import 'package:flutter/foundation.dart';
import '../models/consumption_record.dart';
import '../services/api_service.dart';

class ConsumptionProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<ConsumptionRecord> _records = [];
  bool _isLoading = false;
  String? _error;

  List<ConsumptionRecord> get records => _records;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchConsumptionRecords() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _records = await _apiService.getConsumptionRecords();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addConsumptionRecord(ConsumptionRecordCreate record) async {
    try {
      final newRecord = await _apiService.createConsumptionRecord(record);
      _records.add(newRecord);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateConsumptionRecord(int recordId, ConsumptionRecordUpdate recordUpdate) async {
    try {
      final updatedRecord = await _apiService.updateConsumptionRecord(recordId, recordUpdate);
      final index = _records.indexWhere((r) => r.id == recordId);
      if (index != -1) {
        _records[index] = updatedRecord;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteConsumptionRecord(int recordId) async {
    try {
      await _apiService.deleteConsumptionRecord(recordId);
      _records.removeWhere((record) => record.id == recordId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
} 