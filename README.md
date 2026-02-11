# Malawi Curriculum API - Flutter SDK

A Flutter/Dart client for accessing the Malawi Curriculum API.

## Installation

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  malawi_curriculum_api:
    git:
      url: https://github.com/CodingCodeMw/malawi-curriculum-flutter-sdk.git
```

## Quick Start

```dart
import 'package:malawi_curriculum_api/malawi_curriculum_client.dart';

final client = MalawiCurriculumClient(
  apiKey: 'YOUR_API_KEY',
);

final resources = await client.getResources(
  level: 'MSCE',
  subject: 'Mathematics',
  type: 'past_paper',
);
```

## API Overview

The Malawi Curriculum API provides access to educational resources across various academic levels in Malawi. All endpoints require authentication via an API key.

### Base URL

```
https://malawi-curricular-api-production.up.railway.app/api/v1
```

### Authentication

Include your API key in the `Authorization` header. The SDK handles this automatically.

## API Reference

### Get Levels

Retrieves all academic levels available in the Malawi curriculum.

```dart
final levels = await client.getLevels();

for (String level in levels) {
  print(level);
}
```

**Request:**
- Method: `GET`
- Endpoint: `/levels`
- Headers: `Authorization: Bearer API_KEY`

**Response:**
```json
{
  "success": true,
  "count": 3,
  "data": [
    { "id": 1, "name": "JCE" },
    { "id": 2, "name": "MSCE" },
    { "id": 3, "name": "Primary" }
  ]
}
```

**Returns:** `List<String>` - List of level names

---

### Get Subjects

Retrieves subjects, optionally filtered by academic level.

```dart
final subjects = await client.getSubjects(level: 'MSCE');

for (var subject in subjects) {
  print('${subject['id']}: ${subject['name']} (${subject['level']})');
}
```

**Request:**
- Method: `GET`
- Endpoint: `/subjects`
- Headers: `Authorization: Bearer API_KEY`
- Query Parameters:
  - `level` (optional): Filter by level name (e.g., "MSCE", "JCE")

**Response:**
```json
{
  "success": true,
  "count": 12,
  "data": [
    { "id": 1, "name": "Mathematics", "level": "MSCE" },
    { "id": 2, "name": "Physics", "level": "MSCE" },
    { "id": 3, "name": "Chemistry", "level": "MSCE" }
  ]
}
```

**Returns:** `List<dynamic>` - List of subject objects

---

### Get Resources

Retrieves curriculum resources with filtering options.

```dart
final resources = await client.getResources(
  level: 'MSCE',
  subject: 'Mathematics',
  type: 'past_paper',
  year: 2023,
  limit: 10,
);

for (var resource in resources) {
  print('${resource['title']} (${resource['year']})');
}
```

**Request:**
- Method: `GET`
- Endpoint: `/resources`
- Headers: `Authorization: Bearer API_KEY`
- Query Parameters:
  - `level` (optional): Academic level (e.g., "MSCE", "JCE")
  - `subject` (optional): Subject name (e.g., "Mathematics")
  - `type` (optional): Resource type
    - `past_paper`
    - `marking_scheme`
    - `textbook`
    - `teacher_notes`
    - `student_notes`
    - `scheme_of_work`
  - `year` (optional): Year of the resource (integer)
  - `limit` (optional): Number of results (1-100, default: 50)

**Response:**
```json
{
  "success": true,
  "count": 5,
  "total_count": 47,
  "data": [
    {
      "id": 101,
      "title": "MSCE Mathematics Paper 1 2023",
      "type": "past_paper",
      "year": 2023,
      "description": "Main examination paper",
      "subject": "Mathematics",
      "level": "MSCE"
    }
  ]
}
```

**Returns:** `List<dynamic>` - List of resource objects

---

### Download Resource (Secure Token Flow)

Downloads use a two-step token flow for security. Requires a paid subscription (Basic, Pro, or Enterprise).

#### Request a Download Token

```dart
try {
  final tokenData = await client.requestDownload(101);
  print('Token: ${tokenData['token']}');
  print('Expires in: ${tokenData['expires_in_seconds']} seconds');
} catch (e) {
  print('Error: $e');
}
```

**Request:**
- Method: `POST`
- Endpoint: `/downloads/request`
- Headers: `Authorization: Bearer API_KEY`
- Body: `{ "resourceId": 101 }`

**Response:**
```json
{
  "success": true,
  "token": "a1b2c3d4e5f6...",
  "expires_in_seconds": 900,
  "download_url": "/api/v1/downloads/a1b2c3d4e5f6..."
}
```

#### Redeem the Token

```dart
try {
  final download = await client.redeemDownload(tokenData['token']);
  print('File URL: ${download['download_url']}');
  // URL is valid for 5 minutes, max 2 attempts per token
} catch (e) {
  print('Error: $e');
}
```

**Request:**
- Method: `GET`
- Endpoint: `/downloads/{token}`
- No API key required (token is the authentication)

**Response:**
```json
{
  "success": true,
  "download_url": "https://storage.googleapis.com/...",
  "expires_in_seconds": 300,
  "attempts_remaining": 1
}
```

**Error Responses:**
```json
// Free Tier
{ "error": "Free tier cannot download files.", "code": "PLAN_INSUFFICIENT" }

// Limit Exceeded
{ "error": "Daily download limit exceeded (100/day).", "code": "DOWNLOAD_LIMIT_EXCEEDED" }

// Token Expired
{ "error": "Download token has expired.", "code": "TOKEN_EXPIRED" }

// Max Attempts
{ "error": "Maximum download attempts reached (2).", "code": "TOKEN_MAX_ATTEMPTS" }
```

> **Security:** Tokens expire after 15 minutes, allow max 2 download attempts, and are stored as SHA-256 hashes in the database. The signed download URL is only valid for 5 minutes.

**Returns:** `Map<String, dynamic>` containing the download URL and metadata

---

### Search Resources

Search across all curriculum resources. Results and filter capabilities depend on your plan tier.

```dart
final results = await client.search(
  q: 'biology past paper',
  level: 'MSCE',        // Basic+ plans
  type: 'past_paper',   // Pro+ plans
  year: 2024,           // Pro+ plans
);

for (var item in results) {
  print('${item['title']} (relevance: ${item['relevance']})');
}
```

**Request:**
- Method: `GET`
- Endpoint: `/search`
- Headers: `Authorization: Bearer API_KEY`
- Query Parameters:
  - `q` (required): Search query (min 2 characters)
  - `level` (optional): Filter by level — Basic+ plans only
  - `subject` (optional): Filter by subject — Basic+ plans only
  - `type` (optional): Filter by resource type — Pro+ plans only
  - `year` (optional): Filter by year — Pro+ plans only
  - `limit` (optional): Max results (capped by plan tier)
  - `offset` (optional): Pagination offset
  - `sort` (optional): Sort order — Enterprise only (`relevance`, `newest`, `oldest`, `title`)

**Response:**
```json
{
  "success": true,
  "count": 5,
  "total_count": 23,
  "tier": "basic",
  "tier_info": "Title & description search with basic filters.",
  "data": [
    {
      "id": 101,
      "title": "MSCE Biology Paper 1 2024",
      "type": "past_paper",
      "year": 2024,
      "subject": "Biology",
      "level": "MSCE",
      "relevance": 0.8721
    }
  ]
}
```

**Returns:** `List<dynamic>` - List of resource objects with relevance scores

**Search Tier Limits:**

| Feature | Free | Basic | Pro | Enterprise |
|---|---|---|---|---|
| Search fields | Title only | Title + Description | Title + Description | Title + Description |
| Max results | 10 | 50 | 100 | 500 |
| Filters | None | Level, Subject | All | All + Sorting |

## Error Handling

All methods may throw exceptions for various reasons:

```dart
try {
  final resources = await client.getResources(
    level: 'MSCE',
    subject: 'Math',
  );
} catch (e) {
  if (e.toString().contains('401')) {
    print('Invalid API key');
  } else if (e.toString().contains('429')) {
    print('Rate limit exceeded');
  } else {
    print('Error: $e');
  }
}
```

### Common HTTP Status Codes

- `200` - Success
- `401` - Unauthorized (invalid or missing API key)
- `403` - Forbidden (subscription expired or insufficient permissions)
- `404` - Resource not found
- `429` - Rate limit exceeded

## Rate Limits & Plans

Different subscription tiers provide varying levels of access. Visit the [developer portal](https://malawi-curricular-api-production.up.railway.app) for current pricing.

### Free Plan
- 100 requests/day
- Metadata access only
- No file downloads

### Basic Plan
- 1,000 requests/day
- 5 downloads/day
- Full API access

### Pro Plan
- 10,000 requests/day
- 100 downloads/day
- Priority support

### Enterprise Plan
- 100,000 requests/day
- 1,000 downloads/day
- 24/7 support

## Data Models

The SDK uses dynamic types for simplicity. Here's the structure of common objects:

### Resource Object
```dart
{
  "id": 101,
  "title": "MSCE Mathematics Paper 1 2023",
  "type": "past_paper",
  "year": 2023,
  "description": "Main examination paper",
  "subject": "Mathematics",
  "level": "MSCE"
}
```

### Subject Object
```dart
{
  "id": 1,
  "name": "Mathematics",
  "level": "MSCE"
}
```

### Level Object
```dart
{
  "id": 1,
  "name": "MSCE"
}
```

## License

ISC
