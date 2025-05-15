import 'package:flutter_test/flutter_test.dart';
import 'package:sample_app/features/auth/data/models/user_model.dart';
import 'package:sample_app/features/auth/domain/entities/user.dart';

void main() {
  // Dummy values
  const testId = '123';
  const testEmail = 'test@example.com';

  // Dummy model
  const tModel = UserModel(id: testId, email: testEmail);

  // Dummy JSON object
  final Map<String, dynamic> dummyJson = {
    'id': testId,
    'email': testEmail,
  };

  group('UserModel', () {
    // Test 1
    test('should be a subclass of [User]', () {
      expect(tModel, isA<User>());
    });

    // Test 2
    test('fromJson should return a valid model', () {
      final result = UserModel.fromJson(dummyJson);
      expect(result.id, testId);
      expect(result.email, testEmail);
    });

    // Test 3
    test('toJson should return a valid map', () {
      final result = tModel.toJson();
      expect(result, equals(dummyJson));
    });

    // Test 4
    test('copyWith should update fields when new values are provided', () {
      final updatedModel = tModel.copyWith('456', 'new@example.com');
      expect(updatedModel.id, '456');
      expect(updatedModel.email, 'new@example.com');
    });

    // Test 5
    test('copyWith should retain original values when null is provided', () {
      final updatedModel = tModel.copyWith(null, null);
      expect(updatedModel.id, tModel.id);
      expect(updatedModel.email, tModel.email);
    });

    // Test 6
    test('empty constructor should return a valid default instance', () {
      const emptyModel = UserModel.empty();
      expect(emptyModel.id, "_empty.id");
      expect(emptyModel.email, "_empty.email");
    });

    // Test 7
    test('toJson and fromJson should be symmetric', () {
      final json = tModel.toJson();
      final fromJsonModel = UserModel.fromJson(json);
      expect(fromJsonModel.id, tModel.id);
      expect(fromJsonModel.email, tModel.email);
    });

    // Test 8 (Optional: if equality is overridden in UserModel/User)
    test('value comparison should work correctly if overridden', () {
      final anotherModel = UserModel(id: testId, email: testEmail);
      expect(tModel, equals(anotherModel));
    });
  });
}
