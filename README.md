# Flutter Stats

Flutter Stats is a software tool designed to estimate the size of applications created using the Flutter framework. It allows users to upload datasets containing software project metrics and builds a regression model to predict the number of lines of code based on the number of classes, methods, and dependencies.

## Table of Contents
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Project Structure](#project-structure)
- [Contributing](#contributing)
- [License](#license)

## Features
- Upload datasets with software project metrics.
- Build and use regression models to estimate lines of code.
- Predict the number of lines of code for given numbers of classes, methods, and dependencies.
- Developed using Flutter and Dart.
- Compatible with Web and Windows operating system.

## Installation

## Dependencies

This project uses the following GitHub package:

- [distributions](https://github.com/shebnik/distributions)

### Prerequisites
- Flutter SDK: [Install Flutter](https://flutter.dev/docs/get-started/install)
- Dart SDK: [Install Dart](https://dart.dev/get-dart)

### Steps
1. Clone the repository:
   ```bash
   git clone https://github.com/shebnik/flutter_stats.git
   cd flutter_stats
   ```

2. Get dependencies:
   ```bash
   flutter pub get
   ```

3. Run the application:
   ```bash
   flutter run
   ```

## Usage

1. **Upload Dataset**: Use the interface to upload a dataset containing metrics such as the number of classes, methods, dependencies, and lines of code.
2. **Build Regression Model**: The application will build a regression model based on the uploaded dataset.
3. **Predict Lines of Code**: Input the number of classes, methods, and dependencies to predict the number of lines of code.

### Web
You can use the web version of the application [here](https://flutterstats-nuos.web.app/).

### Windows 
Local build for Windows available in the [releases](https://github.com/shebnik/flutter_stats/releases).

## Project Structure

```plaintext
flutter_stats/
├── lib/
│   ├── main.dart
│   ├── models/
│   ├── services/
│   ├── ui/
│   └── utils/
├── test/
├── README.md
└── pubspec.yaml
```

- `lib/main.dart`: Entry point of the application.
- `lib/models/`: Contains data models.
- `lib/services/`: Contains business logic and service classes.
- `lib/ui/`: Contains UI components.
- `lib/utils/`: Contains utility functions and helpers.
- `test/`: Contains metrics datasets and python scripts for testing.

## Contributing

Contributions are welcome! Please follow these steps:
1. Fork the repository.
2. Create a new branch: `git checkout -b feature-branch`.
3. Make your changes.
4. Commit your changes: `git commit -m 'Add some feature'`.
5. Push to the branch: `git push origin feature-branch`.
6. Open a pull request.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.