# Kuik

Kuik ("KuikMaroc") is a lost & found app for Morocco. People report objects they've lost or found, the app automatically suggests matches between them, and a photo-verified claim flow gates messaging so owners and finders only connect once a claim has been reviewed.

## How it works

1. **Declare an object** — lost or found, with category, description, city, an approximate date, optional photos, and a map position.
2. **Automatic matching** — new listings are scored against existing opposite-type listings (category, distance, date proximity) and suggested to both owners, who confirm or reject.
3. **Claim & verify** — claiming a listing (either direction: "I found this" or "this is mine") requires a photo + description as proof. The listing's owner reviews the claim from a dedicated screen and accepts or rejects it.
4. **Chat** — accepting a claim opens a conversation between the two users; rejecting does not.
5. **Push notifications** — new matches, messages, and claims are delivered via Firebase Cloud Messaging, with the app deep-linking straight to the relevant screen on tap.

The app is bilingual (French / Arabic) and geo-aware — nearby listings are surfaced on a map and via radius search.

## Stack

**Backend** — `backend/`
- Laravel 12, PHP 8.2+
- MySQL, Sanctum (token auth)
- Cloudinary for photo storage
- Firebase Admin SDK ([kreait/laravel-firebase](https://github.com/kreait/laravel-firebase)) for push notifications
- Deployed on [Railway](https://railway.app)

**Mobile** — `mobile/`
- Flutter, Riverpod for state management, GoRouter for navigation
- `dio` (HTTP), `sqflite` (offline cache), `flutter_secure_storage` (auth token)
- `flutter_map` + `geolocator` for map/location features
- `firebase_messaging` + `flutter_local_notifications` for push
- Targets Android and iOS

## Getting started

### Backend

```bash
cd backend
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate
php artisan serve
```

Fill in `.env` with your database credentials. Photo storage and push notifications are optional at first — the app falls back to local disk storage and silently skips push if `CLOUDINARY_URL` / Firebase credentials aren't configured, so you can develop without setting those up immediately.

Run the test suite:

```bash
php artisan test
```

### Mobile

```bash
cd mobile
flutter pub get
flutter run --dart-define=API_BASE_URL=http://<your-backend-host>/api
```

`API_BASE_URL` must point at a reachable instance of the backend (e.g. `http://10.0.2.2:8000/api` for the Android emulator talking to a local server, or your deployed Railway URL for a release build).

## API overview

All endpoints are under `/api`. Except `/register` and `/login`, everything requires a Sanctum bearer token.

| Area | Endpoints |
|---|---|
| Auth | `POST /register`, `POST /login`, `POST /logout`, `GET /me` |
| Listings | `GET/POST /listings`, `GET /listings/search`, `GET/PUT/DELETE /listings/{id}`, `PATCH /listings/{id}/resolve`, `POST /listings/{id}/photos` |
| Claims | `POST /listings/{id}/claim`, `GET /claims`, `PATCH /claims/{id}` |
| Matches | `GET /matches`, `PATCH /matches/{id}` |
| Bookmarks | `GET /bookmarks`, `POST/DELETE /listings/{id}/bookmark` |
| Conversations | `GET /conversations`, `GET/POST /conversations/{id}/messages` |
| Push | `POST/DELETE /device-tokens` |