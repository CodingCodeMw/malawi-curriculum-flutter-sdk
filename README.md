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

### Download Resource

Generates a temporary signed URL to download a resource file. **Requires a paid subscription** (Basic, Pro, or Enterprise).

```dart
try {
  final url = await client.downloadResource(101);
  print('Download URL: $url');
} catch (e) {
  print('Error: $e');
}
```

**Request:**
- Method: `GET`
- Endpoint: `/resources/:id/download`
- Headers: `Authorization: Bearer API_KEY`
- URL Parameters:
  - `id`: Resource ID (integer)

**Response (Success):**
```json
{
  "success": true,
  "download_url": "https://storage.googleapis.com/...",
  "expires_in_seconds": 300
}
```

**Response (Free Tier):**
```json
{
  "message": "Free tier cannot download files. Please upgrade to Basic or Pro."
}
```

**Response (Limit Exceeded):**
```json
{
  "message": "Daily download limit exceeded (100 downloads/day). Upgrade plan for more."
}
```

**Returns:** `String` - Temporary download URL (valid for 5 minutes)

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

### Free Plan
- 100 requests/day
- Metadata access only
- No file downloads

### Basic Plan (20,000 MWK/month)
- 1,000 requests/day
- 5 downloads/day
- Full API access

### Pro Plan (15,000 MWK/month)
- 10,000 requests/day
- 100 downloads/day
- Priority support

### Enterprise Plan (150,000 MWK/month)
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
