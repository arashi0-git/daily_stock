import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/consumption_provider.dart';
import '../providers/items_provider.dart';
import '../models/consumption_record.dart';

class ConsumptionScreen extends StatefulWidget {
  const ConsumptionScreen({super.key});

  @override
  State<ConsumptionScreen> createState() => _ConsumptionScreenState();
}

class _ConsumptionScreenState extends State<ConsumptionScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<ConsumptionProvider>(context, listen: false).fetchConsumptionRecords();
      Provider.of<ItemsProvider>(context, listen: false).fetchItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('消費記録'),
        leading: IconButton(
          onPressed: () => context.go('/home'),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            onPressed: () => _showAddRecordDialog(context),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Consumer<ConsumptionProvider>(
        builder: (context, consumptionProvider, child) {
          if (consumptionProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (consumptionProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'エラーが発生しました',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      consumptionProvider.error!,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => consumptionProvider.fetchConsumptionRecords(),
                    child: const Text('再読み込み'),
                  ),
                ],
              ),
            );
          }

          if (consumptionProvider.records.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    '消費記録がありません',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '右上の + ボタンから記録を追加してください',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: consumptionProvider.records.length,
            itemBuilder: (context, index) {
              final record = consumptionProvider.records[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.shopping_cart),
                  ),
                  title: Text(record.item?.name ?? '商品ID: ${record.itemId}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('消費量: ${record.consumedQuantity}'),
                      Text('日付: ${record.consumptionDate.toString().split(' ')[0]}'),
                      if (record.notes != null && record.notes!.isNotEmpty)
                        Text('メモ: ${record.notes}'),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    onPressed: () => _showDeleteConfirmation(context, record.id),
                    icon: const Icon(Icons.delete, color: Colors.red),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddRecordDialog(BuildContext context) {
    final consumedQuantityController = TextEditingController();
    final notesController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    int? selectedItemId;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('消費記録を追加'),
        scrollable: true,
        content: StatefulBuilder(
          builder: (context, setState) {
            return SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Consumer<ItemsProvider>(
                    builder: (context, itemsProvider, child) {
                      if (itemsProvider.items.isEmpty) {
                        return const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              '商品が登録されていません。\n先に商品を登録してください。',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }

                      return DropdownButtonFormField<int>(
                        value: selectedItemId,
                        decoration: const InputDecoration(
                          labelText: '商品を選択 *',
                          border: OutlineInputBorder(),
                        ),
                        items: itemsProvider.items.map((item) {
                          return DropdownMenuItem<int>(
                            value: item.id,
                            child: Text('${item.name} (在庫: ${item.currentQuantity})'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedItemId = value;
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: consumedQuantityController,
                    decoration: const InputDecoration(
                      labelText: '消費量 *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('消費日付'),
                    subtitle: Text(selectedDate.toString().split(' ')[0]),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          selectedDate = date;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'メモ',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (selectedItemId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('商品を選択してください')),
                );
                return;
              }

              final consumedQuantity = int.tryParse(consumedQuantityController.text);
              if (consumedQuantity == null || consumedQuantity <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('正しい消費量を入力してください')),
                );
                return;
              }

              final newRecord = ConsumptionRecordCreate(
                itemId: selectedItemId!,
                consumedQuantity: consumedQuantity,
                consumptionDate: selectedDate,
                notes: notesController.text.trim().isEmpty
                    ? null
                    : notesController.text.trim(),
              );

              Navigator.of(context).pop();
              
              // プロバイダーを使って消費記録を追加
              try {
                await Provider.of<ConsumptionProvider>(context, listen: false)
                    .addConsumptionRecord(newRecord);
                
                // 商品一覧も更新（在庫数が変わるため）
                if (mounted) {
                  Provider.of<ItemsProvider>(context, listen: false).fetchItems();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('消費記録を追加しました')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('エラー: $e')),
                  );
                }
              }
            },
            child: const Text('追加'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, int recordId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('削除確認'),
        content: const Text('この消費記録を削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Provider.of<ConsumptionProvider>(context, listen: false)
                  .deleteConsumptionRecord(recordId);
            },
            child: const Text('削除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
} 