import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isAuthenticated = false;
  bool _isBiometricAvailable = false;
  String _lastError = '';

  bool get isAuthenticated => _isAuthenticated;
  bool get isBiometricAvailable => _isBiometricAvailable;
  String get lastError => _lastError;

  AuthService() {
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      _isBiometricAvailable = await _localAuth.canCheckBiometrics;
      print('Biometric available: $_isBiometricAvailable');
      
      if (_isBiometricAvailable) {
        final availableBiometrics = await _localAuth.getAvailableBiometrics();
        print('Available biometrics: $availableBiometrics');
      }
      
      notifyListeners();
    } catch (e) {
      _isBiometricAvailable = false;
      _lastError = 'Error checking biometric availability: $e';
      print('Biometric availability error: $e');
      notifyListeners();
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      _lastError = 'Error getting available biometrics: $e';
      print('Error getting biometrics: $e');
      return [];
    }
  }

  Future<bool> authenticateWithBiometrics() async {
    try {
      print('Starting biometric authentication...');
      
      final bool canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      print('Can authenticate with biometrics: $canAuthenticateWithBiometrics');
      
      if (!canAuthenticateWithBiometrics) {
        _lastError = 'Biometric authentication not available on this device';
        print('Biometric authentication not available');
        return false;
      }

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access your todo app',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      print('Authentication result: $didAuthenticate');

      if (didAuthenticate) {
        _isAuthenticated = true;
        _lastError = '';
        // Save authentication state
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isAuthenticated', true);
        notifyListeners();
      } else {
        _lastError = 'Authentication failed or was cancelled';
      }

      return didAuthenticate;
    } catch (e) {
      _lastError = 'Authentication error: $e';
      print('Authentication error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _lastError = '';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAuthenticated', false);
    notifyListeners();
  }

  Future<void> checkAuthenticationState() async {
    final prefs = await SharedPreferences.getInstance();
    _isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
    print('Authentication state: $_isAuthenticated');
    notifyListeners();
  }

  Future<bool> isBiometricSupported() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      _lastError = 'Error checking biometric support: $e';
      print('Biometric support error: $e');
      return false;
    }
  }

  // Method to manually authenticate for testing
  Future<bool> manualAuthenticate() async {
    try {
      print('Manual authentication triggered...');
      return await authenticateWithBiometrics();
    } catch (e) {
      _lastError = 'Manual authentication error: $e';
      print('Manual authentication error: $e');
      return false;
    }
  }
} 