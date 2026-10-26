import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_browser/main.dart';

void main() {
  setUp(() {
    dotenv.loadFromString(envString: 'TMDB_API_KEY=test_api_key_123');
  });

  testWidgets('App smoke test - loads shell and navigation destinations', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: MovieBrowserApp()));
    await tester.pumpAndSettle();

    expect(find.text('Movie Browser'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Favorites'), findsOneWidget);
  });
}
