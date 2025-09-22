import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../widgets/profile_selector.dart';

class FloatMarkerData {
  const FloatMarkerData({
    required this.id,
    required this.position,
    required this.latestTemperature,
    required this.depthHighlight,
    required this.salinity,
    required this.oxygen,
  });

  final String id;
  final LatLng position;
  final double latestTemperature;
  final double depthHighlight;
  final double salinity;
  final double oxygen;
}

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key, this.profileNotifier});

  final ValueNotifier<ProfileMode>? profileNotifier;

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  final MapController _mapController = MapController();

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
                            Text('Last profile: ${data.latestTemperature.toStringAsFixed(1)}°C at ${data.depthHighlight.toStringAsFixed(0)} m'),
                          ],
                        ),
                      ),
                    ],
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
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.floatchat',
            ),
            MarkerLayer(
              markers: _markers
                  .map(
                    (marker) => Marker(
                      point: marker.position,
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
        Positioned(
          left: 16,
          bottom: 16,
          right: 16,
          child: _RealtimeInsightPanel(markers: _markers),
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
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Text('🐬', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tone,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}

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
