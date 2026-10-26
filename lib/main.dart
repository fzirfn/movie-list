import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_browser/core/router.dart';
import 'package:movie_browser/core/theme.dart';
import 'package:movie_browser/providers/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env', isOptional: true);
  } catch (_) {
    try {
      await dotenv.load(fileName: '.env.example', isOptional: true);
    } catch (e) {
      debugPrint('Could not load env file: $e');
    }
  }

  runApp(const ProviderScope(child: MovieBrowserApp()));
}

class MovieBrowserApp extends ConsumerWidget {
  const MovieBrowserApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Movie Browser',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}
