# Movie Browser: Flutter Mini Project Spec

## 1. Goal
Build a simple, polished Flutter mobile app that browses movies using the TMDB API. This is a portfolio project that will be published on GitHub, so code quality, clean structure, and a good README matter as much as features. Keep scope tight: build exactly what is listed here and nothing more.

## 2. Tech Stack (use exactly these)
| Purpose | Package |
|---|---|
| State management | `flutter_riverpod` |
| HTTP client | `dio` |
| Navigation | `go_router` |
| Image caching | `cached_network_image` |
| Local storage (favorites) | `shared_preferences` (store favorites as a JSON list) |
| Env / API key | `flutter_dotenv` |

- Flutter stable channel, Dart null safety, Material 3.
- Targets: Android and iOS. Must run on Android at minimum.
- Do not add other packages without a clear reason. No code generation (no freezed, no json_serializable); write models by hand with `fromJson` / `toJson`.

## 3. API: TMDB (https://developer.themoviedb.org)
- Base URL: `https://api.themoviedb.org/3`
- Image base URL: `https://image.tmdb.org/t/p/` with sizes `w500` (posters) and `w780` (backdrops)
- Auth: v3 API key sent as the `api_key` query parameter, read from `.env` as `TMDB_API_KEY`

Endpoints to use:
- `GET /trending/movie/week`
- `GET /movie/popular`
- `GET /movie/top_rated`
- `GET /search/movie?query={text}`
- `GET /movie/{id}?append_to_response=credits` (returns details, genres, and cast in one call)

All list endpoints support `page`. Implement infinite scroll pagination on the home lists.

## 4. Features (MVP)
1. **Home screen**: three tabs: Trending, Popular, Top Rated. Each shows a poster grid (2 columns) with infinite scroll pagination and pull-to-refresh.
2. **Search**: search bar with 500 ms debounce, results in the same grid style, empty state when there are no results, and a hint state before typing.
3. **Movie detail screen**: backdrop and poster, title, release year, runtime, rating (out of 10), genres as chips, overview, horizontally scrolling cast list (photo, name, character; top 10), and a favorite toggle button.
4. **Favorites screen**: grid of saved movies, persisted locally, removable, with an empty state. Tapping opens the detail screen.
5. **Theme**: light and dark mode with a toggle, and the choice persisted locally.
6. **State handling on every screen**: loading (shimmer or progress indicator), error (message plus Retry button), and empty.

## 5. Navigation
Bottom navigation bar with three destinations: **Home**, **Search**, **Favorites**. The detail screen is pushed on top via `go_router` at `/movie/:id`.

## 6. Architecture
Simple layered structure, no over-engineering:

```
lib/
├── core/
│   ├── constants.dart        # base URLs, image sizes
│   ├── theme.dart            # light and dark ThemeData
│   └── router.dart           # go_router config
├── models/
│   ├── movie.dart            # id, title, posterPath, backdropPath, voteAverage, releaseDate, overview
│   ├── movie_detail.dart     # Movie fields plus runtime, genres, cast
│   └── cast_member.dart      # id, name, character, profilePath
├── services/
│   ├── tmdb_service.dart     # all API calls (Dio)
│   └── storage_service.dart  # favorites and theme persistence
├── providers/
│   ├── movies_provider.dart      # trending, popular, top rated with pagination
│   ├── search_provider.dart
│   ├── detail_provider.dart
│   ├── favorites_provider.dart
│   └── theme_provider.dart
├── screens/
│   ├── home_screen.dart
│   ├── search_screen.dart
│   ├── detail_screen.dart
│   ├── favorites_screen.dart
│   └── shell_screen.dart     # bottom navigation scaffold
├── widgets/
│   ├── movie_card.dart
│   ├── rating_badge.dart
│   ├── cast_tile.dart
│   ├── error_view.dart
│   ├── empty_view.dart
│   └── loading_grid.dart
└── main.dart
```

Rules:
- UI widgets never call Dio directly. They go through providers, and providers go through services.
- Models are immutable (`final` fields).
- Handle API failures (no internet, timeout, 401, 404) in `TmdbService` and surface friendly messages.
- Keep widgets small and reusable. No file over about 250 lines.

## 7. Security
- Never hardcode the API key.
- Commit a `.env.example` containing `TMDB_API_KEY=your_key_here`.
- `.env` must be listed in `.gitignore`.
- Load `.env` in `main()` before `runApp`.

## 8. UI Guidelines
- Material 3 with a single seed color; support light and dark.
- Poster cards use rounded corners, aspect ratio 2:3, and a small rating badge in the corner.
- Use `Hero` animation from poster card to detail screen.
- Placeholder and error images for missing posters.
- Minimum touch target 48 dp, readable text contrast in both themes.

## 9. Build Order
1. Project setup, dependencies, `.env` handling, theme, and folder structure.
2. `TmdbService` and `Movie` model; show Trending grid on Home.
3. Popular and Top Rated tabs with pagination and pull-to-refresh.
4. Detail screen (with `MovieDetail` and cast).
5. Search with debounce.
6. Favorites with local persistence.
7. Dark mode toggle with persistence.
8. Loading, error, and empty states polished across all screens.
9. Basic tests, cleanup, and README.

Complete and verify each step runs before moving to the next.

## 10. Quality Requirements
- `flutter analyze` returns zero issues.
- Code formatted with `dart format`.
- Add a few unit tests: `Movie.fromJson`, `MovieDetail.fromJson`, and the favorites provider (add and remove).
- No unused code, no leftover debug prints, and meaningful commit messages.

## 11. README Requirements
The README must include:
- Project title and one-line description
- Screenshots (placeholders are fine until real ones are taken)
- Features list
- Tech stack
- Setup instructions: clone, get a free TMDB API key, copy `.env.example` to `.env`, run `flutter pub get`, run `flutter run`
- Folder structure overview
- Attribution line: "This product uses the TMDB API but is not endorsed or certified by TMDB."

## 12. Out of Scope (do not build)
User accounts or login, a backend server, watchlists or ratings submitted to TMDB, trailers or video playback, TV shows, localization, push notifications, and anything not listed in section 4.

## 13. Definition of Done
- App runs on an Android emulator or device without errors.
- All five features in section 4 work, including error and empty states.
- `.env` is not tracked by git.
- Analyzer is clean, tests pass, and the README is complete.
