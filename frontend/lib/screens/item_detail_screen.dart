import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/items_provider.dart';
import '../providers/consumption_provider.dart';
import '../models/daily_item.dart';

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
    _tabController = TabController(length: 3, vsync: this);
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
    Provider.of<ConsumptionProvider>(context, listen: false).fetchConsumptionRecords();
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
            Tab(icon: Icon(Icons.history), text: '履歴'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDetailTab(),
          _buildPurchaseTab(),
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
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: _item!.isLowStock ? Colors.red : Colors.green,
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
                          Icon(Icons.warning, color: Colors.red.shade600, size: 20),
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
                  if (_item!.description != null && _item!.description!.isNotEmpty)
                    _buildInfoRow('説明', _item!.description!),
                  _buildInfoRow('単位', _item!.unit),
                  _buildInfoRow('推定消費日数', '${_item!.estimatedConsumptionDays}日'),
                  if (_item!.price != null)
                    _buildInfoRow('価格', '¥${_item!.price!.toStringAsFixed(0)}'),
                  if (_item!.purchaseUrl != null && _item!.purchaseUrl!.isNotEmpty)
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
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                      onPressed: () => _showPurchaseDialog(context, _getRecommendedPurchaseQuantity()),
                      icon: const Icon(Icons.shopping_cart),
                      label: Text('推奨数量(${_getRecommendedPurchaseQuantity()}${_item!.unit})で購入'),
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
                        onPressed: () => _showNotesDialog(context, record.notes!),
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

  Future<void> _purchaseItem(int quantity) async {
    try {
      await Provider.of<ItemsProvider>(context, listen: false)
          .purchaseItem(widget.itemId, quantity);
      
      // 商品データを再読み込み
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
} 