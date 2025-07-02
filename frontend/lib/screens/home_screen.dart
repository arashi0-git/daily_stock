import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/recommendations_provider.dart';
import '../providers/items_provider.dart';
import '../widgets/recommendation_notifications.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // 画面が表示されたら推奨データを取得
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecommendationsProvider>().refresh();
      context.read<ItemsProvider>().fetchItems();
    });
  }

  // データの定期的な更新を追加
  Future<void> _refreshAllData() async {
    if (!mounted) return;
    await context.read<ItemsProvider>().fetchItems();
    if (!mounted) return;
    await context.read<RecommendationsProvider>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('日用品管理アプリ'),
        actions: [
          // 推奨更新ボタン
          IconButton(
            onPressed: () {
              context
                  .read<RecommendationsProvider>()
                  .generateAllRecommendations();
            },
            icon: const Icon(Icons.refresh),
            tooltip: '推奨を更新',
          ),
          IconButton(
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              context.go('/login');
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (!mounted) return;
          await _refreshAllData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 在庫アラートセクション（改善版）- タイトル直下に配置
              _buildEnhancedStockAlertSection(context),

              // 推奨通知エリア
              const RecommendationNotifications(),

              // メニューグリッド
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'メニュー',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _buildMenuCard(
                          context,
                          '商品管理',
                          Icons.inventory,
                          '商品の追加・編集・削除',
                          () => context.go('/items'),
                        ),
                        _buildMenuCard(
                          context,
                          '消費記録',
                          Icons.shopping_cart,
                          '商品の消費を記録',
                          () => context.go('/consumption'),
                        ),
                        _buildMenuCard(
                          context,
                          '消費推奨',
                          Icons.lightbulb,
                          '購入推奨とアドバイス',
                          () => _showRecommendationsDialog(context),
                        ),
                        _buildMenuCard(
                          context,
                          '統計・分析',
                          Icons.analytics,
                          '消費傾向と在庫予測',
                          () => context.go('/analytics'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _buildMenuCard(
                          context,
                          '設定',
                          Icons.settings,
                          'アプリの設定変更',
                          () => _showSettingsDialog(context),
                        ),
                        _buildMenuCard(
                          context,
                          'ヘルプ',
                          Icons.help_outline,
                          '使い方とサポート',
                          () => _showHelpDialog(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    IconData icon,
    String description,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }


  void _showRecommendationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.lightbulb,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '消費推奨一覧',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: Consumer<RecommendationsProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (provider.recommendations.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.check_circle,
                                size: 64,
                                color: Colors.green,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '現在、推奨はありません',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '全ての商品の在庫が十分です',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: provider.recommendations.length,
                        itemBuilder: (context, index) {
                          final recommendation =
                              provider.recommendations[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: Icon(
                                recommendation.urgencyIcon,
                                color: recommendation.urgencyColor,
                              ),
                              title: Text(
                                recommendation.item?.name ?? '不明な商品',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    recommendation.recommendationMessage,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '残り${recommendation.estimatedDaysRemaining}日',
                                    style: TextStyle(
                                      color: recommendation.urgencyColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: recommendation.urgencyColor
                                      .withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  recommendation.urgencyText,
                                  style: TextStyle(
                                    color: recommendation.urgencyColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context
                          .read<RecommendationsProvider>()
                          .generateAllRecommendations();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('推奨を更新'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 改善された在庫アラートセクション
  Widget _buildEnhancedStockAlertSection(BuildContext context) {
    return Consumer<ItemsProvider>(
      builder: (context, itemsProvider, child) {
        // ローディング中のインジケータ
        if (itemsProvider.isLoading) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // エラー状態の表示
        if (itemsProvider.error != null) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Column(
              children: [
                Icon(Icons.error, color: Colors.red.shade600, size: 32),
                const SizedBox(height: 8),
                Text(
                  'データの読み込みに失敗しました',
                  style: TextStyle(color: Colors.red.shade600),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => _refreshAllData(),
                  child: const Text('再試行'),
                ),
              ],
            ),
          );
        }

        final lowStockItems = itemsProvider.items
            .where((item) => item.currentQuantity <= item.minimumThreshold)
            .toList();

        // 商品がない場合の表示
        if (itemsProvider.items.isEmpty) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              children: [
                Icon(Icons.inventory_2, color: Colors.blue.shade600, size: 48),
                const SizedBox(height: 12),
                Text(
                  '商品をまだ登録していません',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade600,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  '商品管理から商品を追加してください',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.blue.shade600,
                      ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => context.go('/items'),
                  icon: const Icon(Icons.add),
                  label: const Text('商品を追加'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }

        // 在庫が十分な場合の表示
        if (lowStockItems.isEmpty) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.green.withValues(alpha: 0.1),
                  Colors.teal.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.shade300),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade600,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '在庫状況良好',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade600,
                                ),
                      ),
                      Text(
                        'すべての商品の在庫が十分です',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.green.shade700,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        // 低在庫アラート表示（既存の機能を改善）
        return _buildStockAlertSection(context);
      },
    );
  }

  Widget _buildStockAlertSection(BuildContext context) {
    return Consumer<ItemsProvider>(
      builder: (context, itemsProvider, child) {
        // ローディング中は非表示
        if (itemsProvider.isLoading) {
          return const SizedBox.shrink();
        }

        final lowStockItems = itemsProvider.items
            .where((item) => item.currentQuantity <= item.minimumThreshold)
            .toList();

        if (lowStockItems.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.red.withValues(alpha: 0.1),
                Colors.orange.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.red.shade400,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
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
                        color: Colors.red.shade600,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.warning,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '在庫アラート',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade600,
                                ),
                          ),
                          Text(
                            '${lowStockItems.length}件の商品で在庫が不足しています',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red.shade600.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '発注推奨',
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

                // 低在庫商品一覧
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: Colors.red.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '発注が必要な商品',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      ...lowStockItems.take(3).map((item) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: Colors.red.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.inventory_2,
                                  color: Colors.red.shade600,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      Text(
                                        '現在: ${item.currentQuantity}${item.unit} / 最低: ${item.minimumThreshold}${item.unit}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Colors.red.shade700,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '緊急',
                                  style: TextStyle(
                                    color: Colors.red.shade600,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          )),
                      if (lowStockItems.length > 3)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '他 ${lowStockItems.length - 3} 件...',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey.shade600,
                                    ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // アクションボタン
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.go('/items');
                        },
                        icon: const Icon(Icons.shopping_cart),
                        label: const Text('発注する'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        context
                            .read<RecommendationsProvider>()
                            .generateAllRecommendations();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('更新'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 設定画面を表示
  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.settings,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'アプリ設定',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: ListView(
                    children: [
                      _buildSettingsTile(
                        context,
                        '通知設定',
                        '在庫アラートの通知設定',
                        Icons.notifications,
                        () => _showNotificationSettings(context),
                      ),
                      _buildSettingsTile(
                        context,
                        'デフォルト閾値設定',
                        '新規商品の最小在庫閾値',
                        Icons.tune,
                        () => _showThresholdSettings(context),
                      ),
                      _buildSettingsTile(
                        context,
                        'データエクスポート',
                        '消費記録をCSV形式で出力',
                        Icons.download,
                        () => _exportData(context),
                      ),
                      _buildSettingsTile(
                        context,
                        'アプリ情報',
                        'バージョン情報とライセンス',
                        Icons.info,
                        () => _showAppInfo(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ヘルプ画面を表示
  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.help_outline,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'ヘルプとサポート',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: ListView(
                    children: [
                      _buildHelpSection(
                        context,
                        '基本的な使い方',
                        '商品の登録、消費記録、在庫管理の方法',
                        Icons.play_circle_outline,
                      ),
                      _buildHelpSection(
                        context,
                        '在庫アラート',
                        '低在庫通知の設定と対応方法',
                        Icons.warning_amber,
                      ),
                      _buildHelpSection(
                        context,
                        '統計・分析機能',
                        '消費傾向の見方と予測の活用方法',
                        Icons.analytics,
                      ),
                      _buildHelpSection(
                        context,
                        'よくある質問',
                        'トラブルシューティングとFAQ',
                        Icons.quiz,
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.contact_support,
                            color: Colors.blue),
                        title: const Text('お問い合わせ'),
                        subtitle: const Text('機能に関するご質問やご提案'),
                        onTap: () => _showContactInfo(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildHelpSection(
    BuildContext context,
    String title,
    String description,
    IconData icon,
  ) {
    return ExpansionTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(title),
      subtitle: Text(description),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getHelpContent(title),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getHelpContent(String section) {
    switch (section) {
      case '基本的な使い方':
        return '''
1. 商品管理から新しい商品を登録します
2. 最小在庫閾値を設定します
3. 消費記録で商品の使用量を記録します
4. 統計・分析で消費傾向を確認できます
5. 在庫が少なくなると自動でアラートが表示されます
        ''';
      case '在庫アラート':
        return '''
• 在庫が設定した最小閾値以下になると自動で通知されます
• ホーム画面の上部に赤いアラートが表示されます
• 「発注する」ボタンから商品管理画面に移動できます
• 設定から通知のタイミングを調整できます
        ''';
      case '統計・分析機能':
        return '''
• 各商品の平均消費スピードを自動計算します
• 在庫切れ予想日を表示します
• 消費パターンの分析結果を確認できます
• データが蓄積されるほど予測精度が向上します
        ''';
      case 'よくある質問':
        return '''
Q: 在庫アラートが表示されません
A: 商品の現在在庫が最小閾値以下に設定されているか確認してください

Q: 統計が正確でない
A: 消費記録が十分蓄積されていない可能性があります

Q: データを初期化したい
A: 設定画面からデータエクスポート後に初期化できます
        ''';
      default:
        return 'ヘルプ情報を準備中です。';
    }
  }

  void _showNotificationSettings(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('通知設定画面は今後追加予定です')),
    );
  }

  void _showThresholdSettings(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('閾値設定画面は今後追加予定です')),
    );
  }

  void _exportData(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('データエクスポート機能は今後追加予定です')),
    );
  }

  void _showAppInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('アプリ情報'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('日用品管理アプリ'),
            SizedBox(height: 8),
            Text('バージョン: 1.0.0'),
            SizedBox(height: 8),
            Text('開発: 日用品管理チーム'),
            SizedBox(height: 8),
            Text('© 2024 All rights reserved'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  void _showContactInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('お問い合わせ'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ご質問やご提案がございましたら、\n以下までお気軽にお問い合わせください。'),
            SizedBox(height: 16),
            Text('メール: support@dailystock.app'),
            SizedBox(height: 8),
            Text('GitHub: github.com/dailystock'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }
}
