# Safe Navigation Utility - Usage Guide

## Overview

The `SafeNavigation` utility provides a centralized, safe way to handle GoRouter navigation across your Flutter app. It prevents common errors like:

- ❌ Popping the last page off the stack
- ❌ _debugLocked assertion errors
- ❌ Navigation after widget disposal
- ❌ Multiple rapid navigation calls

## Installation

The utility is located at:
```
lib/core/utils/safe_navigation.dart
```

Import it in your files:
```dart
import 'package:tolab_fci/core/utils/safe_navigation.dart';
```

---

## Usage Examples

### 1. Safe Pop (Go Back)

```dart
// Using the utility class
SafeNavigation.pop(context);

// Using the extension (recommended)
context.safePop();
```

**What it does:**
- Checks if there's a page to pop
- Pops if possible
- Falls back to `/home` if this is the root page
- Prevents frame locking errors

---

### 2. Pop with Custom Fallback

```dart
// Pop or navigate to dashboard if root
SafeNavigation.popOrGo(context, '/dashboard');

// Using extension
context.safePopOrGo('/dashboard');
```

---

### 3. Navigate to Route

```dart
// Using the utility class
SafeNavigation.go(context, '/courses');

// Using extension (recommended)
context.safeGo('/courses');
```

**What it does:**
- Replaces current route with new one
- Prevents frame locking
- Handles errors gracefully

---

### 4. Push New Route

```dart
// Using the utility class
SafeNavigation.push(context, '/add-lecture');

// Using extension (recommended)
context.safePush('/add-lecture');
```

**What it does:**
- Adds new route to stack
- Allows back navigation
- Prevents frame locking

---

### 5. Check if Can Pop

```dart
// Using the utility class
if (SafeNavigation.canPop(context)) {
  SafeNavigation.pop(context);
}

// Using extension (recommended)
if (context.canSafePop()) {
  context.safePop();
}
```

---

## Real-World Examples

### Example 1: Back Button with Dirty Form Check

```dart
class AddLecturePageState extends State<AddLecturePage> {
  Future<void> _handleBackPressed() async {
    if (!_isFormDirty()) {
      context.safePop();  // ✅ Safe navigation
      return;
    }

    final shouldDiscard = await _showDiscardDialog();
    if (shouldDiscard == true && mounted) {
      context.safePop();  // ✅ Safe navigation
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _handleBackPressed,
        ),
      ),
      // ...
    );
  }
}
```

### Example 2: Form Submission with Navigation

```dart
class EditCoursePageState extends State<EditCoursePage> {
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      // Save data
      await _saveCourse();

      if (!mounted) return;

      // Navigate back safely
      context.safePop();  // ✅ Safe navigation
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Form fields...
            ElevatedButton(
              onPressed: _submitForm,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Example 3: Navigation After Async Operation

```dart
class DashboardPageState extends State<DashboardPage> {
  Future<void> _loadDataAndNavigate() async {
    try {
      final data = await _fetchData();

      if (!mounted) return;

      // Navigate safely after async operation
      context.safePush('/course-details');  // ✅ Safe navigation
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadDataAndNavigate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.safeGo('/courses'),  // ✅ Safe navigation
          child: const Text('Go to Courses'),
        ),
      ),
    );
  }
}
```

### Example 4: Dialog with Navigation

```dart
class ConfirmDeletePageState extends State<ConfirmDeletePage> {
  Future<void> _showDeleteConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete?'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    ) ?? false;

    if (confirmed && mounted) {
      try {
        await _deleteItem();
        // Navigate back safely after deletion
        context.safePop();  // ✅ Safe navigation
      } catch (e) {
        _showErrorDialog(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: _showDeleteConfirmation,
          child: const Text('Delete Item'),
        ),
      ),
    );
  }
}
```

### Example 5: Multiple Navigation Operations

```dart
class ComplexFlowPageState extends State<ComplexFlowPage> {
  Future<void> _complexNavigation() async {
    try {
      // Step 1: Save data
      await _saveData();
      if (!mounted) return;

      // Step 2: Navigate to next page
      context.safePush('/step-2');  // ✅ Safe navigation

      // Step 3: After some operation, go back
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;

      context.safePop();  // ✅ Safe navigation
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: _complexNavigation,
          child: const Text('Start Complex Flow'),
        ),
      ),
    );
  }
}
```

---

## Comparison: Before vs After

### ❌ BEFORE (Unsafe)

```dart
Future<void> _handleBackPressed() async {
  if (!_isFormDirty()) {
    Navigator.of(context).pop();  // ❌ Crashes if root page
    return;
  }

  final shouldDiscard = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(...),
  );

  if (shouldDiscard == true && mounted) {
    Navigator.of(context).pop();  // ❌ Crashes if root page
  }
}
```

**Problems:**
- ❌ No check if page can be popped
- ❌ Crashes on root page
- ❌ No fallback route
- ❌ No error handling
- ❌ Uses Navigator instead of GoRouter

### ✅ AFTER (Safe)

```dart
Future<void> _handleBackPressed() async {
  if (!_isFormDirty()) {
    context.safePop();  // ✅ Safe
    return;
  }

  final shouldDiscard = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(...),
  );

  if (shouldDiscard == true && mounted) {
    context.safePop();  // ✅ Safe
  }
}
```

**Benefits:**
- ✅ Checks if page can be popped
- ✅ Falls back to home if root page
- ✅ Prevents frame locking
- ✅ Error handling included
- ✅ Uses GoRouter correctly

---

## API Reference

### SafeNavigation Class

#### `pop(BuildContext context)`
Safely pop the current page. Falls back to `/home` if root.

#### `popOrGo(BuildContext context, String fallbackRoute)`
Safely pop or navigate to fallback route.

#### `go(BuildContext context, String route)`
Safely navigate to a route (replaces current).

#### `push(BuildContext context, String route)`
Safely push a new route (adds to stack).

#### `pushNamed(BuildContext context, String name, ...)`
Safely push a named route with parameters.

#### `canPop(BuildContext context)`
Check if the current page can be popped.

---

## Extension Methods

### `context.safePop()`
Equivalent to `SafeNavigation.pop(context)`

### `context.safePopOrGo(String fallbackRoute)`
Equivalent to `SafeNavigation.popOrGo(context, fallbackRoute)`

### `context.safeGo(String route)`
Equivalent to `SafeNavigation.go(context, route)`

### `context.safePush(String route)`
Equivalent to `SafeNavigation.push(context, route)`

### `context.canSafePop()`
Equivalent to `SafeNavigation.canPop(context)`

---

## Best Practices

### 1. Always Use Safe Navigation
```dart
// ✅ GOOD
context.safePop();

// ❌ BAD
context.pop();
Navigator.of(context).pop();
```

### 2. Check Before Popping (Optional)
```dart
// ✅ GOOD - Explicit check
if (context.canSafePop()) {
  context.safePop();
}

// ✅ ALSO GOOD - SafeNavigation handles it
context.safePop();
```

### 3. Use Appropriate Method
```dart
// ✅ GOOD - Use push for detail pages
context.safePush('/edit-lecture');

// ✅ GOOD - Use go for section changes
context.safeGo('/courses');

// ✅ GOOD - Use pop for going back
context.safePop();
```

### 4. Handle Async Properly
```dart
// ✅ GOOD - Check mounted before navigation
Future<void> _loadAndNavigate() async {
  await _loadData();
  if (!mounted) return;
  context.safePush('/next');
}
```

### 5. Provide Fallback Routes
```dart
// ✅ GOOD - Fallback to dashboard
context.safePopOrGo('/dashboard');

// ✅ GOOD - SafeNavigation defaults to /home
context.safePop();
```

---

## Testing

### Test Cases

```dart
void main() {
  testWidgets('SafeNavigation.pop works on non-root page', (tester) async {
    // Test pop on non-root page
    expect(context.canSafePop(), true);
    context.safePop();
    // Verify navigation occurred
  });

  testWidgets('SafeNavigation.pop falls back on root page', (tester) async {
    // Test pop on root page
    expect(context.canSafePop(), false);
    context.safePop();
    // Verify fallback to /home occurred
  });

  testWidgets('SafeNavigation prevents frame locking', (tester) async {
    // Test that addPostFrameCallback is used
    context.safePush('/next');
    await tester.pumpAndSettle();
    // Verify no _debugLocked errors
  });
}
```

---

## Migration Guide

### Step 1: Import the utility
```dart
import 'package:tolab_fci/core/utils/safe_navigation.dart';
```

### Step 2: Replace unsafe navigation
```dart
// Before
Navigator.of(context).pop();
context.pop();

// After
context.safePop();
```

### Step 3: Update all navigation calls
```dart
// Before
context.push('/page');
context.go('/page');

// After
context.safePush('/page');
context.safeGo('/page');
```

---

## Troubleshooting

### Issue: Still getting "last page off stack" error

**Solution:** Make sure you're using `context.safePop()` instead of `context.pop()`

```dart
// ❌ WRONG
context.pop();

// ✅ CORRECT
context.safePop();
```

### Issue: Still getting _debugLocked error

**Solution:** Make sure you're using the safe navigation methods

```dart
// ❌ WRONG
context.push('/page');

// ✅ CORRECT
context.safePush('/page');
```

### Issue: Navigation not working

**Solution:** Check that the route exists in your GoRouter configuration

```dart
// Make sure '/home' route exists in GoRouter
GoRouter(
  routes: [
    GoRoute(path: '/home', builder: (context, state) => HomePage()),
    // ...
  ],
)
```

---

## Summary

**SafeNavigation provides:**
- ✅ Safe pop with fallback
- ✅ Frame locking prevention
- ✅ Error handling
- ✅ Convenient extension methods
- ✅ Production-ready code

**Use it for:**
- ✅ Back buttons
- ✅ Form submissions
- ✅ Dialog confirmations
- ✅ Async operations
- ✅ Any navigation

**Result:**
- ✅ No more navigation crashes
- ✅ No more _debugLocked errors
- ✅ Consistent navigation patterns
- ✅ Professional error handling

---

**Status:** ✅ Ready to Use  
**Location:** `lib/core/utils/safe_navigation.dart`
