# 🤝 Contributing to Anonim Chat

Thank you for your interest in contributing to Anonim Chat! This document provides guidelines and instructions for contributing.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Setup](#development-setup)
- [Pull Request Process](#pull-request-process)
- [Coding Standards](#coding-standards)
- [Commit Guidelines](#commit-guidelines)
- [Testing](#testing)

## 📜 Code of Conduct

### Our Pledge
We are committed to providing a welcoming and inspiring community for all.

### Our Standards
- ✅ Be respectful and inclusive
- ✅ Accept constructive criticism
- ✅ Focus on what's best for the community
- ✅ Show empathy towards others

- ❌ No harassment or discrimination
- ❌ No trolling or insulting comments
- ❌ No political or inappropriate content
- ❌ No personal attacks

## 🎯 How Can I Contribute?

### 🐛 Reporting Bugs

Before creating bug reports, please check existing issues. When creating a bug report, include:

- **Clear title and description**
- **Steps to reproduce**
- **Expected behavior**
- **Actual behavior**
- **Screenshots** (if applicable)
- **Environment details:**
  - Flutter version
  - Dart version
  - Device/Platform
  - Firebase SDK versions

**Template:**
```markdown
**Bug Description**
A clear description of the bug.

**To Reproduce**
1. Go to '...'
2. Click on '...'
3. See error

**Expected Behavior**
What should happen.

**Screenshots**
If applicable.

**Environment**
- Flutter: X.X.X
- Dart: X.X.X
- Platform: Android/iOS/Web
```

### 💡 Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. Include:

- **Clear title and description**
- **Use case:** Why is this needed?
- **Proposed solution**
- **Alternative solutions** considered
- **Additional context**

### 🔧 Code Contributions

1. **Find an issue** to work on (or create one)
2. **Comment** on the issue that you'd like to work on it
3. **Fork** the repository
4. **Create a branch** from `main`
5. **Make your changes**
6. **Submit a pull request**

## 🛠️ Development Setup

### Prerequisites

```bash
# Flutter SDK (3.0+)
flutter doctor

# Firebase CLI
npm install -g firebase-tools

# Git
git --version
```

### Setup Steps

1. **Fork and clone:**
```bash
git clone https://github.com/YOUR_USERNAME/full-anonim-chat-with-world.git
cd anonimchat
```

2. **Install dependencies:**
```bash
flutter pub get
```

3. **Set up Firebase:**
- Create your own Firebase project
- Add `google-services.json` (Android)
- Add `GoogleService-Info.plist` (iOS)
- **DO NOT commit these files!**

4. **Run the app:**
```bash
flutter run
```

### Project Structure

```
lib/
├── models/          # Data models
├── services/        # Business logic
├── providers/       # State management
├── screens/         # UI screens
└── main.dart        # Entry point
```

## 🔄 Pull Request Process

### 1. Create a Feature Branch

```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/your-bug-fix
```

**Branch naming:**
- `feature/` - New features
- `fix/` - Bug fixes
- `docs/` - Documentation
- `refactor/` - Code refactoring
- `test/` - Adding tests
- `chore/` - Maintenance tasks

### 2. Make Your Changes

- Write clean, readable code
- Follow existing code style
- Add comments for complex logic
- Update documentation if needed

### 3. Test Your Changes

```bash
# Format code
flutter format .

# Analyze code
flutter analyze

# Run tests
flutter test

# Test on device
flutter run
```

### 4. Commit Your Changes

```bash
git add .
git commit -m "feat: add amazing feature"
```

See [Commit Guidelines](#commit-guidelines) below.

### 5. Push and Create PR

```bash
git push origin feature/your-feature-name
```

Then create a Pull Request on GitHub with:

- **Clear title** (following commit convention)
- **Description** of changes
- **Related issue** number (if applicable)
- **Screenshots** (for UI changes)
- **Testing done**

### 6. PR Review Process

- Maintainers will review your PR
- Address any requested changes
- Once approved, your PR will be merged
- Your contribution will be credited

## 📝 Coding Standards

### Dart/Flutter Code Style

```dart
// ✅ Good
class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Future<User> getUser(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return User.fromFirestore(doc);
  }
}

// ❌ Bad
class userservice {
  var firestore = FirebaseFirestore.instance;
  
  getUser(userId) async {
    var doc = await firestore.collection('users').doc(userId).get();
    return User.fromFirestore(doc);
  }
}
```

### Guidelines:

1. **Naming Conventions:**
   - Classes: `PascalCase`
   - Variables/Functions: `camelCase`
   - Constants: `UPPER_SNAKE_CASE`
   - Private members: `_leadingUnderscore`

2. **Code Organization:**
   - One class per file
   - Group related functions
   - Use meaningful names
   - Avoid magic numbers

3. **Documentation:**
   ```dart
   /// Sends a message to the specified room.
   /// 
   /// Returns the message ID if successful.
   /// Throws [Exception] if user is banned.
   Future<String> sendMessage({
     required String roomId,
     required String text,
   }) async {
     // Implementation
   }
   ```

4. **Error Handling:**
   ```dart
   try {
     await riskyOperation();
   } catch (e) {
     // Handle error appropriately
     throw Exception('Operation failed: $e');
   }
   ```

5. **Async/Await:**
   ```dart
   // ✅ Use async/await
   Future<void> loadData() async {
     final data = await fetchData();
     processData(data);
   }
   
   // ❌ Don't use .then() chains
   ```

## 📝 Commit Guidelines

We follow [Conventional Commits](https://www.conventionalcommits.org/).

### Format:

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types:

- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation changes
- `style` - Code style changes (formatting)
- `refactor` - Code refactoring
- `test` - Adding tests
- `chore` - Maintenance tasks
- `perf` - Performance improvements

### Examples:

```bash
# Feature
git commit -m "feat(chat): add message reactions"

# Bug fix
git commit -m "fix(auth): resolve login crash on iOS"

# Documentation
git commit -m "docs(readme): update installation steps"

# Breaking change
git commit -m "feat(encryption)!: change to AES-256

BREAKING CHANGE: Old encrypted messages won't be compatible"
```

## 🧪 Testing

### Running Tests

```bash
# All tests
flutter test

# Specific test
flutter test test/services/auth_service_test.dart

# With coverage
flutter test --coverage
```

### Writing Tests

```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserService', () {
    test('should create user with unique username', () async {
      // Arrange
      final userService = UserService();
      
      // Act
      final user = await userService.createUser();
      
      // Assert
      expect(user.username, startsWith('User#'));
      expect(user.username.length, greaterThan(5));
    });
  });
}
```

### Test Coverage Goals:

- **Services:** 80%+ coverage
- **Models:** 100% coverage
- **Providers:** 60%+ coverage
- **UI:** Widget tests for critical flows

## 🎨 UI/UX Contributions

### Design Guidelines:

1. **Follow Material 3 Design**
2. **Maintain consistency** with existing UI
3. **Responsive design** for all screen sizes
4. **Accessibility:** Consider screen readers, contrast
5. **Performance:** Avoid expensive rebuilds

### Screenshots Required:

For UI changes, include screenshots of:
- Before/After
- Different screen sizes
- Light/Dark mode (if applicable)
- Error states
- Loading states

## 🌍 Internationalization (i18n)

Currently, the app is in Turkish. If you want to add translations:

1. Create a localization PR
2. Use `intl` package
3. Add all strings to locale files
4. Update documentation

## 📚 Documentation Contributions

Documentation is as important as code! You can contribute by:

- Improving README
- Adding code comments
- Writing tutorials
- Creating diagrams
- Updating API docs

## ⚡ Quick Contribution Checklist

Before submitting your PR, ensure:

- [ ] Code follows project style
- [ ] All tests pass
- [ ] No lint errors (`flutter analyze`)
- [ ] Code is formatted (`flutter format .`)
- [ ] Documentation is updated
- [ ] Commit messages follow convention
- [ ] PR description is clear
- [ ] Screenshots included (for UI changes)
- [ ] No sensitive data committed

## 🎉 Recognition

All contributors will be recognized in:
- README.md contributors section
- Release notes
- GitHub contributors page

Thank you for contributing to Anonim Chat! 🚀

## 💬 Questions?

- Open an issue with the `question` label
- Check existing issues and discussions
- Read the README.md

---

**Happy Contributing! 🎨**
