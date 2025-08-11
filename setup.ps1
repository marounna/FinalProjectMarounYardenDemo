# setup.ps1
$ErrorActionPreference = "Stop"

$root = "lib"
Write-Host "Scaffolding AREA structure under $root ..."

function Ensure-Dir($p) { New-Item -ItemType Directory -Force -Path $p | Out-Null }
function Write-Text($path, $content) {
  $dir = Split-Path $path
  if ($dir) { Ensure-Dir $dir }
  Set-Content -Path $path -Value $content -Encoding UTF8
}

# --- Directories ---
Ensure-Dir "$root/core/router"
Ensure-Dir "$root/core/theme"
Ensure-Dir "$root/core/widgets"
Ensure-Dir "$root/core/services"
Ensure-Dir "$root/data/models"
Ensure-Dir "$root/data/repositories"
Ensure-Dir "$root/features/home/presentation"
Ensure-Dir "$root/features/import/application"
Ensure-Dir "$root/features/import/presentation"
Ensure-Dir "$root/features/annotate/application"
Ensure-Dir "$root/features/annotate/presentation"
Ensure-Dir "$root/shared"

# --- Files ---

Write-Text "$root/main.dart" @'
import 'package:flutter/material.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AreaApp());
}
'@

Write-Text "$root/app.dart" @'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class AreaApp extends ConsumerWidget {
  const AreaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'AREA — AR Easy Assembly',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
'@

Write-Text "$root/core/router/app_router.dart" @'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/import/presentation/import_page.dart';
import '../../features/annotate/presentation/annotate_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', name: 'home', builder: (c, s) => const HomePage()),
      GoRoute(
        path: '/import',
        name: 'import',
        builder: (c, s) =>
            ImportPage(source: s.uri.queryParameters['source'] ?? 'file'),
      ),
      GoRoute(path: '/annotate', name: 'annotate', builder: (c, s) => const AnnotatePage()),
    ],
  );
});
'@

Write-Text "$root/core/theme/app_theme.dart" @'
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3B82F6)),
        useMaterial3: true,
      );

  static ThemeData get dark => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3B82F6),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      );
}
'@

Write-Text "$root/core/widgets/app_scaffold.dart" @'
import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? bottom;
  const AppScaffold({super.key, required this.title, required this.body, this.actions, this.bottom});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      body: body,
      bottomNavigationBar: bottom == null ? null : SafeArea(child: bottom!),
    );
  }
}
'@

Write-Text "$root/core/services/file_picker_service.dart" @'
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class FilePickerService {
  Future<List<PickedPage>> pickFile();
}

class PickedPage {
  final String name;
  final Uint8List bytes;
  const PickedPage(this.name, this.bytes);
}

final filePickerServiceProvider = Provider<FilePickerService>((ref) => _StubFilePicker());

class _StubFilePicker implements FilePickerService {
  @override
  Future<List<PickedPage>> pickFile() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return [];
  }
}
'@

Write-Text "$root/core/services/camera_service.dart" @'
import 'dart:Uint8List';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class CameraService {
  Future<List<CameraCapture>> capturePages();
}

class CameraCapture {
  final String name;
  final Uint8List bytes;
  const CameraCapture(this.name, this.bytes);
}

final cameraServiceProvider = Provider<CameraService>((ref) => _StubCamera());

class _StubCamera implements CameraService {
  @override
  Future<List<CameraCapture>> capturePages() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return [];
  }
}
'@.Replace("dart:Uint8List", "dart:typed_data") # fix casing

Write-Text "$root/data/models/imported_item.dart" @'
import 'dart:typed_data';

class ImportedItem {
  final String name;
  final Uint8List? bytes;
  const ImportedItem({required this.name, this.bytes});
}
'@

Write-Text "$root/data/repositories/session_repository.dart" @'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/imported_item.dart';

abstract class SessionRepository {
  List<ImportedItem> get pages;
  void setPages(List<ImportedItem> pages);
}

final sessionRepositoryProvider = Provider<SessionRepository>((ref) => _MemorySessionRepo());

class _MemorySessionRepo implements SessionRepository {
  List<ImportedItem> _pages = const [];
  @override
  List<ImportedItem> get pages => _pages;

  @override
  void setPages(List<ImportedItem> pages) => _pages = pages;
}
'@

Write-Text "$root/shared/providers.dart" @'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/imported_item.dart';
import '../data/repositories/session_repository.dart';

final pagesProvider = StateNotifierProvider<PagesController, List<ImportedItem>>((ref) {
  final repo = ref.watch(sessionRepositoryProvider);
  return PagesController(repo.pages, onChange: repo.setPages);
});

class PagesController extends StateNotifier<List<ImportedItem>> {
  final void Function(List<ImportedItem>) onChange;
  PagesController(super.state, {required this.onChange});

  void setAll(List<ImportedItem> pages) { state = pages; onChange(state); }
  void add(ImportedItem item) { state = [...state, item]; onChange(state); }
  void clear() { state = []; onChange(state); }
}
'@

Write-Text "$root/features/home/presentation/home_page.dart" @'
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
'@

Write-Text "$root/features/import/application/import_controller.dart" @'
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/camera_service.dart';
import '../../../core/services/file_picker_service.dart';
import '../../../data/models/imported_item.dart';
import '../../../shared/providers.dart';

final importControllerProvider = Provider<ImportController>((ref) {
  return ImportController(
    ref: ref,
    picker: ref.watch(filePickerServiceProvider),
    camera: ref.watch(cameraServiceProvider),
  );
});

class ImportController {
  final Ref ref;
  final FilePickerService picker;
  final CameraService camera;
  ImportController({required this.ref, required this.picker, required this.camera});

  Future<void> pickFromFile() async {
    final pages = await picker.pickFile();
    ref.read(pagesProvider.notifier).setAll(
      [for (final p in pages) ImportedItem(name: p.name, bytes: p.bytes)],
    );
  }

  Future<void> captureFromCamera() async {
    final shots = await camera.capturePages();
    ref.read(pagesProvider.notifier).setAll(
      [for (final s in shots) ImportedItem(name: s.name, bytes: s.bytes)],
    );
  }

  void addMock() {
    final demo = Uint8List(0);
    ref.read(pagesProvider.notifier).add(
      ImportedItem(name: 'Page ${DateTime.now().millisecondsSinceEpoch}.png', bytes: demo),
    );
  }
}
'@

Write-Text "$root/features/import/presentation/import_page.dart" @'
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
'@

Write-Text "$root/features/annotate/application/annotate_controller.dart" @'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final annotateControllerProvider = StateNotifierProvider<AnnotateController, List<Rect>>((ref) {
  return AnnotateController();
});

class AnnotateController extends StateNotifier<List<Rect>> {
  AnnotateController() : super(const []);
  Rect? active;

  void start(Offset p) { active = Rect.fromLTWH(p.dx, p.dy, 0, 0); }
  void update(Offset p) {
    if (active == null) return;
    final start = Offset(active!.left, active!.top);
    active = Rect.fromPoints(start, p);
    state = [...state];
  }
  void end() {
    if (active == null) return;
    final r = _normalize(active!);
    state = [...state, r];
    active = null;
  }
  void undo() { if (state.isNotEmpty) { state = [...state]..removeLast(); } }
  void clear() { state = const []; active = null; }

  Rect _normalize(Rect r) {
    final left = r.left < r.right ? r.left : r.right;
    final top = r.top < r.bottom ? r.top : r.bottom;
    final right = r.left < r.right ? r.right : r.left;
    final bottom = r.top < r.bottom ? r.bottom : r.top;
    return Rect.fromLTRB(left, top, right, bottom);
  }
}
'@

Write-Text "$root/features/annotate/presentation/annotate_page.dart" @'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../application/annotate_controller.dart';

class AnnotatePage extends ConsumerWidget {
  const AnnotatePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rects = ref.watch(annotateControllerProvider);
    final ctrl = ref.read(annotateControllerProvider.notifier);

    return AppScaffold(
      title: 'Annotate',
      actions: [
        IconButton(onPressed: ctrl.undo, icon: const Icon(Icons.undo)),
        IconButton(onPressed: ctrl.clear, icon: const Icon(Icons.delete_sweep_outlined)),
      ],
      body: LayoutBuilder(
        builder: (context, c) {
          final size = Size(c.maxWidth, c.maxHeight);
          return GestureDetector(
            onPanStart: (d) => ctrl.start(d.localPosition),
            onPanUpdate: (d) => ctrl.update(d.localPosition),
            onPanEnd: (_) => ctrl.end(),
            child: CustomPaint(
              size: size,
              painter: _AnnotPainter(rects: rects, active: ctrl.active),
              child: Container(color: Colors.black12),
            ),
          );
        },
      ),
      bottom: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: FilledButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Submit ${rects.length} annotations (wire later)')),
            );
          },
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('Submit'),
        ),
      ),
    );
  }
}

class _AnnotPainter extends CustomPainter {
  final List<Rect> rects;
  final Rect? active;
  _AnnotPainter({required this.rects, required this.active});

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2;
    for (final r in rects) {
      canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(6)), stroke);
    }
    if (active != null) {
      final dashed = Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2;
      _drawDashedRect(canvas, active!, dashed);
    }
  }

  void _drawDashedRect(Canvas canvas, Rect rect, Paint paint) {
    const dash = 8.0; const gap = 6.0;
    double x = rect.left;
    while (x < rect.right) { final nx = (x + dash).clamp(rect.left, rect.right);
      canvas.drawLine(Offset(x, rect.top), Offset(nx, rect.top), paint); x += dash + gap; }
    x = rect.left;
    while (x < rect.right) { final nx = (x + dash).clamp(rect.left, rect.right);
      canvas.drawLine(Offset(x, rect.bottom), Offset(nx, rect.bottom), paint); x += dash + gap; }
    double y = rect.top;
    while (y < rect.bottom) { final ny = (y + dash).clamp(rect.top, rect.bottom);
      canvas.drawLine(Offset(rect.left, y), Offset(rect.left, ny), paint); y += dash + gap; }
    y = rect.top;
    while (y < rect.bottom) { final ny = (y + dash).clamp(rect.top, rect.bottom);
      canvas.drawLine(Offset(rect.right, y), Offset(rect.right, ny), paint); y += dash + gap; }
  }

  @override
  bool shouldRepaint(covariant _AnnotPainter old) => old.rects != rects || old.active != active;
}
'@

Write-Host "Done. Run the VS Code task: Terminal → Run Task → 'Setup AREA Scaffold'"
