Built for Smart TBK technical assessment.

This frontend was built to work with the Node.js backend project: [smart-tbk-test-nodejs](https://github.com/fmuamarr/smart-tbk-test-nodejs.git)

# Smart TBK Technical Test - Flutter

## About This Project

This is a Flutter app that takes a number, reverses it, and calculates the absolute difference between the original and reversed values. It supports two calculation modes — a built-in local calculation and an API mode that delegates to a Node.js backend.

I've structured this using Clean Architecture with proper separation of concerns — domain layer holds business logic, data layer handles API calls and mapping, and presentation layer manages UI and state. The app also supports English and Indonesian localization, and lets you configure a custom API host URL at runtime.

## Project Structure

```
lib/
├── app/            # Routes, theme, constants, localization
├── data/           # API provider, DTOs, mappers, repository implementations
├── domain/         # Entities, repository interfaces, use cases
└── presentation/   # UI views, GetX controllers, DI bindings
```

**Key packages:**
- **GetX** — state management, routing, and dependency injection
- **Dio** — HTTP client for API calls
- **GetStorage** — persisting the custom API host locally

## Getting Started

**Install dependencies:**
```bash
flutter pub get
```

**Run the app:**
```bash
flutter run
```

## Setting Up the Backend API

The API mode connects to a Node.js backend. Clone and run it:

```bash
git clone https://github.com/fmuamarr/smart-tbk-test-nodejs.git
cd smart-tbk-test-nodejs
npm install
npm start
```

Server runs on `http://localhost:3000` by default.

**Verify the server is up:**
```bash
curl http://localhost:3000/api/health
```

### API Endpoints

**Health Check:**
```bash
GET /api/health
```

**Calculate Number Reversal:**
```bash
POST /api/calculate
Content-Type: application/json

{
  "number": 1234
}
```

**Response:**
```json
{
  "success": true,
  "message": "Calculation completed successfully",
  "data": {
    "originalNumber": 1234,
    "reversedNumber": 4321,
    "difference": 3087
  }
}
```

## Pointing the App to the API

Once the app is running, tap the **settings icon** in the app bar. A bottom sheet will appear where you can enter your API host URL. The app performs a health check to verify the server is reachable before switching to API mode.

> If you're testing on a physical device or emulator, use your machine's local IP address (e.g., `http://192.168.x.x:3000`) instead of `localhost`.

## Technical Notes

The app implements Clean Architecture with GetX for reactive state management. Two separate use cases handle local and API calculations, injected via GetX bindings. The API layer uses Dio with request/response logging, and the custom host URL persists across sessions using GetStorage.