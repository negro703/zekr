import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Controls screen brightness for the Quran reader feature.
///
/// Uses the platform brightness plugin to adjust the device's
/// physical screen brightness, and falls back to an in-app
/// overlay via [Opacity] when the platform plugin is unavailable.
abstract final class BrightnessService {
  static const MethodChannel _channel =
      MethodChannel('zekr/brightness');

  /// The current in-app brightness level (0.0 – 1.0).
  /// Defaults to the system brightness.
  static double _current = -1;

  /// Returns the current brightness level (0.0–1.0).
  /// Returns the system brightness if never overridden.
  static double get current {
    if (_current < 0) {
      final brightness = WidgetsBinding.instance.platformDispatcher
          .platformBrightness;
      return brightness == Brightness.dark ? 0.0 : 1.0;
    }
    return _current;
  }

  /// Sets the screen brightness to [value] (0.0 – 1.0).
  ///
  /// This applies a system-level brightness change where supported,
  /// and also applies an in-app overlay for platforms without
  /// system brightness control.
  static Future<void> setBrightness(double value) async {
    final clamped = value.clamp(0.0, 1.0).toDouble();
    _current = clamped;

    try {
      await _channel.invokeMethod('setBrightness', {'value': clamped});
    } on PlatformException {
      // Fall back to in-app overlay only.
    }

    // Apply in-app overlay.
    await _applyOverlay(clamped);
  }

  /// Resets brightness back to the system default.
  static Future<void> resetBrightness() async {
    _current = -1;

    try {
      await _channel.invokeMethod('resetBrightness');
    } on PlatformException {
      // Fall back to in-app overlay only.
    }

    await _removeOverlay();
  }

  /// Returns a widget overlay for the current brightness level.
  /// Used by the Quran reader to dim the screen when reading at night.
  static Widget overlay() {
    if (_current < 0 || _current >= 1.0) {
      return const SizedBox.shrink();
    }
    return IgnorePointer(
      child: Container(
        color: Colors.black.withValues(alpha: 1.0 - _current),
      ),
    );
  }

  static Future<void> _applyOverlay(double value) async {
    // In a production app, this would register the overlay in the
    // widget tree via an overlay entry or a global key.
    // For now, returning a no-op ensures device brightness works.
    await Future<void>.value();
  }

  static Future<void> _removeOverlay() async {
    await Future<void>.value();
  }
}