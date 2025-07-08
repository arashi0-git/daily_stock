import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/items_provider.dart';
import '../providers/consumption_provider.dart';
import '../models/daily_item.dart';
import '../models/consumption_record.dart';

class ItemDetailScreen extends StatefulWidget {
  final int itemId;

  const ItemDetailScreen({super.key, required this.itemId});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  DailyItem? _item;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadItemData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadItemData() {
    final itemsProvider = Provider.of<ItemsProvider>(context, listen: false);
    _item = itemsProvider.items.firstWhere(
      (item) => item.id == widget.itemId,
      orElse: () => throw Exception('商品が見つかりません'),
    );
    setState(() {
      _isLoading = false;
    });

    // 消費記録も取得
    Provider.of<ConsumptionProvider>(context, listen: false)
        .fetchConsumptionRecords();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _item == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('商品詳細'),
          leading: IconButton(
            onPressed: () => context.go('/items'),
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_item!.name),
        leading: IconButton(
          onPressed: () => context.go('/items'),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            onPressed: () => _showEditDialog(context),
            icon: const Icon(Icons.edit),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.info), text: '詳細'),
            Tab(icon: Icon(Icons.shopping_cart), text: '購入'),
            Tab(icon: Icon(Icons.remove_shopping_cart), text: '消費'),
            Tab(icon: Icon(Icons.history), text: '履歴'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDetailTab(),
          _buildPurchaseTab(),
          _buildConsumptionTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildDetailTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 在庫状況カード
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _item!.isLowStock ? Icons.warning : Icons.check_circle,
                        color: _item!.isLowStock ? Colors.red : Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '在庫状況',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '現在の在庫',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        '${_item!.currentQuantity}${_item!.unit}',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              color:
                                  _item!.isLowStock ? Colors.red : Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('最小在庫閾値'),
                      Text('${_item!.minimumThreshold}${_item!.unit}'),
                    ],
                  ),
                  if (_item!.isLowStock) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning,
                              color: Colors.red.shade600, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '在庫が不足しています。早急に補充をお勧めします。',
                              style: TextStyle(color: Colors.red.shade700),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 商品詳細情報カード
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '商品情報',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('商品名', _item!.name),
                  if (_item!.description != null &&
                      _item!.description!.isNotEmpty)
                    _buildInfoRow('説明', _item!.description!),
                  _buildInfoRow('単位', _item!.unit),
                  _buildInfoRow(
                      '推定消費日数', '${_item!.estimatedConsumptionDays}日'),
                  if (_item!.price != null)
                    _buildInfoRow('価格', '¥${_item!.price!.toStringAsFixed(0)}'),
                  if (_item!.purchaseUrl != null &&
                      _item!.purchaseUrl!.isNotEmpty)
                    _buildInfoRow('購入URL', _item!.purchaseUrl!, isUrl: true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '商品購入',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '現在の在庫: ${_item!.currentQuantity}${_item!.unit}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showPurchaseDialog(context, 1),
                          icon: const Icon(Icons.add),
                          label: Text('1${_item!.unit}購入'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showPurchaseDialog(context, 5),
                          icon: const Icon(Icons.add),
                          label: Text('5${_item!.unit}購入'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showCustomPurchaseDialog(context),
                      icon: const Icon(Icons.shopping_cart),
                      label: const Text('カスタム数量で購入'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 購入推奨カード
          if (_item!.isLowStock) ...[
            const SizedBox(height: 16),
            Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb, color: Colors.orange.shade600),
                        const SizedBox(width: 8),
                        Text(
                          '購入推奨',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade600,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '在庫が少なくなっています。推定消費日数を考慮して、${_getRecommendedPurchaseQuantity()}${_item!.unit}の購入をお勧めします。',
                      style: TextStyle(color: Colors.orange.shade700),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => _showPurchaseDialog(
                          context, _getRecommendedPurchaseQuantity()),
                      icon: const Icon(Icons.shopping_cart),
                      label: Text(
                          '推奨数量(${_getRecommendedPurchaseQuantity()}${_item!.unit})で購入'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade600,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConsumptionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '消費記録',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '現在の在庫: ${_item!.currentQuantity}${_item!.unit}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showConsumptionDialog(context, 1),
                          icon: const Icon(Icons.remove),
                          label: Text('1${_item!.unit}消費'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showConsumptionDialog(context, 2),
                          icon: const Icon(Icons.remove),
                          label: Text('2${_item!.unit}消費'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showCustomConsumptionDialog(context),
                      icon: const Icon(Icons.remove_shopping_cart),
                      label: const Text('カスタム数量で消費'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 消費記録の注意事項カード
          const SizedBox(height: 16),
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue.shade600),
                      const SizedBox(width: 8),
                      Text(
                        '消費記録について',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade600,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '• 消費記録を追加すると、在庫数が自動的に減少します\n• 消費した日付やメモを追加できます\n• 履歴タブで過去の消費記録を確認できます',
                    style: TextStyle(color: Colors.blue.shade700),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return Consumer<ConsumptionProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final itemRecords = provider.records
            .where((record) => record.itemId == widget.itemId)
            .toList()
          ..sort((a, b) => b.consumptionDate.compareTo(a.consumptionDate));

        if (itemRecords.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  '消費履歴がありません',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: itemRecords.length,
          itemBuilder: (context, index) {
            final record = itemRecords[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.shopping_basket),
                title: Text('${record.consumedQuantity}${_item!.unit} 消費'),
                subtitle: Text(
                  '${record.consumptionDate.year}/${record.consumptionDate.month}/${record.consumptionDate.day}',
                ),
                trailing: record.notes != null && record.notes!.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.notes),
                        onPressed: () =>
                            _showNotesDialog(context, record.notes!),
                      )
                    : null,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isUrl = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: isUrl
                ? GestureDetector(
                    onTap: () {
                      // URLを開く処理を実装
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('URL: $value')),
                      );
                    },
                    child: Text(
                      value,
                      style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                : Text(value),
          ),
        ],
      ),
    );
  }

  int _getRecommendedPurchaseQuantity() {
    // 最小閾値の2倍程度を推奨数量とする
    return (_item!.minimumThreshold * 2).clamp(1, 50);
  }

  void _showPurchaseDialog(BuildContext context, int quantity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('購入確認'),
        content: Text('${_item!.name}を${quantity}${_item!.unit}購入しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _purchaseItem(quantity);
            },
            child: const Text('購入'),
          ),
        ],
      ),
    );
  }

  void _showCustomPurchaseDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('カスタム購入'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${_item!.name}の購入数量を入力してください'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '購入数量',
                suffixText: _item!.unit,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () async {
              final quantity = int.tryParse(controller.text);
              if (quantity != null && quantity > 0) {
                Navigator.of(context).pop();
                await _purchaseItem(quantity);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('有効な数量を入力してください')),
                );
              }
            },
            child: const Text('購入'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    context.go('/items/${widget.itemId}/edit');
  }

  void _showNotesDialog(BuildContext context, String notes) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('メモ'),
        content: Text(notes),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  void _showConsumptionDialog(BuildContext context, int quantity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('消費確認'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${_item!.name}を${quantity}${_item!.unit}消費しますか？'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today,
                      size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    '消費日付: ${DateTime.now().year}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().day.toString().padLeft(2, '0')}',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _consumeItem(quantity, consumptionDate: DateTime.now());
            },
            child: const Text('消費'),
          ),
        ],
      ),
    );
  }

  void _showCustomConsumptionDialog(BuildContext context) {
    final quantityController = TextEditingController();
    final notesController = TextEditingController();

    // デフォルトで当日の日付を設定
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('カスタム消費'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${_item!.name}の消費記録を追加します'),
                const SizedBox(height: 16),

                // 消費数量
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: '消費数量 *',
                    suffixText: _item!.unit,
                    border: const OutlineInputBorder(),
                    helperText: '1以上の数値を入力してください',
                  ),
                ),
                const SizedBox(height: 16),

                // 消費日付
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2020),
                            lastDate:
                                DateTime.now().add(const Duration(days: 1)),
                            locale: const Locale('ja', 'JP'),
                          );
                          if (picked != null) {
                            setState(() {
                              selectedDate = picked;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: '消費日付',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            '${selectedDate.year}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.day.toString().padLeft(2, '0')}',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // メモ
                TextField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'メモ（任意）',
                    hintText: '消費の詳細やメモを入力',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),

                // 在庫情報
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Colors.grey.shade600, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        '現在の在庫: ${_item!.currentQuantity}${_item!.unit}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () async {
                // バリデーション
                final quantityText = quantityController.text.trim();
                if (quantityText.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('消費数量を入力してください')),
                  );
                  return;
                }

                final quantity = int.tryParse(quantityText);
                if (quantity == null || quantity <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('有効な数量を入力してください（1以上の整数）')),
                  );
                  return;
                }

                if (quantity > _item!.currentQuantity) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('在庫数を超えて消費することはできません')),
                  );
                  return;
                }

                // ダイアログを閉じる
                Navigator.of(context).pop();

                // 消費処理を実行
                await _consumeItem(
                  quantity,
                  consumptionDate: selectedDate,
                  notes: notesController.text.trim().isEmpty
                      ? null
                      : notesController.text.trim(),
                );
              },
              child: const Text('消費'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _purchaseItem(int quantity) async {
    try {
      await Provider.of<ItemsProvider>(context, listen: false)
          .purchaseItem(widget.itemId, quantity);

      // 商品データを再読み込み
      await Provider.of<ItemsProvider>(context, listen: false).fetchItems();
      _loadItemData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${quantity}${_item!.unit}購入しました')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('購入に失敗しました: $e')),
        );
      }
    }
  }

  Future<void> _consumeItem(int quantity,
      {DateTime? consumptionDate, String? notes}) async {
    try {
      if (quantity > _item!.currentQuantity) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('在庫数を超えて消費することはできません')),
        );
        return;
      }

      // 日付を送信せず、バックエンド側でデフォルト値（今日の日付）を使用
      // メモが空の場合はnullにする
      final cleanNotes = notes?.trim();
      final consumptionRecord = ConsumptionRecordCreate(
        itemId: widget.itemId,
        consumedQuantity: quantity,
        // consumptionDate は明示的にnullを設定
        consumptionDate: consumptionDate,
        notes: cleanNotes?.isEmpty == true ? null : cleanNotes,
      );

      await Provider.of<ConsumptionProvider>(context, listen: false)
          .addConsumptionRecord(consumptionRecord);

      // 商品データを再読み込み
      await Provider.of<ItemsProvider>(context, listen: false).fetchItems();
      _loadItemData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${quantity}${_item!.unit}消費しました')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('消費記録の追加に失敗しました: $e')),
        );
      }
    }
  }
}
