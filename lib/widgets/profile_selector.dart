import 'package:flutter/material.dart';

enum ProfileMode {
  agency,
  researcher,
  educator,
  general,
}

extension ProfileModeX on ProfileMode {
  String get label {
    switch (this) {
      case ProfileMode.agency:
        return 'Agency Mode';
      case ProfileMode.researcher:
        return 'Researcher Mode';
      case ProfileMode.educator:
        return 'Educator Mode';
      case ProfileMode.general:
        return 'General Model';
    }
  }

  String get description {
    switch (this) {
      case ProfileMode.agency:
        return 'Policy-ready intelligence for agencies & policymakers.';
      case ProfileMode.researcher:
        return 'Data-deep dives with scientific context for researchers.';
      case ProfileMode.educator:
        return 'Classroom-friendly explanations for educators & students.';
      case ProfileMode.general:
        return 'Conversational ocean insights for everyone.';
    }
  }

  IconData get icon {
    switch (this) {
      case ProfileMode.agency:
        return Icons.account_balance;
      case ProfileMode.researcher:
        return Icons.science_outlined;
      case ProfileMode.educator:
        return Icons.menu_book_outlined;
      case ProfileMode.general:
        return Icons.emoji_people_outlined;
    }
  }
}

class ProfileSelectorChip extends StatelessWidget {
  const ProfileSelectorChip({
    super.key,
    required this.profileMode,
    required this.onPressed,
  });

  final ProfileMode profileMode;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return ActionChip(
      avatar: Icon(profileMode.icon, size: 20),
      label: Text(profileMode.label),
      onPressed: onPressed,
      shape: StadiumBorder(
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      backgroundColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
=======
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(30),
      child: Ink(
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant.withOpacity(0.45),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: colorScheme.outlineVariant, width: 1.2),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              profileMode.icon,
              size: 20,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              profileMode.label,
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
>>>>>>> 83eb138ec91cfde309804726e6ab5afece7aaffe
    );
  }
}

Future<void> showProfileSelector(
  BuildContext context,
  ValueNotifier<ProfileMode> profileNotifier,
) async {
  final theme = Theme.of(context);
  await showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (context) {
      return ValueListenableBuilder<ProfileMode>(
        valueListenable: profileNotifier,
        builder: (context, selectedMode, _) {
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            itemCount: ProfileMode.values.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final mode = ProfileMode.values[index];
              final isSelected = mode == selectedMode;
              return ListTile(
                leading: CircleAvatar(
                  child: Icon(mode.icon),
                ),
                title: Text(mode.label, style: theme.textTheme.titleMedium),
                subtitle: Text(mode.description),
                trailing: isSelected
                    ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
                    : null,
                onTap: () {
                  profileNotifier.value = mode;
                  Navigator.of(context).pop();
                },
              );
            },
          );
        },
      );
    },
  );
}
