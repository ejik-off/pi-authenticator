/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2025 NetKnights GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:privacyidea_authenticator/utils/app_info_utils.dart';

import '../../../utils/customization/theme_customization.dart';
import '../../model/enums/app_feature.dart';
import '../../model/enums/image_format.dart';
import '../../model/widget_image.dart';
import 'theme_extentions/app_dimensions.dart';

/// The central hub for application-wide customization.
/// It orchestrates branding (logos, names), technical metadata (support links, crash reporting),
/// visual styles (Themes), and layout metrics (Dimensions).
class ApplicationCustomization {
  /// Singleton-like access to the default branding configuration.
  static final defaultCustomization = ApplicationCustomization();

  static const _defaultAppName = 'EurasianBank Authenticator';
  static const _defaultWebsiteLink = 'https://eubank.kz/';
  static const _defaultCrashRecipient = 'app-crash@netknights.it';
  static const _defaultCrashSubjectPrefix =
      '($prefixVersionVariable) EurasianBank Authenticator >>>';
  static const _defaultFeedbackRecipient = 'vitkor.kuzmichev@eubank.kz';
  static const _defaultFeedbackSubjectPrefix =
      '($prefixVersionVariable) EurasianBank Authenticator >>> Feedback';

  /// Placeholder string used in subject prefixes to be replaced by the actual app version.
  static const prefixVersionVariable = '\$version';

  static const String defaultFontName = 'defaultFont';

  // --- Branding & Content ---

  /// The visible name of the application.
  final String appName;

  /// The URL used for 'About' sections or help links.
  final String websiteLink;

  /// Email address receiving automated or manual crash reports.
  final String crashRecipient;

  /// Template for the crash report email subject.
  final String rawCrashSubjectPrefix;

  /// Email address for user-driven feedback.
  final String feedbackRecipient;

  /// Template for the feedback email subject.
  final String rawFeedbackSubjectPrefix;

  // --- Typography ---

  /// The name of the font family used throughout the app.
  final String fontFamilyName;

  /// Raw binary data of a custom font file, if provided via JSON/API.
  final Uint8List? customFontBytes;

  // --- Imagery Assets ---

  /// Icon displayed in the primary AppBar.
  final WidgetImage appbarIcon;

  /// Image shown during the application's initial loading phase.
  final WidgetImage splashScreenImage;

  /// Optional background image for the main views.
  final WidgetImage? backgroundImage;

  /// Optional decorative image for the licenses/legal view.
  final WidgetImage? licensesViewImage;

  // --- Styling & Layout ---

  /// The light mode color configuration.
  final ThemeCustomization lightTheme;

  /// The dark mode color configuration.
  final ThemeCustomization darkTheme;

  /// Global spatial configuration (spacing, radii, icon sizes).
  /// This is injected into [ThemeCustomization] during theme generation.
  final AppDimensions dimensions;

  /// A set of features that are explicitly disabled for this specific build/customer.
  final Set<AppFeature> disabledFeatures;

  ApplicationCustomization({
    this.appName = _defaultAppName,
    this.websiteLink = _defaultWebsiteLink,
    this.crashRecipient = _defaultCrashRecipient,
    this.rawCrashSubjectPrefix = _defaultCrashSubjectPrefix,
    this.feedbackRecipient = _defaultFeedbackRecipient,
    this.rawFeedbackSubjectPrefix = _defaultFeedbackSubjectPrefix,
    this.fontFamilyName = defaultFontName,
    this.customFontBytes,
    WidgetImage? appbarIcon,
    WidgetImage? splashScreenImage,
    WidgetImage? Function()? backgroundImage,
    this.licensesViewImage,
    this.lightTheme = ThemeCustomization.defaultLightTheme,
    this.darkTheme = ThemeCustomization.defaultDarkTheme,
    this.dimensions = const AppDimensions(),
    this.disabledFeatures = const {},
  }) : appbarIcon =
           appbarIcon ??
           WidgetImage(
             imageFormat: ImageFormat.png,
             imageData: defaultIconUint8List,
             fileName: 'appbar_icon',
           ),
       splashScreenImage =
           splashScreenImage ??
           WidgetImage(
             imageFormat: ImageFormat.png,
             imageData: defaultImageUint8List,
             fileName: 'splash_screen_image',
           ),
       backgroundImage = backgroundImage != null ? backgroundImage() : null;

  /// Computed property that injects the current version into the crash subject string.
  String get crashSubjectPrefix => rawCrashSubjectPrefix.replaceAll(
    prefixVersionVariable,
    AppInfoUtils.currentVersionAndBuildNumber,
  );

  /// Computed property that injects the current version into the feedback subject string.
  String get feedbackSubjectPrefix => rawFeedbackSubjectPrefix.replaceAll(
    prefixVersionVariable,
    AppInfoUtils.currentVersionAndBuildNumber,
  );

  /// Generates a [ThemeData] for Light Mode.
  /// It merges color data, typography, and spatial [dimensions] into a single Flutter-compatible object.
  ThemeData generateLightTheme() => lightTheme.generateTheme(
    fontFamily: customFontBytes != null ? fontFamilyName : null,
    dimensions: dimensions,
  );

  /// Generates a [ThemeData] for Dark Mode.
  /// Ensures consistent [dimensions] are used even when colors switch to dark variants.
  ThemeData generateDarkTheme() => darkTheme.generateTheme(
    fontFamily: customFontBytes != null ? fontFamilyName : null,
    dimensions: dimensions,
  );

  /// Standard 'immutable update' pattern. Creates a new instance with updated values.
  /// This ensures that [dimensions] can be updated dynamically (e.g., via a 'Compact Mode' setting).
  ApplicationCustomization copyWith({
    String? appName,
    String? websiteLink,
    String? crashRecipient,
    String? crashSubjectPrefix,
    String? feedbackRecipient,
    String? feedbackSubjectPrefix,
    WidgetImage? appbarIcon,
    WidgetImage? splashScreenImage,
    WidgetImage? Function()? backgroundImage,
    WidgetImage? Function()? licensesViewImage,
    ThemeCustomization? lightTheme,
    ThemeCustomization? darkTheme,
    AppDimensions? dimensions,
    Set<AppFeature>? disabledFeatures,
  }) => ApplicationCustomization(
    appName: appName ?? this.appName,
    websiteLink: websiteLink ?? this.websiteLink,
    crashRecipient: crashRecipient ?? this.crashRecipient,
    rawCrashSubjectPrefix: crashSubjectPrefix ?? rawCrashSubjectPrefix,
    feedbackRecipient: feedbackRecipient ?? this.feedbackRecipient,
    rawFeedbackSubjectPrefix: feedbackSubjectPrefix ?? rawFeedbackSubjectPrefix,
    fontFamilyName: fontFamilyName,
    customFontBytes: customFontBytes,
    appbarIcon: appbarIcon ?? this.appbarIcon,
    splashScreenImage: splashScreenImage ?? this.splashScreenImage,
    backgroundImage: backgroundImage ?? () => this.backgroundImage,
    licensesViewImage: licensesViewImage != null
        ? licensesViewImage()
        : this.licensesViewImage,
    lightTheme: lightTheme ?? this.lightTheme,
    darkTheme: darkTheme ?? this.darkTheme,
    dimensions: dimensions ?? this.dimensions,
    disabledFeatures: disabledFeatures ?? this.disabledFeatures,
  );

  /// Equality check to ensure UI updates only trigger when customization data actually changes.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApplicationCustomization &&
          appName == other.appName &&
          websiteLink == other.websiteLink &&
          crashRecipient == other.crashRecipient &&
          rawCrashSubjectPrefix == other.rawCrashSubjectPrefix &&
          feedbackRecipient == other.feedbackRecipient &&
          rawFeedbackSubjectPrefix == other.rawFeedbackSubjectPrefix &&
          fontFamilyName == other.fontFamilyName &&
          customFontBytes == other.customFontBytes &&
          appbarIcon == other.appbarIcon &&
          splashScreenImage == other.splashScreenImage &&
          backgroundImage == other.backgroundImage &&
          licensesViewImage == other.licensesViewImage &&
          lightTheme == other.lightTheme &&
          darkTheme == other.darkTheme &&
          dimensions == other.dimensions &&
          disabledFeatures == other.disabledFeatures;

  @override
  int get hashCode => Object.hashAll([
    appName,
    websiteLink,
    crashRecipient,
    rawCrashSubjectPrefix,
    feedbackRecipient,
    rawFeedbackSubjectPrefix,
    fontFamilyName,
    customFontBytes,
    appbarIcon,
    splashScreenImage,
    backgroundImage,
    licensesViewImage,
    lightTheme,
    darkTheme,
    dimensions,
    disabledFeatures,
  ]);

  /// Handles the dynamic loading of custom fonts into the Flutter engine.
  Future<void> loadFonts() async {
    if (customFontBytes == null) return;
    var fontLoader = FontLoader(fontFamilyName);
    final byteData = ByteData.view(customFontBytes!.buffer);
    fontLoader.addFont(Future.value(byteData));
    await fontLoader.load();
  }

  /// Deserialization from JSON.
  /// Falls back to default NetKnights values if specific keys are missing.
  factory ApplicationCustomization.fromJson(
    Map<String, dynamic> json,
  ) => ApplicationCustomization(
    appName: json['appName'] as String? ?? _defaultAppName,
    websiteLink: json['websiteLink'] as String? ?? _defaultWebsiteLink,
    crashRecipient: json['crashRecipient'] as String? ?? _defaultCrashRecipient,
    rawCrashSubjectPrefix:
        json['crashSubjectPrefix'] as String? ?? _defaultCrashSubjectPrefix,
    feedbackRecipient:
        json['feedbackRecipient'] as String? ?? _defaultFeedbackRecipient,
    rawFeedbackSubjectPrefix:
        json['feedbackSubjectPrefix'] as String? ??
        _defaultFeedbackSubjectPrefix,
    customFontBytes: json['customFontBytes'] != null
        ? base64Decode(json['customFontBytes'] as String)
        : null,
    fontFamilyName: json['fontFamilyName'] as String? ?? defaultFontName,
    appbarIcon: json['appbarIcon'] != null
        ? WidgetImage.fromJson(json['appbarIcon'] as Map<String, dynamic>)
        : null,
    splashScreenImage: json['splashScreenImage'] != null
        ? WidgetImage.fromJson(
            json['splashScreenImage'] as Map<String, dynamic>,
          )
        : null,
    backgroundImage: json.containsKey('backgroundImage')
        ? () => WidgetImage.fromJson(
            json['backgroundImage'] as Map<String, dynamic>,
          )
        : null,
    licensesViewImage: json['licensesViewImage'] != null
        ? WidgetImage.fromJson(
            json['licensesViewImage'] as Map<String, dynamic>,
          )
        : null,
    lightTheme: json['lightTheme'] != null
        ? ThemeCustomization.fromJson(
            json['lightTheme'] as Map<String, dynamic>,
          )
        : ThemeCustomization.defaultLightTheme,
    darkTheme: json['darkTheme'] != null
        ? ThemeCustomization.fromJson(json['darkTheme'] as Map<String, dynamic>)
        : ThemeCustomization.defaultDarkTheme,
    dimensions: json['dimensions'] != null
        ? AppDimensions.fromJson(json['dimensions'] as Map<String, dynamic>)
        : const AppDimensions(),
    disabledFeatures: json['disabledFeatures'] != null
        ? (json['disabledFeatures'] as List<dynamic>)
              .map((e) => AppFeature.values.byName(e as String))
              .toSet()
        : {},
  );

  /// Serialization to JSON.
  /// Includes the [dimensions] object to ensure layout settings are persisted or transmitted correctly.
  Map<String, dynamic> toJson() => {
    'appName': appName,
    'websiteLink': websiteLink,
    'crashRecipient': crashRecipient,
    'crashSubjectPrefix': rawCrashSubjectPrefix,
    'feedbackRecipient': feedbackRecipient,
    'feedbackSubjectPrefix': rawFeedbackSubjectPrefix,
    'fontFamilyName': fontFamilyName,
    'customFontBytes': customFontBytes != null
        ? base64Encode(customFontBytes!)
        : null,
    'appbarIcon': appbarIcon.toJson(),
    'splashScreenImage': splashScreenImage.toJson(),
    if (backgroundImage != null) 'backgroundImage': backgroundImage?.toJson(),
    if (licensesViewImage != null)
      'licensesViewImage': licensesViewImage?.toJson(),
    'lightTheme': lightTheme.toJson(),
    'darkTheme': darkTheme.toJson(),
    'dimensions': dimensions.toJson(),
    'disabledFeatures': disabledFeatures.map((e) => e.name).toList(),
  };
}

final Uint8List defaultIconUint8List = base64Decode(
  "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",
);
final Uint8List defaultImageUint8List = base64Decode(
  "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==",
);
