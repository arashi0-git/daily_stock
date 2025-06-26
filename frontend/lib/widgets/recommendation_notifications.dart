import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/consumption_recommendation.dart';
import '../providers/recommendations_provider.dart';

class RecommendationNotifications extends StatelessWidget {
  const RecommendationNotifications({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RecommendationsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (provider.error != null) {
          return Card(
            margin: const EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 48,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'エラーが発生しました',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    provider.error!,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.clearError(),
                    child: const Text('閉じる'),
                  ),
                ],
              ),
            ),
          );
        }

        final urgentRecommendations = provider.urgentRecommendations;
        
        if (urgentRecommendations.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            // 緊急推奨の大きな表示
            if (urgentRecommendations.isNotEmpty)
              _buildUrgentRecommendationCard(context, urgentRecommendations.first),
            
            // その他の緊急推奨があれば追加表示
            if (urgentRecommendations.length > 1)
              _buildAdditionalUrgentRecommendations(context, urgentRecommendations.skip(1).toList()),
          ],
        );
      },
    );
  }

  Widget _buildUrgentRecommendationCard(BuildContext context, ConsumptionRecommendation recommendation) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            recommendation.urgencyColor.withOpacity(0.1),
            recommendation.urgencyColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: recommendation.urgencyColor,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: recommendation.urgencyColor.withOpacity(0.3),
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
            // ヘッダー部分
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: recommendation.urgencyColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    recommendation.urgencyIcon,
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
                        '${recommendation.urgencyText}推奨',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: recommendation.urgencyColor,
                        ),
                      ),
                      if (recommendation.item?.name != null)
                        Text(
                          recommendation.item!.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: recommendation.urgencyColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    recommendation.actionText,
                    style: TextStyle(
                      color: recommendation.urgencyColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // メッセージ部分
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: recommendation.urgencyColor.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recommendation.recommendationMessage,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 12),
                  
                  // 統計情報
                  Row(
                    children: [
                      _buildStatChip(
                        context,
                        '残り日数',
                        '${recommendation.estimatedDaysRemaining}日',
                        Icons.schedule,
                        recommendation.urgencyColor,
                      ),
                      const SizedBox(width: 8),
                      _buildStatChip(
                        context,
                        '信頼度',
                        '${(recommendation.confidenceScore * 100).round()}%',
                        Icons.verified,
                        Colors.blue,
                      ),
                    ],
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
                    onPressed: () => _acknowledgeRecommendation(context, recommendation),
                    icon: const Icon(Icons.check),
                    label: const Text('確認しました'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: recommendation.urgencyColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _dismissRecommendation(context, recommendation),
                  icon: const Icon(Icons.close),
                  label: const Text('非表示'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalUrgentRecommendations(BuildContext context, List<ConsumptionRecommendation> recommendations) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.warning,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'その他の緊急推奨 (${recommendations.length}件)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...recommendations.map((rec) => _buildCompactRecommendationItem(context, rec)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactRecommendationItem(BuildContext context, ConsumptionRecommendation recommendation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: recommendation.urgencyColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: recommendation.urgencyColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            recommendation.urgencyIcon,
            color: recommendation.urgencyColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recommendation.item?.name ?? '不明な商品',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '残り${recommendation.estimatedDaysRemaining}日',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            recommendation.actionText,
            style: TextStyle(
              color: recommendation.urgencyColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(BuildContext context, String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: color.withOpacity(0.8),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _acknowledgeRecommendation(BuildContext context, ConsumptionRecommendation recommendation) {
    final provider = Provider.of<RecommendationsProvider>(context, listen: false);
    provider.acknowledgeRecommendation(recommendation.id);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${recommendation.item?.name ?? "商品"}の推奨を確認しました'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _dismissRecommendation(BuildContext context, ConsumptionRecommendation recommendation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('推奨を非表示にする'),
        content: Text('${recommendation.item?.name ?? "この商品"}の推奨を非表示にしますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              final provider = Provider.of<RecommendationsProvider>(context, listen: false);
              provider.deactivateRecommendation(recommendation.id);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${recommendation.item?.name ?? "商品"}の推奨を非表示にしました'),
                ),
              );
            },
            child: const Text('非表示にする'),
          ),
        ],
      ),
    );
  }
}