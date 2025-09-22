import 'dart:async';
import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../widgets/profile_selector.dart';

class ChatMessage {
  ChatMessage({
    required this.text,
    required this.isUser,
    this.insight,
  });

  final String text;
  final bool isUser;
  final ChatInsightData? insight;
}

class ChatInsightData {
  ChatInsightData({
    required this.temperatureProfile,
    required this.salinityProfile,
    required this.oxygenSeries,
  });

  final List<FlSpot> temperatureProfile;
  final List<FlSpot> salinityProfile;
  final List<FlSpot> oxygenSeries;
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, this.profileNotifier});

  final ValueNotifier<ProfileMode>? profileNotifier;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [
    ChatMessage(
      text:
          '🐬 Hello! I\'m Della the FloatChat dolphin. Ask me about any ARGO float and I\'ll surface insights with maps, graphs, and context.',
      isUser: false,
    ),
  ];
  bool _isGenerating = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final trimmed = _controller.text.trim();
    if (trimmed.isEmpty || _isGenerating) return;

    setState(() {
      _messages.add(ChatMessage(text: trimmed, isUser: true));
      _isGenerating = true;
      _controller.clear();
    });

    _scrollToBottom();

    final profile = widget.profileNotifier?.value ?? ProfileMode.general;
    Timer(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      final insight = _buildInsightData(profile, trimmed);
      setState(() {
        _messages.add(ChatMessage(
          isUser: false,
          text: _mockResponse(profile, trimmed),
          insight: insight,
        ));
        _isGenerating = false;
      });
      _scrollToBottom();
    });
  }

  String _mockResponse(ProfileMode profile, String query) {
    final baseIntro = switch (profile) {
      ProfileMode.agency =>
          'For policy review: wave height anomalies near Bay of Bengal show +1.2m versus baseline.',
      ProfileMode.researcher =>
          'Research brief: Float 290313 analyzed. Thermocline dipped 35m post-monsoon burst.',
      ProfileMode.educator =>
          'Classroom snapshot: notice how warm surface water layers mix during summer monsoon.',
      ProfileMode.general =>
          'Ocean insight: surface temps are trending warmer around the Indian peninsula.',
    };

    return '$baseIntro\n\nBased on your prompt "$query", I\'ve staged depth vs temperature and salinity charts plus an oxygen anomaly timeline below. Tap the Analysis tab to compare floats, overlay cyclonic events, or export NetCDF snapshots. 🐬';
  }

  ChatInsightData _buildInsightData(ProfileMode profile, String query) {
    final hash = query.hashCode.abs();
    final double tempOffset = ((hash % 7) - 3) * 0.12;
    final double salinityOffset = (((hash >> 3) % 5) - 2) * 0.05;
    final double oxygenOffset = (((hash >> 6) % 5) - 2) * 0.07;
    final double profileAdjustment = profile.index * 0.15;

    final temperatureProfile = List<FlSpot>.generate(7, (index) {
      final depth = index * 320.0;
      final base = 29.2 - index * 0.95 - profileAdjustment;
      return FlSpot(depth, base - tempOffset);
    });

    final salinityProfile = List<FlSpot>.generate(7, (index) {
      final depth = index * 320.0;
      final base = 35.1 - index * 0.14 + salinityOffset;
      return FlSpot(depth, base);
    });

    final oxygenSeries = List<FlSpot>.generate(8, (index) {
      final day = index.toDouble();
      final base = 5.3 + math.sin((index / 7) * math.pi) * 0.35;
      return FlSpot(day, base + oxygenOffset);
    });

    return ChatInsightData(
      temperatureProfile: temperatureProfile,
      salinityProfile: salinityProfile,
      oxygenSeries: oxygenSeries,
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.all(20),
            itemCount: _messages.length + (_isGenerating ? 1 : 0),
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (_isGenerating && index == _messages.length) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        ),
                        SizedBox(width: 12),
                        Text('Della is crafting insights...'),
                      ],
                    ),
                  ),
                );
              }

              final message = _messages[index];
              final alignment =
                  message.isUser ? Alignment.centerRight : Alignment.centerLeft;
              final bubbleColor = message.isUser
                  ? theme.colorScheme.primaryContainer
                  : theme.colorScheme.surfaceVariant.withOpacity(0.6);
              final textColor = message.isUser
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onSurfaceVariant;
              final bubbleMaxWidth =
                  MediaQuery.of(context).size.width * (message.isUser ? 0.7 : 0.9);
              final insight = message.insight;
              return Align(
                alignment: alignment,
                child: Container(
                  constraints: BoxConstraints(maxWidth: bubbleMaxWidth),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: message.isUser
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.text,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: textColor),
                      ),
                      if (!message.isUser && insight != null) ...[
                        const SizedBox(height: 12),
                        _buildInsightCharts(insight, theme),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        SafeArea(
          top: false,
          minimum: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: _buildInputBar(context),
        ),
      ],
    );
  }

  Widget _buildInputBar(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Upload files for analysis',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                showDragHandle: true,
                builder: (context) {
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Upload Data',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Attach NetCDF, CSV, or imagery files to enrich the upcoming analysis. The preview and parsing will appear in chat. 🐬',
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Ask Della to explore ARGO floats, trends, or anomalies...',
                border: InputBorder.none,
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 4),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton.tonal(
              onPressed: _isGenerating ? null : _sendMessage,
              style: FilledButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(18),
              ),
              child: const Icon(Icons.send_rounded),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCharts(ChatInsightData insight, ThemeData theme) {
    final scheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDepthProfileChart(
          title: 'Temperature vs depth',
          spots: insight.temperatureProfile,
          color: Colors.orangeAccent,
          unitSuffix: '°C',
          theme: theme,
        ),
        const SizedBox(height: 14),
        _buildDepthProfileChart(
          title: 'Salinity vs depth',
          spots: insight.salinityProfile,
          color: scheme.primary,
          unitSuffix: 'PSU',
          theme: theme,
        ),
        const SizedBox(height: 14),
        Text(
          'Oxygen trend (7 days)',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 170,
          child: LineChart(_oxygenSeriesData(insight.oxygenSeries, theme)),
        ),
      ],
    );
  }

  Widget _buildDepthProfileChart({
    required String title,
    required List<FlSpot> spots,
    required Color color,
    required String unitSuffix,
    required ThemeData theme,
  }) {
    final minY = spots.map((e) => e.y).reduce(math.min) - 0.4;
    final maxY = spots.map((e) => e.y).reduce(math.max) + 0.4;
    final interval = _axisInterval(minY, maxY);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 180,
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: 2000,
              minY: minY,
              maxY: maxY,
              lineTouchData: const LineTouchData(enabled: false),
              gridData: FlGridData(
                show: true,
                horizontalInterval: interval,
                verticalInterval: 500,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: theme.colorScheme.outlineVariant.withOpacity(0.25),
                  strokeWidth: 1,
                ),
                getDrawingVerticalLine: (value) => FlLine(
                  color: theme.colorScheme.outlineVariant.withOpacity(0.25),
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  axisNameWidget: const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text('Depth (m)', style: TextStyle(fontSize: 11)),
                  ),
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 500,
                    reservedSize: 44,
                    getTitlesWidget: (value, meta) {
                      if (value % 500 != 0) return const SizedBox.shrink();
                      return Text('${value.toInt()}',
                          style: const TextStyle(fontSize: 10));
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  axisNameWidget: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Text(unitSuffix,
                        style: const TextStyle(fontSize: 11)),
                  ),
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: interval,
                    reservedSize: 46,
                    getTitlesWidget: (value, meta) => Text(
                      value.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withOpacity(0.4),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  color: color,
                  barWidth: 3,
                  isCurved: true,
                  dotData: const FlDotData(show: false),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  LineChartData _oxygenSeriesData(List<FlSpot> spots, ThemeData theme) {
    final minY = spots.map((e) => e.y).reduce(math.min) - 0.2;
    final maxY = spots.map((e) => e.y).reduce(math.max) + 0.2;
    final maxX = spots.map((e) => e.x).reduce(math.max);
    final interval = _axisInterval(minY, maxY);

    return LineChartData(
      minX: 0,
      maxX: maxX,
      minY: minY,
      maxY: maxY,
      lineTouchData: const LineTouchData(enabled: false),
      gridData: FlGridData(
        show: true,
        horizontalInterval: interval,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) => FlLine(
          color: theme.colorScheme.outlineVariant.withOpacity(0.25),
          strokeWidth: 1,
        ),
        getDrawingVerticalLine: (value) => FlLine(
          color: theme.colorScheme.outlineVariant.withOpacity(0.2),
          strokeWidth: 1,
        ),
      ),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          axisNameWidget: const Padding(
            padding: EdgeInsets.only(right: 6),
            child: Text('ml/l', style: TextStyle(fontSize: 11)),
          ),
          sideTitles: SideTitles(
            showTitles: true,
            interval: interval,
            reservedSize: 42,
            getTitlesWidget: (value, meta) => Text(
              value.toStringAsFixed(2),
              style: const TextStyle(fontSize: 10),
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          axisNameWidget: const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text('Day', style: TextStyle(fontSize: 11)),
          ),
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: (value, meta) => Text(
              'D${value.toInt() + 1}',
              style: const TextStyle(fontSize: 10),
            ),
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.4),
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          color: theme.colorScheme.primary,
          barWidth: 3,
          isCurved: true,
          dotData: const FlDotData(show: true),
        ),
      ],
    );
  }

  double _axisInterval(double min, double max) {
    final range = max - min;
    if (range <= 0) {
      return 1;
    }
    final interval = range / 4;
    return (interval.clamp(0.2, 3.0)) as double;
  }
}
