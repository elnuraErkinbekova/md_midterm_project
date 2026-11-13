# Shop App (Flutter + Bloc + Node.js + PostgreSQL)

```
.
├── mobile/              Flutter app (Bloc)
├── backend/             Node.js (Express) REST API
├── docker-compose.yml   Starts the API + PostgreSQL
└── README.md
```

## Run the backend

Requires only Docker.

```bash
docker compose up --build
```

API: http://localhost:3000 (check: http://localhost:3000/health).
On first start the database is created and filled with products
(from dummyjson.com, or a built-in set if offline).

Reset the database: `docker compose down -v`

## API

| Method | Path | Auth | Description |
|---|---|---|---|
| GET | /products?q=&category=&limit=&skip= | no | List/search. Returns `{products,total,skip,limit}` |
| GET | /products/:id | no | One product |
| GET | /categories | no | List of category names |
| POST | /auth/register `{name,email,password}` | no | Returns `{token,user}` |
| POST | /auth/login `{email,password}` | no | Returns `{token,user}` |
| GET | /auth/me | yes | Current user |
| GET | /cart | yes | `{items,totalItems,total}` |
| POST | /cart/items `{productId,quantity}` | yes | Add to cart |
| PATCH | /cart/items/:productId `{quantity}` | yes | Set quantity |
| DELETE | /cart/items/:productId | yes | Remove item |
| DELETE | /cart | yes | Clear cart |

Auth = header `Authorization: Bearer <token>`.

## Mobile base URL

- Android emulator: `http://10.0.2.2:3000`
- iOS simulator: `http://localhost:3000`
- Real phone: `http://<your computer's LAN IP>:3000`

## Run the mobile app

Requires Flutter. The backend (above) must be running.

```bash
cd mobile
flutter create . --project-name firstflutterproject --platforms=android,ios   # first time only: generates android/ and ios/
flutter pub get
flutter run
```

**Android only, first time:** in `mobile/android/app/src/main/AndroidManifest.xml` add
`android:usesCleartextTraffic="true"` to the `<application ...>` tag (the local server uses plain http).

The server address is chosen automatically (`10.0.2.2:3000` on the Android emulator, `localhost:3000` otherwise).
For a real phone: `flutter run --dart-define=API_URL=http://<your-computer-ip>:3000`

## Tests

```bash
cd mobile
flutter test
```

## State management (Bloc)

| Bloc | Events | Purpose |
|---|---|---|
| `ProductsBloc` | Started, SearchChanged, CategorySelected, Refreshed | Product list, search (debounced), category filter |
| `ProductDetailBloc` | Requested | One product, shown instantly then refreshed from the server |
| `CartBloc` | Loaded, ItemAdded, ItemQuantityChanged, ItemRemoved, Cleared, Reset | Server-side cart |
| `AuthBloc` | Started, LoginRequested, RegisterRequested, LogoutRequested | JWT login, session restored on app start |

Layers: `pages/widgets` -> `blocs` -> `repositories` -> `data` (Dio API classes) -> backend.
