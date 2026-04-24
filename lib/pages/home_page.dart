import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card.filled(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Welcome to TechPie',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your academic dashboard at a glance.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card.outlined(
            child: ListTile(
              leading: Icon(
                Icons.calendar_today,
                color: theme.colorScheme.primary,
              ),
              title: const Text('Upcoming classes'),
              subtitle: const Text('No classes today'),
              trailing: const Icon(Icons.chevron_right),
            ),
          ),
          const SizedBox(height: 8),
          Card.outlined(
            child: ListTile(
              leading: Icon(
                Icons.assignment_outlined,
                color: theme.colorScheme.tertiary,
              ),
              title: const Text('Pending assignments'),
              subtitle: const Text('All caught up!'),
              trailing: const Icon(Icons.chevron_right),
            ),
          ),
        ],
      ),
    );
  }
}
