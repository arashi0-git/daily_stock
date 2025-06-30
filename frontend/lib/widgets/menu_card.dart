import 'package:flutter/material.dart';

// デザインを統一するためのカスタムカードWidget
class MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final VoidCallback onTap;

  const MenuCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor = Colors.deepPurple,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      // InkWellでタップ時のエフェクト(Ripple)を追加
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0), // InkWellの角も丸くする
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // アイコン
              Icon(
                icon,
                size: 40.0,
                color: iconColor,
              ),
              const SizedBox(width: 20), // アイコンとテキストの間の余白
              // テキスト部分を縦に並べる
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // タイトル
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // サブタイトル
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
