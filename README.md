# Malawi Curriculum API - Flutter SDK 🇲🇼

A Flutter/Dart client for accessing the Malawi Curriculum API.

## Installation

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  malawi_curriculum_api:
    path: ./malawi_curriculum_api_flutter_sdk
```

(Or git dependency if hosted remotely)

## Usage

### Initialization

```dart
import 'package:malawi_curriculum_api/malawi_curriculum_client.dart';

final client = MalawiCurriculumClient(
  apiKey: 'YOUR_API_KEY',
  // Optional: Override URL for local dev
  // baseUrl: 'http://localhost:3000/api/v1', 
);
```

### Fetch Resources

```dart
final resources = await client.getResources(
  level: 'MSCE',
  subject: 'Mathematics',
  type: 'past_paper',
  year: 2023,
);

for (var resource in resources) {
  print(resource.title);
}
```

### Download Resource (Paid Plans)

```dart
try {
  final url = await client.downloadResource(123);
  print('Download URL: $url');
} catch (e) {
  print('Error: $e');
}
```

### Get Metadata

```dart
final subjects = await client.getSubjects(level: 'MSCE');
final levels = await client.getLevels();
```

## Data Models

- `Resource`: Represents a curriculum item (paper, book, etc.)
- `Subject`: Represents a subject in the curriculum.

## License

ISC
