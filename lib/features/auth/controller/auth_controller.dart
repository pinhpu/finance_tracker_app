import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthController {
  final _storage = const FlutterSecureStorage();
  static const _pinKey = 'user_pin';

  Future<bool> hasPin() async {
    final pin = await _storage.read(key: _pinKey);
    return pin != null && pin.isNotEmpty;
  }

  Future<bool> setupPin(String pin) async {
    try {
      await _storage.write(key: _pinKey, value: pin);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> verifyPin(String enteredPin) async {
    final storedPin = await _storage.read(key: _pinKey);
    return storedPin == enteredPin;
  }

  Future<void> removePin() async {
    await _storage.delete(key: _pinKey);
  }
}
