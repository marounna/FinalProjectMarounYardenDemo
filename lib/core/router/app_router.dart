import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "../../features/home/presentation/home_page.dart";
import "../../features/import/presentation/import_page.dart";
import "../../features/annotate/presentation/annotate_page.dart";
import "../../features/analysis/presentation/analysis_page.dart";

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: "/",
    routes: [
      GoRoute(path: "/",        name: "home",     builder: (c, s) => const HomePage()),
      GoRoute(path: "/import",  name: "import",   builder: (c, s) => ImportPage(source: s.uri.queryParameters["source"] ?? "file")),
      GoRoute(path: "/annotate",name: "annotate", builder: (c, s) => const AnnotatePage()),
      GoRoute(path: "/analyze", name: "analyze",  builder: (c, s) => const AnalysisPage()),
    ],
  );
});
