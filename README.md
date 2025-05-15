<!DOCTYPE html>
<html lang="en">
<body>

  <h1>🚀 Flutter Clean Architecture (TDD) Boilerplate</h1>
  <p>
    A ready-to-use project structure for scalable and testable Flutter apps using Clean Architecture principles and Test-Driven Development (TDD).
  </p>

  <div class="section">
    <h2>📦 What’s Included</h2>
    <ul>
      <li><strong>Architecture:</strong> Clean Architecture (Domain, Data, Presentation)</li>
      <li><strong>State Management:</strong> BLoC</li>
      <li><strong>Dependency Injection:</strong> get_it</li>
      <li><strong>Networking:</strong> Dio</li>
      <li><strong>Code Generation:</strong> Freezed, JsonSerializable</li>
      <li><strong>Testing:</strong> Unit, Bloc, and Widget Tests</li>
    </ul>
  </div>

  <div class="section">
    <h2>🗂️ Folder Structure</h2>
    <pre>
lib/
├── core/
│   ├── di/
│   ├── error/
│   └── usecases/
├── features/
│   └── auth/
│       ├── data/
│       ├── domain/
│       └── presentation/
└── main.dart
.
test/
└── features/
.   └── auth/
.       ├── data/
.       ├── domain/
.       └── presentation/
    </pre>
  </div>

  <div class="section">
    <h2>🧪 Test Coverage Summary</h2>
    <ul>
      <li><strong>Model Layer:</strong> <code>UserModel</code> JSON serialization/deserialization, equality, and factory tests</li>
      <li><strong>Repository Layer:</strong> <code>AuthRepositoryImpl</code> unit tests for both success and failure cases</li>
      <li><strong>Use Cases:</strong> <code>Login</code> use case tested for correct interaction with repository and error handling</li>
      <li><strong>BLoC:</strong> Comprehensive tests for all AuthBloc states:
        <ul>
          <li>Initial, Loading, Success, Failure transitions</li>
          <li>Mocked use case integration</li>
        </ul>
      </li>
      <li><strong>UI Tests:</strong> <code>LoginPage</code> widget tests:
        <ul>
          <li>Input validations</li>
          <li>Form submission dispatch</li>
          <li>Success and failure snackbar behaviors</li>
        </ul>
      </li>
    </ul>
  </div>

  <div class="section">
    <h2>⚙️ Setup Instructions</h2>
    <ol>
      <li>Make the script executable:
        <pre>chmod +x script.sh</pre>
      </li>
      <li>Create your app:
        <pre>./script.sh &lt;your_app_name&gt;</pre>
      </li>
      <li>Run tests when prompted or manually:
        <pre>flutter test</pre>
      </li>
    </ol>
  </div>

  <div class="highlight">
    <strong>Note:</strong> This boilerplate is designed for long-term scalability, maintainability, and high test coverage from day one.
  </div>

  <!-- <div class="important"> -->
<div class="highlight">
    <strong>Platform Note:</strong> This script runs best on macOS/Linux. Use Git Bash or WSL on Windows.
  </div>

  <footer>
    Created with ❤️ for scalable Flutter development.
  </footer>
</body>
</html>
