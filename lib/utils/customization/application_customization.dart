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
  "iVBORw0KGgoAAAANSUhEUgAAAO4AAADpCAYAAAAj6wuaAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAD/TSURBVHhe7Z13nBxHmfe/Vd0TN+8qy7ZkOWPjbOAO7AMDB37NgTk44I50x3tgG2PALzncEc93R7iDIxpbjodtMCY44SAHWXK2ZVmykpVz2BwmdnfV+0fV7I5WmyTt7vSs+uvPWLs9szM93fWr56mnnnpKzJ8/XxMREVFVyMEHIiIiwk8k3IiIKiQSbkREFRIJNyKiComEGxFRhUTCjYioQiLhRkRUIZFwIyKqkEi4ERFVSCTciIgqJBJuREQVEgk3IqIKiYQbEVGFRMKNiKhCIuFGRFQhkXAjIqqQSLgREVVIJNyIiCokEm5ERBUSCTciogqJhBsRUYVEwo2IqEIi4UZEVCGRcCMiqpBIuBERVUgk3IiIKiQSbkREFRIJNyKiComEGxFRhUTCjYioQiLhRkRUISLaHzc8iLKfBOW3RQw8N/CiYRjtBaPc7rKnddkvuv99y49GVIpIuBOMsFqQJfFpe7mlBK0x/4mqk4Po71wEQgBKowApBVqbnwekHjHeRMI9TEzjNI1YIFBaIwEtQA1+8QgIIKYlCeEQxyGO/VlL4kKSxCUtYqRwcJE4CCQCV5ifHQRSm98lgpg9rmzn4KFRaHytUEITYB6+Vua4/b1AQEZ75PEp6IAiiqJQ9ueAoja/H0xHIxBIK2YpTCdlLPjBvEtEOZFwDwJReggj15JlGYmkltSLOA0iQQNx6kWCRuI0iyRNMkETSZpFgrRwiSH7H3Hh2H9d87MYCEcc6AwfeIQxWbz9nyn/LdBWrP2CDfDQeDrAQ5ETPh1Bnk4KdFKgQxfo1gW6ddH8S5EeXaQgghGvkRx0PfUBZxUxFJFwR0CWebZYSzEYB0GdjtEoE8wSaWaTZo6sZaZIMUukmSFqSFoLmnRcksLFFRIFKLQVv3mUOgKN7reUyj6vGa1FH/hkuSAOZGixlw6bTkrgCOMUy9K/9n2N62/+lQIkEl8HFHRAXnkUtSJPQJvOs0dn2KOz7FYZdpNhl8rQRYEe7RGIA89NIPovvBDmmx34qiObSLhlmAYKSmn0EO06pgVzRC1Hy1pOFI2c4DQyU6RpIUmzkySOgyskrpAE2rihHoEVIQR6wPqIkqBEWeBpPzmZn8ot/GRTsoD2t7L/lx2x36F0QApwhJG1FMZ1dyldE4WPoqgCOlSONp2nVefYoLpZr7vZqnrYRZYCQdmnGBwhQcPI9vvI4YgXrrEgplENZg5pTpJNHCvqOVE2Mk/WMU2kaHZSdlSr8VF4WuGpwI7dLFoj+kVZeRFOFmo/6166HuZamauhzRhcmrG6awUphKBL5WhTebbpXtarLjaqbl5RXewkQ1DWZQjM9ZVCDngjRxhHpHBLLvBgq9qk45wkmzjHmc7pchoLRANNbpKYcPC0wteKovbxVMkimIiqAGTZGDRidJRWxgUuE7orHOLSjOdjwsHXiu4gzxbdy8qgjRdVK6tVB63k9xOrsEb/wK536nLECLd/3DRorHoiDbzOmcVZcjrHywZmurXEEHho8srH0wNum7CPSKQTQ2lcT5lLHhOShDSBO4WmLcixPujkJd3GM/5eVtPZb41L9/hIEPGUF66RmMD074ajqeUCZzYXyLmc7DTT4CbxtSKvPYrKNAMjUjNOi6gcJTGX7l5cOiSFS0xIMkGRV4IulgS7WKx2sln39AtW2qhW+X2fSkxZ4Tp2XFW6kU0k+Cs5hze5c3m1nEaTm8JTiqwq9o+TZGRNQ08pyl7yftIyTkI6dPl51qhOFgc7eTTYwV5yMEoMo5qZcsItyU7bxxxquMQ9lovc+Rzl1uGpgLz28eyNNNMZkVWtRkpTadp21CkZIyEd9voZHvK2cWewkc30Qlm7mCrynTLCLbm2JdfoJBp4b+wE3ujMZbpbQ19QoKgDQCOQkVinGEoPzInHhUOdm6A7yLPE38kd/kZW6nYr8FIkurqb/ZQQroPoD1AcTQ2fiJ3GG92jqJFxeoMCPipyg48gSu60g6DeSVLUPk94u/iV9zLr6LapI9U9/q164Uph8nGT2uHvnRP4YPwkmp003UEehckbjgR7ZKK0RgmN0NDgJMmqIncUN3Cjv4Ye4SHtMolqtL5VK1xZNl65QMzm8tirOSXeQrdfwNMBrpBTPtkhYuz4OsBB0ugm2eR1c52/ivuDrXYGQaKqbPRblcItucZxLflM7Az+PnEyBeWRUR6OiMavEUNTcqGTwqHGSXBvYSP/WVxGj/BwhCAYMqc7nFSdcEsXeC41fDP+Gs6Lz6YjyIHWJp81ImIUApu11eykWOd38I3C02bsqzW6Sjr9qmrpjoZAa/5SzGJh8kLOjM2g3c8itU1Cj4gYA45dCNLuZznWaeCXqQu5SB6DFmZdczVIt2pau9AQCLhIHsOP0hdQK+L0+PloLBtxyMSkQ19QxNGCq9Ov50PyRAJ0VQy1qkK4DgIt4K3yaP418VpygUdBB7jSGfzSiIiDwpUSH0VXkOeq1Nm8Tx5HoDUi5OPd0AvXQRKgeZOcy7cSr6VIQIA2y8EiIsYBs9ZX0xPk+WLqXP5WLuh3m8NKqFu/iR4rzhbT+Hb8tfhaEWgVjWcjxh0pJBroC4p8JXUeF8q5BGickEoknGdl0xcDNPU6xpfi5xCTLl4k2ogJxLEL84s64Avxc5ij0wQ26y5shPGcAFMzAeAzsTM4MdZMRhVxZWhPN2KK4AhJLvCY4aT5YvxsJGK/UrNhIZRKcOzFuljO45LE8XR4uWhMGzFpxKRDV5DnjYmj+aBzAthVZGEidGoQQICmlhj/HD+Vgg76a5FFREwWEuhVRT4SO4U5pPereRUGQifc0oKAdznHMt9tIBsUo3FtxKQjhaSoAqY5ad7vhs/qhkoRAkGgFfU6xntjx5NVJoc0IqISSAR9ushFzjyOpqZ/tVkYCMt5ALZOEPBOdwHHuo3klR8tyYuoGFIIiipgRqyG97rHgzUuYSBUqijVBbrQOYqC9kNyiSKOZCSQVR7nu3OpF3GC/vrQlSVUwgU4WTRxvGOsbRguUMSRjRSSvPI5yqnjNJrMscEvqgBhOIf9eIOcTb0Tx1dBVSR7R0x9tNbEhOR8Z445EIJmGSrhCuC1zkyKWkUrfiJCgxSCnPI515lFWjtmEcLgF00yoRLuTNLME3UUIjc5IkRIISnqgDlOmmNEHYTA6IZKuHNkDQ1OEk9HbnJEuFBakRAuxzr1YPeeqiShEu7xooGYkBW/KBERg9FATDjMF0a4lSZUwl0g680GykeqsRUCHGkeYboG0p6XtFsTHolo8LRivnWVK91IQyXcOaKmf2uQIwIhQFqhArroo7oyqK4M2jtwc+dKoLVGZQqozj5UpoAO1BEpZCHA14rZoqZ/b+RKEqoqj9fFL+Q0dxpZNUXzk4WwD0BpdNFHFz3wFaImgTunmfjpR5M85zjiZ89HphOgdGXFIcDb3Erh6Q0UXtqCt34PQWcGggDiMWTCBdeWENLanO8UJNCKlIyxw+/lA4UHCISJLFfq24ZKuLcl/pp5TgMF5U2NVEcBCOv2aivUgg9BgEjGceY0kXjVUSTOXUDi7GOJnzwHkU4MfpfwoDTBrk7yy7dQeGEzhWWb8bbsQ3X22UGgi0zG+j2IqSRkpRUJ6dKqcvxD7gEywmT2VerbhUq4dyUuplkm8bSqzqiyKLOqSqP9AJ33IFCIuIszq5H4yXNInHecEeopc5D16f4NtwG00vb3cOTFanT/1odi0NhbBxp/ayvFFVvJP7OB4spteJv2ofryoDQiGUPE3QEhl75bFaK0IiZduoM8Hy0soo18RV3mUAn3keQl1eciSytUrdFegC76UPSNUKfVEztlDomzjyVx3nHET5mL01y7/98rjVYKhECU3iusaCNibd13IQcJuejjb22jsGwThec3UXhpK/72dlRvDqRExN1BQlaVM1kHidIKVzhktcfH8g+zkwyygtt2hkq4DycvCXeli3KLqjUECpX3wAvAkTjT64kfN9O4vucsIH76MTjTbBSyhDLbQQLhF+pYGOH76KKPt34PhRc3k39uI8WXt+PvaEdniiAFImEtsjS7x5uOITTNcT/Khft/8w+zIxLuAH9O/A21Mk4QxpRH6/6qggdF3wi1qYbYCbNInDGP5GtPIHbqUbizm/YPJmltIrHVYFEPFys8Y5GFca2xA0EBKlvAe2U3hWWbKTy3ieLqHfg7O9D5IjhyQMghHBcrrYgJh15d5B/zi/p3vK8UoRLunxIX0xLGMa4U6KKPcB1iJ8wmcdZ8EuceS+LM+TizmwYaKIMCMlKYFhuirzKpWCuqlTadltz/QqjeHN663cYaL9tM4eXt+Pt6TIArZJa3fIz7kcIi2qMx7gC/i7+d2W4txTAtoJcSnS/izG5kxi8/TvzUo/otCGDcRCtUIczrI4bBXiuN7c9K10qb/6mCT9f376bnV4uQjTUQVMoRPRClFXHp0h7k+FD+QXqEV1HhhqqVeahQRFL7EQLtB4i4y7T/+ogRbWleVSm054PWCEcaqxuJdmSESdwQjkRIiQ6UmSKzwTmZjNH89XdTc/HZZq7YDdf1FIASppihoTKiJWzCLaLCJFsQoPNFWr7zPpLnHQdao3rz5J9Yh/YUIuYaq6FMoCps7l1oCRQo2+HFXRCC/FOvEOzpAiFo+Y+/J3HmPFRPfiACHQoESmv8Cgq2RJiuCgV8ZH8p9ArjSlRXhsYr307Ne15rAkwaZEOK4uqd7Hr71fT86mH8bW0DKYBgXqfC4+KFA+si+3b6x6ZLBvu66f31UnZf9O/kHl2NM6sRHShkYw3Tf/RRnBn16IJ3wNi4EpRGRz4BPiYdtZLtNFTC7cZUdazkBQEj2qAjQ827zqPxc+8YCK7YgFn9xy/EndtM25duZfclP6D1iuvJLVqJKvj9LrNWNpp8RFthcw200mb6x5XoICD/5Dravvi/7P6b79H22ZsAaPz8O6A0pRQoYsfPYtr3P2SGTjYqX2mkEPToIkHlTwWnsbHxm4MPVorXiBmcFptmqztW6Oo4EtWbI3nWsUz/+cfMFAV2fCasmycFTl2K3KKVIKC4cjuZu18g9+BKgrZenBn1OC21phEi0EqZbRtDYDkmBWUDdlIipEAIgb+9nb7bn6Tzu3+g55eLKL60tT/i3vjpi0iccyw6UGboIQX4itiCGcjGNNn7X0Kk4hXtBBWalHRZG3TwoNpe8SFdqIR7hpzGue5MssqrjHClQBc83BkNzLjuE7gzG20DLDsXYUQsHEnmT8+jiz4ynUDEYwTtveSfWEv2Ty9QeHELQkqcOU1mekPa7CqljfGoxPebSLRGB7aki5360XmP/ONr6PrRfXR9726yD7yE6uhDpOJGiJjrWX/FX+PObjKDpNJ1sZY3ceZ8E1dYuhZRk6iYeDWalIyzImhjsdqFjFzlAbp0AUWF6vkI65JJybQffpjYsTP6reuQSGn+RttpDptJBYKgrYe+O59h7z/9gl1vv5rOq/9Ace0uI3j7dwOu9OA3ri60smN6IRCOEay3uZWuH93H7ov/gz3/8BN6b1mCv7vLqLRkjbXub/qlK3zApZDm+jZ/7d2k33YGqitTsWCVtq5yty4AICo8XRkqiztP1HGBexR5XQFXWQpUX4GW776fmovPAl8NPR2hjVUort1F321PIpIxs5DAVyTOPpb0284g+fqTSJw0B1mfQnVmyD38Mr03P05u8Rp0rogzqxGnPjUlLK+xsJKgrZfs3S/Q8d3f0/ndO8k/vgZiLvFT55J+46mkLzyV5FnzEak4wY4OdMFHpBPonjypC04mftIcE2nez7uxqaWOJHn+yeQfX4O/pwuRmPwEDYWmVsZZ7O/kRdWG1BpdwVsXqgSMC+QcfpA6n76gMLmLDRyJ6uij4ZNvpelrf2vGWsP07KXn2r92O72/XopwJe7R02j5zvtJvv7EA4QYdPQR7OkyyfcrtuKt2w1A/NSjjMDPmDfgNpaj9WS3zWEZroPRRZ/iqh3kn1hHccU2VMEjdvxMEmfMxz12Bu7sBpyWuoG/tZ1e4aWtdPzLbyis3I6QgtQbT2XGwksPHJZYSte8uHYne/7hJ+i+/KSnRgZa0eSk+G7+Ge4MNuFoKhqkCpVwT6aRG9JvJT+Z63EdM+2TfvuZzLjm47aRlY21yrENq7hqB3s//FOCtl4Srz6GGQsvxZnVaJIy7NUUwrp6Qzj+uujh7+xEdWeRDWli86ZVZfKGv62doL0XWZfEnds8dAeESVbBrg4UwrjTqjdH2ycXkn1sNbI2yfRrPkHqgpOH7zQDBY4kt2gl+y67zs7/DuVfTwyBVtTIOF/IL+VxtQtHCIIK9qyhEu4MUtyceAs1Mo4/GfnKjkT15YmfMpdZt15p0uysVRgKrTVCCPb98zVk/vgcydeewPSFl+LOajQZVq48UKilpPsyhmyYg9AFzyTg5zwTfE24iLgNcgkxvkviBAML/pXNZsr7oBUiHsOd2zSmBf56UIqiESkHXBPtK4Rrovetly0k+8BykuefwqxbrxyIHg9xD0qi7ln4CB3f/N2kp0VKBB/LLWI93RVdGUTYhJvUkoWJN3Oc22h36hu9gR8yduGArE8x67ZPEzththHDMJav1Ggydz7D3kuvJXnuAmZefznOnKbhrcRwlHpqXRJNWSO1x1SuiL9pL4XlW02liTW78Ha0oTMF0NpMU8VcMw4X1hsYswWwCf82pRMvMIkOGkQqjju3idhJc0mcNc8s+D9+FqI2OfhNbFDO/jz4e4xC6Zqp7hytl19H5t5ltFz9ARqueNuI17N/qPL139B742PIptoJF6/SGldI+rTHP+QfoJNCRfOUCZtwAX4Su4C/iM+hO8hP/NrcIGD6Lz9O6k2n9rtiQ2ItQNDWw663/BuyIc3MX1+Je1TzyH83juhswdR+Wr6FwvItFFdsw9/ZYSKtVnAiERs9a0tKY1FzRdAaWZ/GndNE/LSjiZ85j+RZx+IumIGsTw3+y/HHDj1Ud5Z9//RLCi9uZs6DXyN2wqxhx7ule6H9gH0f/Tn5J9Yh6lITKt5AK9Iyxvqgi/+bf5iiMKm5lRRO6IT7r7HzuCR+PJ1+FlfaImTjjSNRnX00XPl2mr70rtHFZ59v/cyN5JeuZfZdX8SdO8Gi1SXLbE3woEas/QB/cyvFl7dTWLaZ3JI1eJv3IWuSdhplqNtqxpbu3GZS559M4twFxE87mtjxs8yYsRxV+mxrSQ/Cmh4MWpmkC9WdZfd7/xunMc2sO64a1l2GAcF7m/ex573/jerLI1xnmO98+Pha0egkeby4g6u8pRW3toRtOgjgBNHAa9xZ5CYqQCVMYkDs+FlM+96HEMnYyG6eFWf2wRX03bKE2XdchXvMtBHduYNmqEZaOqfSoxRltnO/wnVwWmqJnzyX1IWnUvve1yEbasg/+Yr5cyEPMAk679Fw2VuZ/t8foead5xB/1VE4MxoQjjTzsXYeWmADa+WfP5ihzvkQEEKgA4VMxal5x9n03vQ4wpEkzphnM6mG+AxrcZ2WOpzGGpNZlXAP+L7jhUZT48R4LtjLErUbYfvSSjJOLW/82Kb6wN7QCUEKdK5I+s2nIRvTJvF9uM/SZg5RZQr03fEU06/9BO786eMr2rFiK2gI1zGfrbUJJCllGn46TsNlb2Haf37QVOgoRwpUJk/TVy+h6cvvQjakTdK/Mu+B1ggpzXuXBDsqY3nN2BCOBKVwmmuZecsV5B5Zhb+zY+B7DoFwjIWtfe9rSZxxDDpbOMArGS+0zRnZFvQCIIeJg0wmlT+DQeygj15l5nHVMDftsNAaEXdJnDnf/D6Ge517eCUNn3gLidOPGV/R2q8X7OsxY86yY6MiTDF1Yde3aowVqrnkXGr+9jWonlz/KhydKZB646nU//OFJmMLm/Tv2DXEYxJqGUrj72g3P4/XPbLrc925zTR+8Z3klqy1TwxzbsIWrXMkNX9zDtoboQM+TIQwCRgbdLc5MF7f+TAYpxY4fuzQfXTqPDEhD6IVHwTaNBI5VJR0MMJY58TZC0icd5zJMx4v0WIbX65I5u7nTWDJHjsUSsn8ADXvPBcRd4yZEALtK2reda55oTLW9ZDRxoJnH34Z1ZkxrXqcGnLJZY+fPIfUBaeY6pBiBKHYa5U4ZwEiNjFjXBNRdugKcuwmA9Z1rjSHcQcnhh489qgcrnAm5vIIM1epMibndDTM9Ejzgel4h4uN/uYWr8F7ZY+xjIcbGbXnlzj9GDO37AXgBzgttSTOmAdW4IeFPW/V1kPm7hcAa/nGCSGNe+zObkTW2cj2sJbUHBepuNlNYQKEq9HEhcM+nWO3ytpjlSdUwpX2RmxQXdbiTgDCzN8WV+8wv4/pZg8zNXE42MbYe8OjODMbBj97aNj3lA1p3GNngB+gfYUzqxF33vT9XnOolK6We8w0em5YbIYe4+mFcDDnaM5GtfWYLVEO1V0ZAQ24QrJHZygKVfFVQSXG+YofHsKKaLPusSH3CcCOcfNPvWJ+Lu17MxJjbkhjxK6mKTy/iexjq4mdPGfwKw6ZktWOnzLXWNxAETthlsnqUrZe1mFQ+nN3/nS8dTvJ3L3MHDhcb2EwY7nm1tLnlq4zW7uMd+dqv68rJOuVGd9OWND0IAmVcEs3a7PqNmtyBz8/HiiNqElQeH4j2fuWm2Pj3ehGxXzPnusfBQ3OjHGyuGXETpyNiDtozzdF7qC/cPlhYe+R01KHqEvRc8OjA/PZ4/H+Y0WZTtfbuJe+O58xa3XH0WUvR2nFBtVlfp6gzzhYJkQbh0pJPutVNx1Blph0JyayDCAk3b94sL8Y98SY9yGwyQOF5zeRfWgF7uxGnIYaGKfevPQe8VOP6t/yI37i7MEvO3TsKTottTjT6sg/u5HM/S/BOI91x0rnv/+RYE+3SSAZ57ZSCkx1Bvkyizv4VZUhVMItRet6hMdG3UNSuKiJUFTJ6r60lb7fPQOADiZ3P9reGxejMgVkfRrZbIR7uG4sDLyHO7fZWMVknNjJc81T49LqzHvIuhSyPo3Q0Hvz4+aZyeoA/QCkoPe2J8g+uALZmJ4Qr6kUmNqtM2zH5BdMxtcbC6ESLmCyUoA1QQeOmMAqy0ojUnG6f/GQmex37fTJcGgbyCo9DoWStV22mezDK5GpBCIdRzZZ4Y7Ht7XTM7IhjXt0C870OtxS8Gsc3h5hr4XdK0kkYxSe20h20Urz/Gi50sMxxuurAwWug/fKbrp+eI+JKI903w6ThHRYqzoJ0OGpQBpG4ZaW8q1UHfgTuTu9XWHj7+ig/Qv/O1AGdLhGI6wo7PnpwGQsaZt5NBZKY8zemxajbMKF01I3kCE0HsIqc1ndY1qIHTcLSimN42JxrcAAZ2a9EZKA3hseM0+VhD0a2uxSWLqOYFMoy67xASiT/BLs7aL1ioUEHRmzQmqM1/9g0TbNdE3Q0f97WAidcEvu8mbdTbufIyaciRvnBgpZnyL3+Fo6vnWnOTZM76368ngb9uDv6jTWuqwiP5j1sTqw+b56YE9ZtH1PL0A4ktziNWT+vBxZl0L7Ps6MevMBQ3/sYRE/fR6xk+z4dhz7wFIDdlrqwAuQdSnyT6yj73fPmB0KfH//61iyoiWRKpsTXZb5hYZgbzfe+j2objNfuh/KVI1UfXlaP3k9xVf2IGsSh27hx4AUkqwuslKZLLHh+pNKELpFBqXb3YvHBc5sjnLrKU5kDSqtEekEhWc3IBvTJM5ZYOpNDZpaEDEH1Veg8MQ6+n77FLnFa1DZIiIZQ6bjA3m+/cn5JStt38CR+Ls7afvMTajOPmQihs4WSZy7gPSbX22++Dh9R4F9Lz/AndmIO28aYIoAjAt2RU/xhc3klq5F1iTQWlN4YRPpC04xUfLy71OyonJgx0IdKII9XeSf3kDfrUvJPrgC1ZXBPXqace3Lr782QwztBbRdcT25x9dM2Li2RKAVKRljZ9DHLcEreJjOJiyETrhAf1H0eaKOc2MzyQUTtFKoH42Ix8g9tpr4cbPMvGowSLxC4DSkiL/6GOKvnoe/eR9dP7qX7p89SO6hlRSWbcbf0WEKxznSbE9iE+GD9l6yD75E22dvJtjZ0V/lQQcKpzZJ7XtfayziuM1Dmo7DaUjjHtViOhXGr2NAmwysvt88hbdul1nU70h0X4HM3S8g0wnc2Q1mjbAUqIJH0NZHcfVOcg+/TN+tS+n+6QN0ff8ucg+/TOKsY6n/5wtJnX8KTnPN/sUMrLsqhKD9C78m86fnkS2TsXheUeskWOLv5iG1DQcxMYHSQyR063EBHAQBmteImfw09Vf0qeLEVsPAiEb7AUIIZlx7Kck3nHRgpceSCyyMCHRvjp4bF9P9i4cI9nQhapOIRAzZkEam4zjT6yFQeDs6UO294Dpm+VkpEUJpcB1m3fpp4q8+2myQ7Trj27GbVj/46KFh3V1cB39nJ3ve80OCzszAWli73E4XPJzm2v46VMG+blSmgOrJoXNFdKaAbExT/7E3Uf+Jt+BMr7Oulr2+pQ5MD1jbjm/fSc81i5DNEy9aAF8FNMXSfD33JPcFWyteY2owobS4JXoo8lbnaOplAl8bUU0Y2iwV035A7qGVJP/yJNzZZi+b/vzessCJVia4lXztCaTfeS6qM4O3aa8JlvgBqjtLsKsLf283+AEiGTN1h8vvvSPROY/Csk2k/upVJrpcKppe+rzDQdNvfQ+L/rpZZkVR0NFH+2dvMtZ20F62wpGIhIsueAR7uwl2dqD68qZYujD1ptJvPo0Zv/o4Ne9+DTIdH/i+pWEGVsM2GNX1o/vo/skDkyZapTUx6dCrClznraKbIqJ0OUNCaIUrgQKK00ULJ7vNE7ewvhytETEXncmTe3QVqTefhtNcu794MYIS0ohQK43TWEPNO87GPXoahec3oroyyLoUwpWImNOfOH8AGkTcwd/TTfbeZcjGGmInzTEWzI4D0Yex84E4jGFZSayltbrSTM1lH1xB26dvpLByO7J2mGwl60oL1ySAiEQMskVEKkbTly+h+RvvwZnRYK6r7QwGfz8dBAjXoefGx+i8+o/9a4gnA4Um7cRZHbTz68AUJpicTx474RWuNlMLdcR4U+zoySuSbqeJVEcf+aXrSL/tDLNKZajplJKAldk2Mn7qUdS8/UyKa3bhrd1px7LW3RsODSIeQ2XyZP/8IvlHVoHSuLObkHXJgYXt9jOM1R/8JuOENoEnXS5WKVCdGTJ/Xk7HN+6g55qHUX15ZHoY0Q5GSFRnhvhpRzHj2ktJ//Xp/XP1QwkWTIKFcB0yf3iOjq/ebqLHE/alD0ShqXMS3OVt4gXViiNkKJbylRPKMS7W4ipgvqjj+sSbce3C+gl1l8txJKonS+LsBcy88XJkQ9q4dMMFkEourmOKsXV9/266r33YBmiGsbjlCFPKVGWKUPRxZjeSfMPJ1LzjbJKvO8E2XkNpIUG/qA+HcstaJiRd8Ck8v5HMPcvILV6Dv70dXGnOY7TOiAEPQfXkqH3fX9D8zffYKTBlhgzDnLcpc+uQe/hl9l1+nTknxy6QmCSUjSh/KvcYz+vW/phLmAitcEWZe/LL+Bs5OzZz8nc4cI21SF14GjOu+fjAeG6YRgfGYqGN8Pt++zTtX70NXIlw3bHNOdryNLroo7IFcCTxBTNJvfFVpN92BvEz5w2saLIWEsGwZWWHxYp1v3Gl0hRX7yD74Apyj7xMcd1udNE32V1xFx3YUjejIYRJXsgUaPryu2i4/K2gtLHkIy0BtMHAwrMb2PuxX6K9wCyQn0TRlqaBtvrdfLTwMAURhG58S5iFC+AISaAVH3FO4qrU2XR4E1j5cThcB9XeS83fvoZpP/7HAc2OJF471SNch+yfl9N21c0m0JJwIRjhctsWojJ540LbjCqV99C5IiIRI37SbFJvOZ2a/3Mm8dOPsfvoHLonqf3AiPX+l8g9uILiqh2obMFM8aTiRtjWwsuahOkgRrK2tiCAznu0fPf91H3wDcbKygMrVe5HYFYYFVftYO9Hf47qzthysyN81gQQaEWTm+Lm/Gr+23+pvw2GjVALt+QuL6CehYkLkdK4y5My1i3HlQTtfdT/0xtp+e77jQjF8O6ewezALlyH3JI1tF5xAzpbMGIYKjIqMBZNa9JvPo3Eucfhzm0aEG5PDn9HO97m1v4dDpzpdSTPO47kBacQP2WuKcczkjgwVlXlinjr95BfsobcU+vNVFbMwZnTRGz+DNxjWnAaayBp5meDvV0UXtxC9oEVaM8fPs3QJkmgNNN+8CFq3nXuQGBvhGulbR0vb2srez/0MzPXXZMY+jpNMKaGcpxP5x7jWb0PGbL52xKhFm45FXOXS9hazI1XXUzj594xsAZ1NOzrCi9sovWy6/A7+kxgZ6hGqTTTfvBh0u84a1SXXGULqNYe/F12D6LGWiPehtTQFrg0z5opUFy7k6CtD1mTwJnThDOj3ljT4T7P/m3+qfW0Xn6dTTIZYmqr4CFiDtP/559Ivfm0sV0jZdz1oLWHvR/+GcW1u5B1yaGvzwRTcpO3BT38Y34RuZC6yYQ5qlyiFNFrJsEbYnPIVWy3erOaKLd4NbIhReKcBQdOEw2FtKmHR7WYrSIfXW02dy7fKtJu8Zn6q1No/MLf2GkgUxFE67IVM/YhhEDEXWRjDe7RLcSOn4V7VLMZgzOEaBlw7UXcxZ3TROz4mbjHTMNpqrEbaAm71+2Bn1caS8fmTTO7Dr6wCZEq22RaCrNtZm2CGdd8gtQFp5ild6NVF7GiVX15Wj/+KwrLt5hpnwqIFhuUqnMT/NnbyuPabOxVmTMZnVG6w8qj7fjiKbWHLmttJ2zRwUhoY3lkXYqO7/yevjueNhFkfwzreF0HHSjip8xlxs1X4M5psnWA7eUXdileS535FTu+LS1kGPQAKyg1sMKmX3BjofR3g4RanvQ/+FESvjOjwYzTS51DaQ+mmjgzF15G8i9OMNdkLKK19b/arryB/DPrTf7xWK7nBCGEoKgDFgelemSDXxEeQi9cZRvyet3Ny0EbaRmr3JhDG5GJVJz2r95O9sEVJsI7hkX4wpHgK2ILZjD95x9D1CTRRVsnyUZb/S37zItHixCXxtdyYIXNftHh0Sj9nSz7u1H+tjQN563fDTFpb4zon0qa9l8fIXH2sf3TOSPS38Fo2r/wa7IPrTCbd/mVs2+lse16v5Plqg0w87lhZZQWEhLs9Xsw2I7DKFHNiaY0pSEFbVfdTP6p9WBTJUfFNRY6fvo8pv/Xh21ShXWLk3GKq3ZQXL3T9FSTHE0dEW1cWn9XJ4XnNyGSpa0wQWfyNH/z70hdeNoYRYtx/6Wg41/voO93T1vRjuH6TSDaLpp/1N+BL7QdooWX6hCu7e2XBLvY5feScGKoSobolU2NLPq0fup6iqu2W8s7+jkJ14g89ZZX0/zN96L6bH1nu19s321PmN8r2TkNxnYimd8/i7+r04yJpUB1ZWn89EVmysdOf42Ixuy5KyVdP7iHnhsem7T845FQWhMTkk4/x2PBTigbooWVqhCutmVDOinwlNpDjYxVZpxbjlKIZAzVlaH10oX429pMBHUMjbAk8roPnU/jpy/qXzgua5P0/fE5vLW7Jj1baFi02eYjaOul99YnEGkzt6s6+qj7+780EXa7GGBUlNl/uOe6R+j68X0TvqZ2rCg0aRnjJdXGRnqMwzP4RSFjDFc7XDwUbKOoJnil0FgJFKImgbejnX2fuJagtdcKbgy3XZpyMo2ffwe1H/gLVJdJOFBdGbqvfRhsh1VpSmVwem98DH9rKzKdQHVljMfwbx8wZnQM90L7gckmu+NpOr/7B2R9OlTBH4Fgkb8doEKzFgdH1Qi31IiXBa2sCzqoceLhyGjxFbIuSXH1Tlovv87sdyPHYC2FaSwALd/9AMnzjifoziIba8jc+yKFl7aa4NFYOoGJwuZe+9va6L3tSWR9CtWXJ7ZgJtN++GHjMtsg1UiUxr7ZB1bQ/pXbjNUmHMMBpRVJ6bLD7+WJYLc9NvhV4aOKhGvmdH2hud/fRlyMMp6aTAKFbEyRf2Y9bZ++caCq/mgN064sEskYLVd/AKc+ZaZqcgV6rllkXzSyKCYUe/491z9GsK8bYmaRf/O334czrc5MQ402j22zx/JPvkLbVTeB44zt2kwSShs3+dFgB12iaKuvhOPcRqJqhIu9yACLgm3s8nqJS6eyQapyfIVsqiH74Arav/Rr0zD1GKyKlGhfETt5Dk1ffCeqJ4dsSJtE/yfWmXnSSlhdZca2xQ176LvzGWRDGtWRoeGyt5I6/+T+NMWR0IFdNLByG62fut6mS47BG5kklNa40qE7yHNPsAWwEe8qYOQrHzI0GgfBPvIsDnZQI+Ph6ht9hWyupfeOZ+j45p3Wsowu3tK+PrUffAM17z4P1Z0Drem5xox1hRiUXjgpWGt7zcOo3hw6WyR5/sk0XvV/ALur3kjYgJW3aR+tl12H6s6aaaSQiBYr3FoZ5xl/Lxt0N4LwZkoNZpSrHz5Kbsy9wVb6VLF/h7/QECic5hp6Fj5C14/usxZzDI3Vfo3mb7yH2IIZ4EjyT6wl9/DLZgw5mVZXmVKoxeVbyN67zNTRakrT8p33DYzfR7jsxoWWBHu7ab3sWjOFNFx+dgURdsPqkrUdzesPE1UnXGXb+CrdyQv+XmqdOP5kNuqxoBSyMU3XD++l58bFCMfstj4iwiyfc1rqaPn2+0xWktZ0X/OQcZVHcUsngu5rFpnC7UWfpi9fQuz4WaOPa21AS/Xk2HfZdRTX7a7YooGRCLQi7cRZE3TwZH9QagwdbEiY/NYwDpSs7J/8zejRg5qTj3WPZX2Kzm/9jswfnu1PeRwROw+cPP9kGj7+ZvAV+ec3k/nj8+b5yWj8yggz/9QrZB9dBb6i9u9eR+3fvW70+Vpl6x8XPFo/dT2F5zeZ1Uqjfe8KoLUmjsM93maCKsiUGswIdyG8lMqIPB7sYqXXSm1YpobKKbWCZIy2L91qXF53DJbXjosbPnsRyTechM4W6L3+UXSutKvgBDcv2wt2X7MI1Z0lfupRNH313fs9NyTaDmKUpu1zt5B7ZBWyKR1K0SqtSDkxNvud3B9s6z9WTVSlcClVxxCaO4NNuMIJZzSwv44TtH72JgrPbjS/jyReYRcduA4t33k/7tEt5F/YTN+ddlfBsYyXD5XAFMTL3v8S+cVrcBpraP7me5GNadPhDCdcbR5CCtq//hsyf3jO7EAYQtFiTzclYtzjb6WH0hRQdVG1wi31kIv87az12sOTkDEYpRGxGDpfpPWKhXhrdo6eGinNeDd23Eyav3wJws6lqq6sEf5EdFI2tRFf0XPdI6ieHA2fejvJ151gMsSGc5H1gHvd+b276L1psck/DqlolVbEpcsOv4d7g8322OBXhZ9h7kb40ZgtOQsi4A/+RhITuQn24aIUIhnHb+9l36XXmoqJowWs7PM173kNdR+9gMLzG+m9dSlMkNUtvWfm7hfIPvIyNe88xxR50ybCPBylwFnPNYvo/p/7TVH3kb5XhVFAjYxxf7CNfeRxqI6Ei8EMf0eqAeu63R9sY7PfTdqJh3esEihkbRJvWxutl15L0NFnrNgIIixV12j62rtJnHscPdc8jL+3e/ytrnXpVbZA90/vJ3Z0C83f+jsTaNLDJ29p3+xA2Pebp+j4d1u0fBxPa7xR2mxU3RZk+aO/EcriJdVGVQtXo3GEoBePO70NpKQb7tvgm209Cy9vN7WbMgWb9jjMWdspIlmXYtp/fhB/Xze91z8K42117Xv13f4UheVbab76A7jHTDMu8nBTP6Uqlvcvp/1rt5s6WliXO6QEWlHnxLnX28JOsjjDjdmrgKoWLmVzb3f5m9ngd5KSsXCOdUv4Zo43/8QrtH72RrQX2M2gh2nwjkmJTJy3gMbPvYPuXz2Mv7VtVGs9ZuzYVnVn6f7xfdR99AJqLj7buLvDjGu1b57LP/kKbf/vFvM6G1QLK0orko7LHj/Dbb7ZViRMm3gdLEPfmSpCY7bl7BUevymuJxnmsW4JXyGba8jet5z2L99qPFE9vHiFY13m/3cxseNn0fnDe+wzQ7/+YChZ7p5fPgRS0vwv7zFPjGhpJcWXttL6yYXGXY7Z3fpCjBnbxvmTt4m95EwllSqmus/eUhLq3cEW1ngd4ZzXHYyvkC219N3+JB3f/v1AauRQAhDWnZaCad/7B7IPrqDw0taxLR8ciVKtqx0d9Ny8hJarP4Bsqhl26kdbK+xt2MO+y65D9eUqUrT8YFFakZAuO/0+7gw2mGPj0OlVkikhXGN1JQUR8Bv/FeLSrY5IoV2U0H3tIrp+/GeTGjmcCOwOAYmzjqX+Q+fT9f27B7/i4LGf1fWDu0m96VWkLzpz2Kmf0mqgYHcXrZdeh7+ny5RoDXEEuUSgNbUyxh/8jSaSXCVL90biwDtUpZSiyff5W1nhtVLrJMJvdTHicRpr6PrhPfTe9PiIqZGlFTmNX34nqjtL9qGVh77sT5mxbWHFVoovbzdRZIZxkUv5x91Zk3+8YY/ZwbAqRKtIOzE2+9381lsPVTpvO5gpI1yNyWH2hOIGb3X4Vg0NhzbusaxN0v6tO8j86XmbGjlE1UNh54Rdh6avXELvjYuNqKQ85OFuzy8W0XDl23Fa6vozp/bDuug679H6yespLNts84+HOL8QorUmKWLcUlxLr/BCuWXmoTBlhEvZuGWx2sXi4g4anCS+qoIGps04VsRjtH3x1+QeXYVwHBO9HYw0iRnJvzyR+Jnz6PvtU4BNhBgrNtMp99BKZGPa7PEz1AokrdHCuMltV91sdnFoCm8q42ACrah1Eyz39nJXf5ZUdZz7aEwp4WKtLsAN/hr6VGHid7EfL7Q2C+q1pvUzN5r6xe7QqZGludWGS99C8eXtZpG6M0arq4348QNyi1fTcOXbAQ4svqdNBQ8hBB1fu52+u563+cdV0BGWITQs9FebWslUX07ycFRJqx47ylbJWKU7+LO/jUY3iVcNVhc7lkzE0Lki+z65kKIt03pAaqRdWC/rU6QvPpvsAy+Z40NFpAdjLU520cskXn8S7pwmY4HLhVva7FoKOq/+I723LMFpCW/+8VD4KqDBTfKYt4Mn1B5ECDenPhymnHBhoCbu9d5qdvt9JCtdQP1gCExec9DWa6pH7GgfekWR3ac2+RcnIBIx/N2ddkngCI1Tm7xj1ZVB9+WoedsZAxa4HBuM6v75g3T//MGKbw9ysJRqSfUGBRZ6qwGmkK01TEnhmtpUkn3kuN5bTVpUcL+hQyFQyNoE3pZWWi9biOrMmPHnAeFQYyVTF5xiFi6UHRsJb9M+kq8/yUaQB72nzYrqvXUpnf95l80/Hvy54UahaXCS3FZcxzq6cKqoltRYmZLCBQhQCODOYCNPertocFLVEagqUcprXrGVfZcvRGeLB+Y1C2NFZVMN7lEtqJ5s/7ED0KZwucoUcKbX48w2m2aXu8hmlz1J5p5ldHz9t2bPXIZJCgkpgVbUyDirvFZu8tdBWdByKjFlhUupXQM/9VbQp4q40gl/OmQ5vkI21pBfupbWz95khDVYmFZ47qwGU0Wx7Nh+2GMi5uDMbtzvGJj8Y+E65B5fQ9vn/xfsnrnV2OYF8JPiCvIimFIBqXKmtHAV4CBYqzu5tbiOeidRfb2vH5i85nuX0fGV2wfENLgDsptdj4aIuwdmRtn848KyzbRdeYOdKx7npYOTgKcCmtwUd3ubeFrvRVbxsr3RmNLCpcxNutlfy8teW3grZYxEqV7zrUvp+Ldh8pqHsrJDodlvHFzKPy6+spvWyxeiMoWqyD8eTKAVKSfOdr+HXxRXAqDHMN6vVqa8cLW1unkR8DNvRdVZkX4ChWyqpecXi+j+2YOHvqxPlOnW5h/7OztM/nFrDyIVPzCCXQVoNEnhcK23mnZRqNrKFmNlygsX6y5JBE+rvdzlbaLJTVXP3G45WiMb0qa2061L7VrdQ/weNldZdWVovew6vE17kbXVsWhgML4KaHBSPOZt526bITVVXeQSR4RwKZv0uMZ7ma1+N6lqdJmttyBrEnR8/bdk7n2xf6Psg6KUf5wtsO/y6yi8tDW09Y9HQ2lNTLp0BXl+7hkX+Uho1EfCdwTrSjkI2ilwrbeKlHCqs08uTeHEXdo/dwv5JWuteMcoOm22D9F+QOtnbya/ZB2ysXryjwej0NQ7CW721rBR9yC0nnJztkNxxAgX6z4JBPcGW3mouJUmN4VfbVYXIz7hmo2xW6+8gcLyLcPmNe+HtjsICkHHl28je9+yqsw/LuGrgHonwfPeHm7zzZK9MQfpqpwjSrhYywvwQ2852/2e8NeoGg6b16z6crRevhBvwx6bXTXMd9E2Ci0FHd/9Pb23P1l1qYzllOoj9wQF/qP4Ap5QyLIh0VTniBMu0J8O+f3iMpz+feGrkEAhUgn8PV2m5OuuTpN3PITlNYsGJN0/uZ+eXy4Kff3j0dACapw4Py2+xAbdPSXTGkfiiBRugMJBsFTt5pbiGprcdHW6zNhporokxQ172He52Yd2cF5zqf5x7y2P0/n9u5GN6eEtcxXga0WTTHF3cSN/UJundKLFcByRwqUsMeMabxXPFndT7ySqK5e5HF8hG9IUlm2m9Yrr0QWvf6WQ9gOE65D50/N0fOMOZG1yYKxbhZRykV/xO/hB4UVgaidaDMcRK1xtv7wnFP9efJ4uVSAuq2j532B8hWyqIffYKlPrWGkIzOZhuUdX0f7FXyPisarNP8ZO/UgEgVZ8r/CCKUUzxRMthuOIFS42l1lo2Ewv/1N8kbR0q3uc5Jvsqswfn6P9q7eBKyk8t5HWz9xoGncV5h+Xo4Sm0U2xsLiKF2jDEVNrcfzB4DQ2Nn5z8MEjCmF6r3W6m5k6ydnxmWSUh6zWaQWtEek4hRc2E+zppOemxQT7epDJxKGlSIYETwU0OSmWeDv4T38Z2I73SEXMnz+/eu/mOCGsu1WnY1ybvJD5bgOZoIhbLfWqhkIKVK8pWC7iblWLNtCKhHDp1gU+llvEHpFDHuHCreKWOX6Usqp6hcfVxefxVYCLqN7xLmaeV9alEbHqFm1p/XRCOPyg+CJ7RO6Im/oZiki4lsCKd4Vu54eFZdQ5ieofPSlV1WNa7Li22UlxbWElj6gdR/S4tpxIuGWUxPsHtZmbCmtorub53SmApxXNToq7C5u4JlhtKjVWeUc0XkTCHYSys4I/9VewqLCVJicZibcC+FrR4CR5sbiXf/dfGPz0EU8k3EFou848QPPt4rOs9TuocxL4VZxpVG0EWpGWMfYEffxL8Rmy+MgjdL52OCLhDoECJIIe4fEvhafpDHIkpVudixGqDKUVjpD4WvGNwtPsJGODUZFoy4mEOwwKjSMkG+nhO8XnkEIgENVVJbIK0UCtjPP94gss020IfeTlIY+FSLgjEGiFg2Sp2s2PC8tpcJKRuzaB+Cia3TTXF1ZxV7DFpDNWaR7MRBMJdxQCFBLB7cF6bsuvpcVN40Uu87jjaUWLk+aB4mZ+5q9ElC0EiTiQSLhjoGRl/9tfzkOFrUxz0/hHfArA+OFrRZOT5LniHr5VeBasyxzJdngi4Y6BUgPyhebrxadZWtxJk5PCi8R72Hi2/Mxqr50vFpeSFUHUKMdAdI0OAgnkRcBXik/yQnEvTTKJr6t0DW8I8FHUu0m2+N18ofgEnRSjdMYxEgn3IChNE/Xi8aXCE6z126l3qrRGc4Xx7YL4PX4fn88vZQ9Zs9Y2cpDHRCTcg8RMEwk6RIHPF55gq99tEzQi8Y4VXwWkZYyuIM/nCkvYKvqiudqDJBLuIRBok9O8myyfLyxln8pS4yQit3kMBFqRlDGyyuML+aWspyeaqz0EIuEeIgEaoTVb6OXz+aV0qzwpGY8s7wj4WhETDgGarxSfYiUdCG0qNkYcHJFwDwMtBI6GdXTxhfwT5JRHyolHixKGwNeKGBKJ4F/yT/Gs2ovQOhLtIRIJ9zAJhKlbtYJ2rsovoVcVqJGxyPKW4WtFUrooAV/OP8FivQsHia7W8kAhIBLuOKAFOEKwgnauzC9mb5Clzk1GSRplgaic9vlc/nGW6N042mSkRRw6kXDHiUCbMe8rdPOpwmK2+N00yMQR7TZ7KqDWSdAR5Ph0fjEv6DYcIQkiQ3vYRMIdR7QQOEKynT4+VVjMKq+NJjd5RGZYeSqgwU2yS/VxZWExq3WniR4fwR3ZeBIJd5wxK4oE+8jx6cISni3uoUVW6a6Ah4ivA5rcFBv8Tj6Zf4xN9OKIaKXPeBIJdwII0EigWxT5XPEJHiluMwsTtJrS63m11qZOlJtmubePT+UXs5ssDjKqFTXORMKdIEx6JGTw+HLxKX5fWE+Lm0aIqekuKq1RAqa7aR4tbOOzxSW0i4Ktyjj1vm+liQqiTzDSbkql0XzEOYkrEmdQVD5FHeBKZ/DLqxJfKVwhqXXi3JRfzc+Clf1eRyTZiSES7iQgsDvnCThfzOZfk6+hQSborfbdEuwcbVrG8HTA9wrLuEdt6XfjItFOHNXdaqoEjQYBQmuW6N18IvcIr3idNDsmaFWN416tNb5WNDpJ9gYZrsgv5h61BUcbDyMS7cQSCXeS0Ha6SGjNZnq5vPAY9xe30OKmQRjLVS0EWqHQtLhpninu5hOFR1ip2810jxioGBIxcUSucgUoLWETwMecV3Fp8tUUVUBOecRCPu71VEBCOtTKBLcW1vIjbzmeMKulohU+k0ck3AoirYBfL2bzufiZHBtrpCvIo7UpDRsmlNYEWtMUS7LPz/Dj4kvcr7ZF49kKEQm3ggiwQStBvY7x6dgZXJI4joLyySk/NNbXVwEx6VAnEzxU3MJ/ecvZQw5HSJTWkWtcASLhhgBHmELrGniTnMtVsbM4OlZHZ5ADTcWsr9IKBTQ6STqCPD8tvsSf1GYAHCRmpBtRCSLhhgQJCCEJtKKFJJ9xT+fixALyyievfSQgJ0nAxi02S/FqnDiLCzv4obeM7XY7EI2OXOMKEwk3ZJQCVxr4a3k0H3dP5fh4E31BkYLycYRETtA61tIUT0w41LsJdni93OSv4ffBRlRkZUNFJNwQYuyqEXANMf7WOZb3uydyVKyOHr9AUQfjKmCldf9mWw1uklY/w++9jfw22EAHhSgAFUIi4YYYM/Y186LNJPh750QuiS1gmpOmJ8jjaYW0SwkPhUAb6+kgqHOSZFSBe70t3OKvZRdZGOQBRISHSLhVQLl45pLmo+4pvNk9mmY3TV555JSHtlFqgRjWEmut+x1drSHlxEhJl56gwBJ/Jzf5a1mvuxGALOs0IsJHJNwqojTvCzCXGi5yjuGt7jEc6zbiIihqRUH5pmSOpmzzFCNkVwgS0iWGgxawze/mkWAn9/qb2Uyv+Qxh8qojtzjcRMKtMgaPN5Nacoaczl86sznHmc4skabJSVmpliyvsZvdQZ49OssK1c7SYBcvBq1khD/k+0aEm0i4VYqZPhL7LVB3tWCOqGG+rGemSNNADCEE3apAK3k2q252ixyFssLtjpD7udAR1UEk3CrHjEclaD3mXGGJQGuzYmlsfxERNg4tHBkRGrSNDpdEK20wy7HRZvMwv0srdIVZGxyJtnqJhDvFULbmVWCzn8zD/K7KwlUR1U0k3IiIKiQSbkREFRIJNyKiComEGxFRhUTCjYioQiLhRkRUIZFwIyKqkEi4ERFVSCTciIgqJBJuREQVEgk3IqIKiYQbEVGFRMKNiKhCIuFGRFQhkXAjIqqQSLgREVVIJNyIiCokEm5ERBUSCTciogqJhBsRUYVEwo2IqEIi4UZEVCGRcCMiqpBIuBERVUgk3IiIKuT/A1v9xPP1vhaRAAAAAElFTkSuQmCC",
);
final Uint8List defaultImageUint8List = base64Decode(
  "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==",
);
