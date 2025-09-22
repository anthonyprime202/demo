<<<<<<< HEAD
=======
import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
>>>>>>> 83eb138ec91cfde309804726e6ab5afece7aaffe
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../widgets/profile_selector.dart';

<<<<<<< HEAD
=======
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

>>>>>>> 83eb138ec91cfde309804726e6ab5afece7aaffe
class FloatMarkerData {
  const FloatMarkerData({
    required this.id,
    required this.position,
    required this.latestTemperature,
    required this.depthHighlight,
    required this.salinity,
    required this.oxygen,
<<<<<<< HEAD
=======
    required this.status,
    required this.temperatureProfile,
    required this.salinityProfile,
    required this.oxygenSeries,
    required this.lastUpdated,
>>>>>>> 83eb138ec91cfde309804726e6ab5afece7aaffe
  });

  final String id;
  final LatLng position;
  final double latestTemperature;
  final double depthHighlight;
  final double salinity;
  final double oxygen;
<<<<<<< HEAD
=======
  final FloatStatus status;
  final List<FlSpot> temperatureProfile;
  final List<FlSpot> salinityProfile;
  final List<FlSpot> oxygenSeries;
  final DateTime lastUpdated;
>>>>>>> 83eb138ec91cfde309804726e6ab5afece7aaffe
}

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key, this.profileNotifier});

  final ValueNotifier<ProfileMode>? profileNotifier;

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  final MapController _mapController = MapController();
<<<<<<< HEAD

  final List<FloatMarkerData> _markers = const [
    FloatMarkerData(
      id: 'IN-9023',
      position: LatLng(15.5, 73.8),
      latestTemperature: 28.4,
      depthHighlight: 120,
      salinity: 34.8,
      oxygen: 5.6,
    ),
    FloatMarkerData(
      id: 'IN-1775',
      position: LatLng(9.9, 76.2),
      latestTemperature: 27.1,
      depthHighlight: 140,
      salinity: 35.2,
      oxygen: 6.1,
    ),
    FloatMarkerData(
      id: 'IN-4410',
      position: LatLng(18.1, 72.9),
      latestTemperature: 29.2,
      depthHighlight: 95,
      salinity: 34.5,
      oxygen: 5.2,
    ),
  ];
=======
  late final List<FloatMarkerData> _markers = _buildMarkers();
  FloatMarkerData? _selectedMarker;

  List<FloatMarkerData> _buildMarkers() {
    return [
      _createMarker(
        id: 'IN-9023',
        position: const LatLng(15.5, 73.8),
        temperature: 28.4,
        depth: 120,
        salinity: 34.8,
        oxygen: 5.6,
        status: FloatStatus.watch,
        hoursAgo: 2,
      ),
      _createMarker(
        id: 'IN-1775',
        position: const LatLng(9.9, 76.2),
        temperature: 27.1,
        depth: 140,
        salinity: 35.2,
        oxygen: 6.1,
        status: FloatStatus.stable,
        hoursAgo: 4,
      ),
      _createMarker(
        id: 'IN-4410',
        position: const LatLng(18.1, 72.9),
        temperature: 29.2,
        depth: 95,
        salinity: 34.5,
        oxygen: 5.2,
        status: FloatStatus.alert,
        hoursAgo: 1,
      ),
    ];
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
>>>>>>> 83eb138ec91cfde309804726e6ab5afece7aaffe

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
<<<<<<< HEAD
                            Text('Last profile: ${data.latestTemperature.toStringAsFixed(1)}°C at ${data.depthHighlight.toStringAsFixed(0)} m'),
                          ],
                        ),
                      ),
                    ],
                  ),
=======
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
>>>>>>> 83eb138ec91cfde309804726e6ab5afece7aaffe
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
<<<<<<< HEAD
                  _InsightBanner(profileMode: profileMode),
                  const SizedBox(height: 24),
                  Text(
                    'Profiles in dashboard',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
=======
                  _InsightBanner(profileMode: profileMode, data: data),
                  const SizedBox(height: 24),
                  _ProfileChartsSection(data: data),
                  const SizedBox(height: 24),
>>>>>>> 83eb138ec91cfde309804726e6ab5afece7aaffe
                  const _ProfilesDescription(),
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
<<<<<<< HEAD
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
=======
            onTap: (_, __) {
              setState(() => _selectedMarker = null);
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c'],
>>>>>>> 83eb138ec91cfde309804726e6ab5afece7aaffe
              userAgentPackageName: 'com.example.floatchat',
            ),
            MarkerLayer(
              markers: _markers
                  .map(
                    (marker) => Marker(
                      point: marker.position,
<<<<<<< HEAD
                      width: 80,
                      height: 80,
                      child: GestureDetector(
                        onTap: () => _openFloatDetails(marker),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.lightBlueAccent.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('🐬', style: TextStyle(fontSize: 20)),
                              Text(
                                marker.id,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
=======
                      width: 90,
                      height: 90,
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _selectedMarker = marker);
                          _openFloatDetails(marker);
                        },
                        child: _MapMarker(status: marker.status, label: marker.id),
>>>>>>> 83eb138ec91cfde309804726e6ab5afece7aaffe
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
<<<<<<< HEAD
        Positioned(
          left: 16,
          bottom: 16,
          right: 16,
          child: _RealtimeInsightPanel(markers: _markers),
        ),
=======
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
>>>>>>> 83eb138ec91cfde309804726e6ab5afece7aaffe
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
<<<<<<< HEAD
  const _InsightBanner({required this.profileMode});

  final ProfileMode profileMode;

  @override
  Widget build(BuildContext context) {
    final tone = switch (profileMode) {
      ProfileMode.agency =>
          'Policy insight: surface warming exceeds treaty targets near EEZ corridors. Della suggests reviewing adaptive shipping advisories.',
      ProfileMode.researcher =>
          'Research insight: salinity drop coincides with freshwater plume on 12 June. Consider overlaying cyclone Biparjoy tracks.',
      ProfileMode.educator =>
          'Teaching tip: compare pre- and post-monsoon profiles to explain thermal layering to students.',
      ProfileMode.general =>
          'Ocean note: it\'s a great time to watch how currents carry warm water along India\'s coasts.',
    };
=======
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

>>>>>>> 83eb138ec91cfde309804726e6ab5afece7aaffe
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
<<<<<<< HEAD
=======
        crossAxisAlignment: CrossAxisAlignment.start,
>>>>>>> 83eb138ec91cfde309804726e6ab5afece7aaffe
        children: [
          const Text('🐬', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
<<<<<<< HEAD
            child: Text(
              tone,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer),
=======
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
>>>>>>> 83eb138ec91cfde309804726e6ab5afece7aaffe
            ),
          ),
        ],
      ),
    );
  }
}

<<<<<<< HEAD
=======
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
            const SizedBox(height: 12),
            Text(
              marker.status == FloatStatus.alert
                  ? 'Della flagged a sharp thermocline compression and oxygen dip. Consider exporting full NetCDF for audit.'
                  : marker.status == FloatStatus.watch
                      ? 'Warm anomaly persists; overlay cyclone tracks or compare with last month to anticipate shifts.'
                      : 'Conditions stable with healthy oxygenation. Perfect baseline for comparison.',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

>>>>>>> 83eb138ec91cfde309804726e6ab5afece7aaffe
class _ProfilesDescription extends StatelessWidget {
  const _ProfilesDescription();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profile Plots',
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        const Text(
          'Y-axis: Depth (0–2000 m). X-axis: Temperature / Salinity / Oxygen etc. Shows how the ocean changes with depth.',
        ),
        const SizedBox(height: 12),
        Text(
          'Time Series of Profiles',
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        const Text(
          'Profiles collected over time → compare January vs June at the same location.',
        ),
        const SizedBox(height: 12),
        Text(
          'Profile Map Integration',
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        const Text(
          'Each float’s location on map → click → see its latest profile. Profiles = the core data product of ARGO.',
        ),
        const SizedBox(height: 12),
        const Text(
          'Use the dashboard to select a float, view the latest profile, overlay multiple profiles (e.g., before & after a cyclone), download in CSV/NetCDF, and spot anomalies like “surface warming > 1°C compared to baseline.”',
        ),
      ],
    );
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

<<<<<<< HEAD
class _RealtimeInsightPanel extends StatelessWidget {
  const _RealtimeInsightPanel({required this.markers});

  final List<FloatMarkerData> markers;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Text('🐬', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Text(
                  'Real-time AI Insights',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...markers.map(
              (marker) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.radar, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Float ${marker.id}: Surface temp ${marker.latestTemperature.toStringAsFixed(1)}°C, anomaly +${(marker.latestTemperature - 27).toStringAsFixed(1)}°C. Oxygen ${marker.oxygen.toStringAsFixed(1)} ml/l.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
=======
>>>>>>> 83eb138ec91cfde309804726e6ab5afece7aaffe
