import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../widgets/profile_selector.dart';

enum FloatStatus { stable, watch, alert }

extension FloatStatusX on FloatStatus {
  String get label {
    switch (this) {
      case FloatStatus.stable:
        return 'Stable';
      case FloatStatus.watch:
        return 'Watch';
      case FloatStatus.alert:
        return 'Alert';
    }
  }

  Color get color {
    switch (this) {
      case FloatStatus.stable:
        return const Color(0xFF1ABC9C);
      case FloatStatus.watch:
        return const Color(0xFFF39C12);
      case FloatStatus.alert:
        return const Color(0xFFE74C3C);
    }
  }

  IconData get icon {
    switch (this) {
      case FloatStatus.stable:
        return Icons.check_circle_outline;
      case FloatStatus.watch:
        return Icons.warning_amber_rounded;
      case FloatStatus.alert:
        return Icons.priority_high_rounded;
    }
  }
}

class FloatMarkerData {
  const FloatMarkerData({
    required this.id,
    required this.position,
    required this.latestTemperature,
    required this.depthHighlight,
    required this.salinity,
    required this.oxygen,
    required this.status,
    required this.temperatureProfile,
    required this.salinityProfile,
    required this.oxygenSeries,
    required this.lastUpdated,
  });

  final String id;
  final LatLng position;
  final double latestTemperature;
  final double depthHighlight;
  final double salinity;
  final double oxygen;
  final FloatStatus status;
  final List<FlSpot> temperatureProfile;
  final List<FlSpot> salinityProfile;
  final List<FlSpot> oxygenSeries;
  final DateTime lastUpdated;
}

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key, this.profileNotifier});

  final ValueNotifier<ProfileMode>? profileNotifier;

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  final MapController _mapController = MapController();
  late final List<FloatMarkerData> _markers = _buildMarkers();
  FloatMarkerData? _selectedMarker;

  List<FloatMarkerData> _buildMarkers() {
    final seeds = <LatLng>[
      const LatLng(8.7, 76.7),
      const LatLng(9.9, 76.2),
      const LatLng(10.8, 79.0),
      const LatLng(12.9, 74.8),
      const LatLng(13.1, 80.3),
      const LatLng(14.7, 74.0),
      const LatLng(15.5, 73.8),
      const LatLng(16.8, 82.2),
      const LatLng(17.7, 83.4),
      const LatLng(18.6, 72.9),
      const LatLng(19.9, 72.8),
      const LatLng(20.5, 86.7),
      const LatLng(21.3, 88.1),
      const LatLng(13.7, 92.7),
      const LatLng(15.1, 92.9),
      const LatLng(11.6, 94.3),
      const LatLng(6.4, 93.8),
      const LatLng(5.9, 80.5),
      const LatLng(7.1, 77.4),
      const LatLng(22.5, 68.7),
    ];

    final random = math.Random(2024);
    final markers = <FloatMarkerData>[];
    for (var i = 0; i < 50; i++) {
      final seed = seeds[i % seeds.length];
      final latJitter = (random.nextDouble() - 0.5) * 1.2;
      final lngJitter = (random.nextDouble() - 0.5) * 1.2;
      final status = FloatStatus.values[i % FloatStatus.values.length];
      final baseTemperature = 26.5 + random.nextDouble() * 4.5;
      final depth = 80 + random.nextDouble() * 220;
      final salinity = 34.2 + random.nextDouble() * 1.4;
      final oxygen = 4.6 + random.nextDouble() * 2.0;
      final hoursAgo = 1 + random.nextInt(36);

      markers.add(
        _createMarker(
          id: 'IN-${9100 + i}',
          position: LatLng(
            seed.latitude + latJitter,
            seed.longitude + lngJitter,
          ),
          temperature: baseTemperature,
          depth: depth,
          salinity: salinity,
          oxygen: oxygen,
          status: status,
          hoursAgo: hoursAgo,
        ),
      );
    }

    return markers;
  }

  FloatMarkerData _createMarker({
    required String id,
    required LatLng position,
    required double temperature,
    required double depth,
    required double salinity,
    required double oxygen,
    required FloatStatus status,
    required int hoursAgo,
  }) {
    final profileVariation = (id.hashCode % 5) * 0.08;
    final depthSeries = List<FlSpot>.generate(7, (index) {
      final level = index * 320.0;
      final base = temperature - index * 0.95;
      final adjustment = status == FloatStatus.alert
          ? 0.6
          : status == FloatStatus.watch
              ? 0.3
              : 0.1;
      return FlSpot(level, base - adjustment - profileVariation);
    });

    final salinitySeries = List<FlSpot>.generate(7, (index) {
      final level = index * 320.0;
      final base = salinity - index * 0.12;
      final adjust = status == FloatStatus.alert
          ? -0.25
          : status == FloatStatus.watch
              ? -0.1
              : 0.05;
      return FlSpot(level, base + adjust);
    });

    final oxygenSeries = List<FlSpot>.generate(8, (index) {
      final day = index.toDouble();
      final base = oxygen - math.sin(index / 6 * math.pi) * 0.25;
      final adjust = status == FloatStatus.alert
          ? -0.3
          : status == FloatStatus.watch
              ? -0.1
              : 0.0;
      return FlSpot(day, base + adjust);
    });

    return FloatMarkerData(
      id: id,
      position: position,
      latestTemperature: temperature,
      depthHighlight: depth,
      salinity: salinity,
      oxygen: oxygen,
      status: status,
      temperatureProfile: depthSeries,
      salinityProfile: salinitySeries,
      oxygenSeries: oxygenSeries,
      lastUpdated: DateTime.now().subtract(Duration(hours: hoursAgo)),
    );
  }

  String _timeAgo(DateTime timestamp) {
    final difference = DateTime.now().difference(timestamp);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours} h ago';
    }
    return '${difference.inDays} d ago';
  }

  void _openFloatDetails(FloatMarkerData data) {
    final profileMode = widget.profileNotifier?.value ?? ProfileMode.general;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (context, controller) {
            return SingleChildScrollView(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        child: const Text('🐬', style: TextStyle(fontSize: 28)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Float ${data.id}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Last profile: ${data.latestTemperature.toStringAsFixed(1)}°C at ${data.depthHighlight.toStringAsFixed(0)} m',
                            ),
                          ],
                        ),
                      ),
                      Chip(
                        avatar: Icon(data.status.icon, color: Colors.white, size: 18),
                        label: Text(data.status.label,
                            style: const TextStyle(color: Colors.white)),
                        backgroundColor: data.status.color,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Updated ${_timeAgo(data.lastUpdated)} • ${profileMode.label}',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Theme.of(context).colorScheme.outline),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _MetricCard(
                        title: 'Temperature',
                        value: '${data.latestTemperature.toStringAsFixed(1)} °C',
                        subtitle: 'Surface anomaly +0.8°C',
                        icon: Icons.thermostat,
                      ),
                      _MetricCard(
                        title: 'Salinity',
                        value: '${data.salinity.toStringAsFixed(1)} PSU',
                        subtitle: 'Halocline shift 12 m',
                        icon: Icons.water_drop_outlined,
                      ),
                      _MetricCard(
                        title: 'Oxygen',
                        value: '${data.oxygen.toStringAsFixed(1)} ml/l',
                        subtitle: 'Hypoxia risk low',
                        icon: Icons.bubble_chart_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _InsightBanner(profileMode: profileMode, data: data),
                  const SizedBox(height: 24),
                  _ProfileChartsSection(data: data),
                  const SizedBox(height: 24),
                  _DownloadRow(floatId: data.id),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: const LatLng(15.0, 78.0),
            initialZoom: 4.8,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
            onTap: (_, __) {
              setState(() => _selectedMarker = null);
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              tileProvider: const NetworkTileProvider(),
              maxZoom: 18,
              userAgentPackageName: 'com.floatchat.app',
            ),
            MarkerLayer(
              markers: _markers
                  .map(
                    (marker) => Marker(
                      point: marker.position,
                      width: 90,
                      height: 90,
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _selectedMarker = marker);
                          _mapController.move(marker.position, 6.5);
                        },
                        child: _MapMarker(status: marker.status, label: marker.id),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
        Positioned(
          right: 16,
          top: 16,
          child: ElevatedButton.icon(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                showDragHandle: true,
                builder: (_) => Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Export queued',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'A CSV export with the latest temperature, salinity, and oxygen profiles will be available in your downloads shortly. 🐬',
                      ),
                    ],
                  ),
                ),
              );
            },
            icon: const Icon(Icons.download_outlined),
            label: const Text('Export CSV'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
          ),
        ),
        if (_selectedMarker != null)
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: _MarkerInsightCard(
              marker: _selectedMarker!,
              onViewDetails: () => _openFloatDetails(_selectedMarker!),
            ),
          ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 170,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(height: 12),
          Text(title, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(subtitle, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _InsightBanner extends StatelessWidget {
  const _InsightBanner({required this.profileMode, required this.data});

  final ProfileMode profileMode;
  final FloatMarkerData data;

  @override
  Widget build(BuildContext context) {
    final statusTone = switch (data.status) {
      FloatStatus.stable =>
          'Stable column with resilient oxygen (${data.oxygen.toStringAsFixed(1)} ml/l) and minimal salinity drift.',
      FloatStatus.watch =>
          'Watchlist: surface warmed to ${data.latestTemperature.toStringAsFixed(1)}°C and halocline lifted ${data.depthHighlight.toStringAsFixed(0)} m.',
      FloatStatus.alert =>
          'Alert: sharp ${data.latestTemperature.toStringAsFixed(1)}°C spike with oxygen dipping near ${data.oxygen.toStringAsFixed(1)} ml/l. Escalate review.',
    };

    final personaTone = switch (profileMode) {
      ProfileMode.agency =>
          'Recommend issuing a policy brief for coastal stakeholders and adjusting EEZ advisories.',
      ProfileMode.researcher =>
          'Queue comparative casts and align with upcoming monsoon campaigns for deeper context.',
      ProfileMode.educator =>
          'Use this float to show students how heat and salinity shift after a storm pulse.',
      ProfileMode.general =>
          'Great moment to follow Della’s insight trail and see the ocean breathe in real-time.',
    };

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🐬', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusTone,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color:
                            Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  personaTone,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                        color:
                            Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileChartsSection extends StatelessWidget {
  const _ProfileChartsSection({required this.data});

  final FloatMarkerData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profiles in dashboard',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _InsightPill(
              icon: Icons.thermostat,
              color: scheme.primary,
              text: 'Surface ${data.latestTemperature.toStringAsFixed(1)}°C',
            ),
            _InsightPill(
              icon: Icons.water_drop_outlined,
              color: scheme.secondary,
              text: 'Salinity ${data.salinity.toStringAsFixed(1)} PSU',
            ),
            _InsightPill(
              icon: Icons.bubble_chart,
              color: scheme.tertiary,
              text: 'Oxygen ${data.oxygen.toStringAsFixed(1)} ml/l',
            ),
          ],
        ),
        const SizedBox(height: 16),
        _ChartCard(
          title: 'Temperature profile',
          subtitle: 'Depth vs °C across latest cast',
          child: LineChart(_depthChartData(
            context,
            spots: data.temperatureProfile,
            color: Colors.orangeAccent,
            unitSuffix: '°C',
          )),
        ),
        const SizedBox(height: 20),
        _ChartCard(
          title: 'Salinity structure',
          subtitle: 'Halocline shift compared to climatology',
          child: LineChart(_depthChartData(
            context,
            spots: data.salinityProfile,
            color: scheme.primary,
            unitSuffix: 'PSU',
          )),
        ),
        const SizedBox(height: 20),
        _ChartCard(
          title: 'Oxygen trend (7 days)',
          subtitle: 'Daily mean ml/l measurements',
          child: LineChart(_oxygenChartData(context, data.oxygenSeries, scheme)),
        ),
      ],
    );
  }

  LineChartData _depthChartData(
    BuildContext context, {
    required List<FlSpot> spots,
    required Color color,
    required String unitSuffix,
  }) {
    final minY = spots.map((e) => e.y).reduce(math.min) - 0.4;
    final maxY = spots.map((e) => e.y).reduce(math.max) + 0.4;
    final interval = _interval(minY, maxY);

    return LineChartData(
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
          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.25),
          strokeWidth: 1,
        ),
        getDrawingVerticalLine: (value) => FlLine(
          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.25),
          strokeWidth: 1,
        ),
      ),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
            child: Text(unitSuffix, style: const TextStyle(fontSize: 11)),
          ),
          sideTitles: SideTitles(
            showTitles: true,
            interval: interval,
            reservedSize: 48,
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
          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.4),
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
    );
  }

  LineChartData _oxygenChartData(
    BuildContext context,
    List<FlSpot> spots,
    ColorScheme scheme,
  ) {
    final minY = spots.map((e) => e.y).reduce(math.min) - 0.2;
    final maxY = spots.map((e) => e.y).reduce(math.max) + 0.2;
    final interval = _interval(minY, maxY);
    final maxX = spots.map((e) => e.x).reduce(math.max);

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
          color: scheme.outlineVariant.withOpacity(0.25),
          strokeWidth: 1,
        ),
        getDrawingVerticalLine: (value) => FlLine(
          color: scheme.outlineVariant.withOpacity(0.2),
          strokeWidth: 1,
        ),
      ),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
        leftTitles: AxisTitles(
          axisNameWidget: const Padding(
            padding: EdgeInsets.only(right: 6),
            child: Text('ml/l', style: TextStyle(fontSize: 11)),
          ),
          sideTitles: SideTitles(
            showTitles: true,
            interval: interval,
            reservedSize: 46,
            getTitlesWidget: (value, meta) => Text(
              value.toStringAsFixed(2),
              style: const TextStyle(fontSize: 10),
            ),
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(
          color: scheme.outlineVariant.withOpacity(0.4),
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          color: scheme.primary,
          barWidth: 3,
          isCurved: true,
          dotData: const FlDotData(show: true),
        ),
      ],
    );
  }

  double _interval(double min, double max) {
    final range = max - min;
    if (range <= 0) {
      return 1;
    }
    final interval = range / 4;
    return (interval.clamp(0.2, 3.0)) as double;
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.45),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          SizedBox(height: 200, child: child),
        ],
      ),
    );
  }
}

class _InsightPill extends StatelessWidget {
  const _InsightPill({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _MapMarker extends StatelessWidget {
  const _MapMarker({required this.status, required this.label});

  final FloatStatus status;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: status.color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(status.icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.65),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _MarkerInsightCard extends StatelessWidget {
  const _MarkerInsightCard({
    required this.marker,
    required this.onViewDetails,
  });

  final FloatMarkerData marker;
  final VoidCallback onViewDetails;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final insights = _insightBullets(marker);
    return Material(
      elevation: 12,
      borderRadius: BorderRadius.circular(24),
      color: scheme.surface.withOpacity(0.95),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: marker.status.color,
                  child: Icon(marker.status.icon, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Float ${marker.id}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Surface ${marker.latestTemperature.toStringAsFixed(1)}°C • O₂ ${marker.oxygen.toStringAsFixed(1)} ml/l',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                FilledButton.tonalIcon(
                  onPressed: onViewDetails,
                  icon: const Icon(Icons.insights),
                  label: const Text('View profile'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 90,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: marker.oxygenSeries.map((e) => e.x).reduce(math.max),
                  minY: marker.oxygenSeries.map((e) => e.y).reduce(math.min) - 0.2,
                  maxY: marker.oxygenSeries.map((e) => e.y).reduce(math.max) + 0.2,
                  lineTouchData: const LineTouchData(enabled: false),
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    topTitles:
                        const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: scheme.outlineVariant.withOpacity(0.4),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: marker.oxygenSeries,
                      color: marker.status.color,
                      barWidth: 3,
                      isCurved: true,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...insights
                .map(
                  (line) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('• ', style: theme.textTheme.bodyMedium),
                        Expanded(
                          child: Text(
                            line,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ],
        ),
      ),
    );
  }

  static List<String> _insightBullets(FloatMarkerData marker) {
    final statusSummary = switch (marker.status) {
      FloatStatus.alert =>
          'Alert status: temperature spike to ${marker.latestTemperature.toStringAsFixed(1)}°C with oxygen at ${marker.oxygen.toStringAsFixed(1)} ml/l.',
      FloatStatus.watch =>
          'Watch status: gradual warming to ${marker.latestTemperature.toStringAsFixed(1)}°C and mixed-layer depth near ${marker.depthHighlight.toStringAsFixed(0)} m.',
      FloatStatus.stable =>
          'Stable regime: balanced column at ${marker.latestTemperature.toStringAsFixed(1)}°C and oxygen ${marker.oxygen.toStringAsFixed(1)} ml/l.',
    };

    return [
      statusSummary,
      'Salinity trend holding around ${marker.salinity.toStringAsFixed(2)} PSU across the upper ${marker.depthHighlight.toStringAsFixed(0)} m.',
      'Last update ${_relativeTime(marker.lastUpdated)}; compare with adjacent floats for mesoscale context.',
      'Tap “View profile” to review the depth-resolved charts and export a CSV snapshot.',
    ];
  }

  static String _relativeTime(DateTime timestamp) {
    final difference = DateTime.now().difference(timestamp);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours} h ago';
    }
    return '${difference.inDays} d ago';
  }
}

class _DownloadRow extends StatelessWidget {
  const _DownloadRow({required this.floatId});

  final String floatId;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.stacked_line_chart),
          label: const Text('Overlay profiles'),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.analytics_outlined),
          label: Text('View anomalies for $floatId'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.download_for_offline_outlined),
          label: const Text('Download NetCDF'),
        ),
      ],
    );
  }
}

