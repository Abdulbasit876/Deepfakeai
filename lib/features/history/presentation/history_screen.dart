import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import zaroori hai
import 'package:deepfake_ai/core/constants/app_colors.dart';
import 'package:deepfake_ai/core/theme/text_styles.dart';
import 'package:deepfake_ai/features/status_states/presentation/empty_error_screens.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  late Future<List<Map<String, dynamic>>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    setState(() {
      _historyFuture = Supabase.instance.client
          .from('detection_reports')
          .select('*')
          .eq('user_id', userId ?? '')
          .order('created_at', ascending: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("History", style: AppTextStyles.getHeadingMedium(isDark)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.cardBg(isDark),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(color: AppColors.textPrimary(isDark), fontSize: 14),
                        decoration: InputDecoration(
                          hintText: "Search history...",
                          prefixIcon: Icon(Icons.search_rounded, color: AppColors.textSecondary(isDark).withValues(alpha: 0.6)),
                          filled: true,
                          fillColor: Colors.transparent,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.cardBorder(isDark))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.cardBorder(isDark))),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.neonBlue, width: 1.5)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _loadHistory,
                    child: Container(
                      height: 56, width: 56,
                      decoration: BoxDecoration(color: AppColors.cardBg(isDark), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.cardBorder(isDark))),
                      child: const Icon(Icons.refresh_rounded, color: AppColors.neonBlue, size: 20),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _historyFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return EmptyErrorScreens(stateIndex: 0, onActionTap: _loadHistory);
              }

              final items = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
                itemCount: items.length,
                itemBuilder: (context, index) => _buildHistoryCard(items[index], isDark),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> item, bool isDark) {
    final mediaType = item['media_type']; // 'image', 'video', etc
    final fileName = "Report ${item['created_at'].toString().substring(0, 10)}";
    final aiPercent = (item['ai_percentage'] ?? 0).toInt();
    final realPercent = 100 - aiPercent;
    final imageUrl = item['media_url'] ?? "";

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBg(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder(isDark)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: mediaType == 'audio'
                ? Container(
                    height: 54, width: 54, color: AppColors.neonPink.withValues(alpha: 0.1),
                    child: const Icon(Icons.audiotrack_rounded, color: AppColors.neonPink, size: 22),
                  )
                : Image.network(imageUrl, height: 54, width: 54, fit: BoxFit.cover, errorBuilder: (c, o, s) => Container(height: 54, width: 54, color: AppColors.neonBlue, child: const Icon(Icons.image, color: Colors.white))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fileName, style: TextStyle(color: AppColors.textPrimary(isDark), fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text("$mediaType • ${item['created_at'].toString().substring(0, 10)}", style: AppTextStyles.getBodySmall(isDark)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("$aiPercent% AI", style: const TextStyle(color: AppColors.neonPink, fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text("$realPercent% Real", style: const TextStyle(color: AppColors.successGreen, fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}