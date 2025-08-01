import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jinbeanpod_83904710/core/ui/themes/provider_theme.dart';
import 'package:jinbeanpod_83904710/core/ui/themes/jinbean_theme.dart';

void main() {
  group('ProviderTheme Tests', () {
    test('ProviderTheme light theme should be different from base theme', () {
      final providerTheme = JinBeanProviderTheme.lightTheme;
      final baseTheme = JinBeanTheme.lightTheme;
      
      // ProviderTheme should have different primary color (darker)
      expect(providerTheme.colorScheme.primary, isNot(baseTheme.colorScheme.primary));
      
      // ProviderTheme should have tertiary color (green)
      expect(providerTheme.colorScheme.tertiary, isNotNull);
      
      // ProviderTheme should have different card theme (smaller border radius)
      expect(providerTheme.cardTheme.shape, isNot(baseTheme.cardTheme.shape));
    });

    test('ProviderTheme dark theme should be different from base dark theme', () {
      final providerDarkTheme = JinBeanProviderTheme.darkTheme;
      final baseDarkTheme = JinBeanTheme.darkTheme;
      
      // ProviderTheme dark should have different characteristics
      expect(providerDarkTheme.colorScheme.primary, isNot(baseDarkTheme.colorScheme.primary));
    });

    test('ProviderTheme should have professional color scheme', () {
      final theme = JinBeanProviderTheme.lightTheme;
      
      // Should have professional colors
      expect(theme.colorScheme.primary, isNotNull);
      expect(theme.colorScheme.secondary, isNotNull);
      expect(theme.colorScheme.tertiary, isNotNull);
      
      // Tertiary should be green (professional color)
      expect(theme.colorScheme.tertiary, const Color(0xFF2E7D32));
    });

    test('ProviderTheme should have compact layout settings', () {
      final theme = JinBeanProviderTheme.lightTheme;
      
      // Card theme should have smaller border radius
      final cardShape = theme.cardTheme.shape as RoundedRectangleBorder;
      final borderRadius = cardShape.borderRadius as BorderRadius;
      expect(borderRadius.topLeft.x, 12.0); // 12px border radius
      
      // Button theme should have compact padding
      final buttonStyle = theme.elevatedButtonTheme.style;
      expect(buttonStyle, isNotNull);
    });
  });
} 