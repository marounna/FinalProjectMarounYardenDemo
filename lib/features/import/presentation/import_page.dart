import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../data/models/imported_item.dart';
import '../../../shared/providers.dart';
import '../application/import_controller.dart';

class ImportPage extends ConsumerWidget {
  final String source; // 'file' or 'camera'
  const ImportPage({super.key, this.source = 'file'});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(pagesProvider);
    final controller = ref.watch(importControllerProvider);

    return AppScaffold(
      title: source == 'camera' ? 'Scan with Camera' : 'Import File',
      actions: [
        IconButton(
          onPressed: () async {
            if (source == 'camera') {
              await controller.captureFromCamera();
            } else {
              await controller.pickFromFile();
            }
          },
          icon: Icon(source == 'camera' ? Icons.photo_camera_outlined : Icons.upload_file_outlined),
        ),
        IconButton(
          tooltip: 'Add mock',
          onPressed: controller.addMock,
          icon: const Icon(Icons.add),
        ),
      ],
      body: items.isEmpty
          ? const _EmptyState()
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3 / 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: items.length,
              itemBuilder: (context, i) => _ImportTile(item: items[i]),
            ),
      bottom: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: FilledButton.icon(
          onPressed: () => context.go('/annotate'),
          icon: const Icon(Icons.arrow_forward),
          label: const Text('Next'),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.insert_drive_file_outlined, size: 72),
          const SizedBox(height: 12),
          Text('No pages yet', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          const Text('Use the top-right action to add pages.'),
        ],
      ),
    );
  }
}

class _ImportTile extends StatelessWidget {
  final ImportedItem item;
  const _ImportTile({required this.item});
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 1,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                  ),
                  child: const Icon(Icons.image_outlined, size: 56),
                ),
              ),
              const SizedBox(height: 8),
              Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}
