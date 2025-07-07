import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/items_provider.dart';
import '../providers/consumption_provider.dart';
import '../models/daily_item.dart';
import '../models/consumption_record.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ItemsProvider>().fetchItems();
        context.read<ConsumptionProvider>().fetchConsumptionRecords();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('統計・分析'),
        actions: [
          IconButton(
            onPressed: () {
              if (mounted) {
                context.read<ItemsProvider>().fetchItems();
                context.read<ConsumptionProvider>().fetchConsumptionRecords();
              }
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'データを更新',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (!mounted) return;
          await context.read<ItemsProvider>().fetchItems();
          if (!mounted) return;
          await context.read<ConsumptionProvider>().fetchConsumptionRecords();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 予想枯渇日表示セクション
              _buildDepletionPredictionSection(context),

              const SizedBox(height: 24),

              Text(
                '消費傾向分析',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              // サマリーカード
              _buildSummaryCards(context),

              const SizedBox(height: 24),

              Text(
                '商品別分析',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              // 商品別分析リスト
              _buildItemAnalyticsList(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context) {
    return Consumer2<ItemsProvider, ConsumptionProvider>(
      builder: (context, itemsProvider, consumptionProvider, child) {
        final items = itemsProvider.items;
        final consumptionRecords = consumptionProvider.records;

        // 統計計算
        final totalItems = items.length;
        final lowStockItems = items
            .where((item) => item.currentQuantity <= item.minimumThreshold)
            .length;
        final totalConsumption = consumptionRecords.fold<int>(
            0, (sum, record) => sum + record.consumedQuantity);
        final averageConsumptionPerDay = consumptionRecords.isNotEmpty
            ? totalConsumption / _getDaysFromRecords(consumptionRecords)
            : 0.0;

        // 在庫切れ予想の最も早い商品を計算
        DateTime? earliestEmptyDate;
        String? earliestItem;
        for (final item in items) {
          final itemConsumption = consumptionRecords
              .where((record) => record.itemId == item.id)
              .toList();
          final analytics = _calculateItemAnalytics(item, itemConsumption);
          final emptyDate = analytics['estimatedEmptyDate'] as DateTime?;
          if (emptyDate != null &&
              (earliestEmptyDate == null ||
                  emptyDate.isBefore(earliestEmptyDate))) {
            earliestEmptyDate = emptyDate;
            earliestItem = item.name;
          }
        }

        return Column(
          children: [
            // 基本統計カード
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    context,
                    '総商品数',
                    totalItems.toString(),
                    Icons.inventory,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    context,
                    '低在庫商品',
                    lowStockItems.toString(),
                    Icons.warning,
                    lowStockItems > 0 ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 消費統計カード
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    context,
                    '平均消費量',
                    '${averageConsumptionPerDay.toStringAsFixed(1)}/日',
                    Icons.trending_up,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    context,
                    '次回発注予定',
                    earliestEmptyDate != null
                        ? '${earliestEmptyDate.month}/${earliestEmptyDate.day}'
                        : '未定',
                    Icons.schedule,
                    earliestEmptyDate != null &&
                            earliestEmptyDate
                                    .difference(DateTime.now())
                                    .inDays <=
                                7
                        ? Colors.red
                        : Colors.green,
                    subtitle: earliestItem,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard(BuildContext context, String title, String value,
      IconData icon, Color color,
      {String? subtitle}) {
    return Card(
      elevation: 4,
      shadowColor: color.withOpacity(0.3),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemAnalyticsList(BuildContext context) {
    return Consumer2<ItemsProvider, ConsumptionProvider>(
      builder: (context, itemsProvider, consumptionProvider, child) {
        final items = itemsProvider.items;
        final consumptionRecords = consumptionProvider.records;

        if (items.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Icon(
                    Icons.inbox,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '商品が登録されていません',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: items.map((item) {
            final itemConsumption = consumptionRecords
                .where((record) => record.itemId == item.id)
                .toList();

            final analytics = _calculateItemAnalytics(item, itemConsumption);

            return _buildItemAnalyticsCard(context, item, analytics);
          }).toList(),
        );
      },
    );
  }

  Widget _buildItemAnalyticsCard(
    BuildContext context,
    DailyItem item,
    Map<String, dynamic> analytics,
  ) {
    final averageConsumption = analytics['averageConsumption'] as double;
    final estimatedDaysLeft = analytics['estimatedDaysLeft'] as int;
    final estimatedEmptyDate = analytics['estimatedEmptyDate'] as DateTime?;
    final isLowStock = item.currentQuantity <= item.minimumThreshold;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        isLowStock ? Colors.red.shade100 : Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.inventory_2,
                    color:
                        isLowStock ? Colors.red.shade600 : Colors.blue.shade600,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      Text(
                        '現在在庫: ${item.currentQuantity}${item.unit}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: isLowStock
                                  ? Colors.red.shade600
                                  : Colors.grey.shade600,
                            ),
                      ),
                    ],
                  ),
                ),
                if (isLowStock)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '低在庫',
                      style: TextStyle(
                        color: Colors.red.shade600,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // 統計情報
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildAnalyticsItem(
                          context,
                          '平均消費スピード',
                          averageConsumption > 0
                              ? '${averageConsumption.toStringAsFixed(2)}${item.unit}/日'
                              : 'データ不足',
                          Icons.speed,
                          Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildAnalyticsItem(
                          context,
                          '残り予想日数',
                          estimatedDaysLeft > 0
                              ? '$estimatedDaysLeft日'
                              : '計算不可',
                          Icons.schedule,
                          estimatedDaysLeft <= 7 ? Colors.red : Colors.green,
                        ),
                      ),
                    ],
                  ),
                  if (estimatedEmptyDate != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: estimatedDaysLeft <= 7
                            ? Colors.red.shade50
                            : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: estimatedDaysLeft <= 7
                              ? Colors.red.shade200
                              : Colors.blue.shade200,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.event,
                            color: estimatedDaysLeft <= 7
                                ? Colors.red.shade600
                                : Colors.blue.shade600,
                            size: 20,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '在庫切れ予想日',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: estimatedDaysLeft <= 7
                                          ? Colors.red.shade600
                                          : Colors.blue.shade600,
                                    ),
                          ),
                          Text(
                            '${estimatedEmptyDate.year}年${estimatedEmptyDate.month}月${estimatedEmptyDate.day}日',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: estimatedDaysLeft <= 7
                                      ? Colors.red.shade600
                                      : Colors.blue.shade600,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Map<String, dynamic> _calculateItemAnalytics(
    DailyItem item,
    List<ConsumptionRecord> consumptionRecords,
  ) {
    if (consumptionRecords.isEmpty) {
      return {
        'averageConsumption': 0.0,
        'estimatedDaysLeft': 0,
        'estimatedEmptyDate': null,
      };
    }

    // 消費記録から平均消費量を計算
    final totalConsumption = consumptionRecords.fold<int>(
      0,
      (sum, record) => sum + record.consumedQuantity,
    );

    final daysWithData = _getDaysFromRecords(consumptionRecords);
    final averageConsumption =
        daysWithData > 0 ? totalConsumption / daysWithData : 0.0;

    // 在庫切れ予想日を計算
    int estimatedDaysLeft = 0;
    DateTime? estimatedEmptyDate;

    if (averageConsumption > 0) {
      estimatedDaysLeft = (item.currentQuantity / averageConsumption).ceil();
      estimatedEmptyDate =
          DateTime.now().add(Duration(days: estimatedDaysLeft));
    }

    return {
      'averageConsumption': averageConsumption,
      'estimatedDaysLeft': estimatedDaysLeft,
      'estimatedEmptyDate': estimatedEmptyDate,
    };
  }

  // 枯渇予想日表示セクション
  Widget _buildDepletionPredictionSection(BuildContext context) {
    return Consumer2<ItemsProvider, ConsumptionProvider>(
      builder: (context, itemsProvider, consumptionProvider, child) {
        final items = itemsProvider.items;
        final consumptionRecords = consumptionProvider.records;
        
        if (items.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Icon(
                    Icons.inventory_2,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '商品が登録されていません',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '商品を登録してから統計を確認してください',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // 各商品の枯渇予想日を計算
        final depletionPredictions = <Map<String, dynamic>>[];
        
        for (final item in items) {
          final itemConsumption = consumptionRecords
              .where((record) => record.itemId == item.id)
              .toList();
          final analytics = _calculateItemAnalytics(item, itemConsumption);
          
          depletionPredictions.add({
            'item': item,
            'estimatedEmptyDate': analytics['estimatedEmptyDate'],
            'estimatedDaysLeft': analytics['estimatedDaysLeft'],
            'averageConsumption': analytics['averageConsumption'],
          });
        }
        
        // 枯渇予想日順にソート（nullは最後）
        depletionPredictions.sort((a, b) {
          final dateA = a['estimatedEmptyDate'] as DateTime?;
          final dateB = b['estimatedEmptyDate'] as DateTime?;
          
          if (dateA == null && dateB == null) return 0;
          if (dateA == null) return 1;
          if (dateB == null) return -1;
          
          return dateA.compareTo(dateB);
        });

        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.schedule,
                        color: Colors.blue.shade600,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '商品枯渇予想日',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '現在の消費ペースに基づいた各商品の在庫切れ予想日です',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 16),
                
                // 枯渇予想リスト
                ...depletionPredictions.take(5).map((prediction) {
                  final item = prediction['item'] as DailyItem;
                  final estimatedEmptyDate = prediction['estimatedEmptyDate'] as DateTime?;
                  final estimatedDaysLeft = prediction['estimatedDaysLeft'] as int;
                  final averageConsumption = prediction['averageConsumption'] as double;
                  
                  final isUrgent = estimatedDaysLeft > 0 && estimatedDaysLeft <= 7;
                  final isLowStock = item.currentQuantity <= item.minimumThreshold;
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isUrgent
                          ? Colors.red.shade50
                          : isLowStock
                              ? Colors.orange.shade50
                              : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isUrgent
                            ? Colors.red.shade200
                            : isLowStock
                                ? Colors.orange.shade200
                                : Colors.green.shade200,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isUrgent
                                ? Colors.red.shade600
                                : isLowStock
                                    ? Colors.orange.shade600
                                    : Colors.green.shade600,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            isUrgent ? Icons.warning : Icons.inventory_2,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (estimatedEmptyDate != null) ...[
                                Text(
                                  '予想枯渇日: ${estimatedEmptyDate.year}/${estimatedEmptyDate.month}/${estimatedEmptyDate.day}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: isUrgent
                                        ? Colors.red.shade700
                                        : Colors.grey.shade600,
                                  ),
                                ),
                                if (averageConsumption > 0)
                                  Text(
                                    '平均消費: ${averageConsumption.toStringAsFixed(2)}${item.unit}/日',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                              ] else
                                Text(
                                  '消費データが不足しています',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (estimatedDaysLeft > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isUrgent
                                      ? Colors.red.shade600
                                      : isLowStock
                                          ? Colors.orange.shade600
                                          : Colors.green.shade600,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '$estimatedDaysLeft日',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 4),
                            Text(
                              '現在: ${item.currentQuantity}${item.unit}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
                
                if (depletionPredictions.length > 5)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '他 ${depletionPredictions.length - 5} 商品の詳細は下記の商品別分析をご確認ください',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  double _getDaysFromRecords(List<ConsumptionRecord> records) {
    if (records.isEmpty) return 0.0;

    final dates = records.map((r) => r.consumptionDate).toSet().toList();
    dates.sort();

    if (dates.length < 2) return 1.0;

    final firstDate = dates.first;
    final lastDate = dates.last;

    return lastDate.difference(firstDate).inDays + 1.0;
  }
}
