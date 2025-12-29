import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ouendi/screens/phone.dart';
import 'package:ouendi/screens/pincode.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InactivityService with WidgetsBindingObserver {
  static final InactivityService _instance = InactivityService._internal();
  factory InactivityService() => _instance;
  InactivityService._internal();

  Timer? _timer;
  Duration timeout = const Duration(seconds: 90);
  bool enabled = false;

  BuildContext? _safeContext; // stocké mais nullable

  void setContext(BuildContext context) {
    _safeContext = context;   // context toujours mis à jour
  }

  void start() {
    enabled = true;
    _reset();
    WidgetsBinding.instance.addObserver(this);
  }

  void stop() {
    enabled = false;
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
  }

  void _reset() {
    if (!enabled) return;

    _timer?.cancel();
    _timer = Timer(timeout, _onTimeout);
  }

  Future<void> _onTimeout() async {
    if (!enabled) return;

    final context = _safeContext;

    // si le context n'existe plus => ne pas naviguer (EVITE LE CRASH)
    if (context == null || !context.mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString('phone');

    final targetScreen = (phone != null && phone.isNotEmpty)
        ? PinCode()
        : Phone();

    // Navigation sécurisée
    Future.microtask(() {
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => targetScreen),
              (route) => false,
        );
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!enabled) return;

    if (state == AppLifecycleState.paused) {
      _reset();
    }
  }

  void userActivityDetected() => _reset();
}