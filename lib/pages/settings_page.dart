import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, this.onThemeChanged, this.isDarkMode = false});

  final ValueChanged<bool>? onThemeChanged;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _SettingsSection(
          title: 'Preferences',
          children: [
            SwitchListTile(
              title: const Text('Dark theme'),
              subtitle: const Text('Toggle to rest your eyes during late-night dives.'),
              value: isDarkMode,
              onChanged: onThemeChanged,
              secondary: const Icon(Icons.nightlight_round),
            ),
            SwitchListTile(
              title: const Text('Enable notifications'),
              subtitle: const Text('Get pinged when Della detects new anomalies.'),
              value: true,
              onChanged: (_) {},
              secondary: const Icon(Icons.notifications_active_outlined),
            ),
            SwitchListTile(
              title: const Text('Ocean health digests'),
              subtitle: const Text('Weekly digest of top floats and regions to watch.'),
              value: true,
              onChanged: (_) {},
              secondary: const Icon(Icons.podcasts_outlined),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _SettingsSection(
          title: 'Storage & privacy',
          children: [
            ListTile(
              leading: const Icon(Icons.cleaning_services_outlined),
              title: const Text('Clear cache'),
              subtitle: const Text('Remove downloaded ARGO profiles and previews.'),
              trailing: FilledButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cache cleared. Della thanks you! 🐬')),
                  );
                },
                child: const Text('Clear'),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text('Privacy controls'),
              subtitle: const Text('Manage how shared data contributes to community insights.'),
              onTap: () {},
            ),
          ],
        ),
        const SizedBox(height: 24),
        _SettingsSection(
          title: 'Account',
          children: [
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Profile & identity'),
              subtitle: const Text('Adjust your ocean role, avatar, and affiliations.'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              subtitle: const Text('Surface for air and sign back in later.'),
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...children.map(
          (child) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.35),
                borderRadius: BorderRadius.circular(18),
              ),
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}
