import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/app_scaffold.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'AREA',
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.handyman_outlined, size: 96),
                const SizedBox(height: 16),
                Text(
                  'Turn paper manuals into step-by-step AR',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => context.go('/import?source=file'),
                  icon: const Icon(Icons.upload_file_outlined),
                  label: const Text('Upload PDF / Image'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => context.go('/import?source=camera'),
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: const Text('Scan with Camera'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
