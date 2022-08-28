// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:flutter_gen/gen_l10n/gallery_localizations.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:gallery/constants.dart';
import 'package:gallery/data/gallery_options.dart';
import 'package:gallery/pages/backdrop.dart';
import 'package:gallery/pages/splash.dart';
import 'package:gallery/routes.dart';
import 'package:gallery/themes/gallery_theme_data.dart';
import 'package:google_fonts/google_fonts.dart';

export 'package:gallery/data/demos.dart' show pumpDeferredLibraries;

class MouseCursorPainter extends CustomPainter {
  MouseCursorPainter({required this.offset, this.factor = 64.0});

  final Offset offset;
  final double factor;

  @override
  void paint(Canvas canvas, Size size) {
    final path = ui.Path()
      ..moveTo(offset.dx, offset.dy)
      ..lineTo(offset.dx, offset.dy + 48 * factor / 64)
      ..lineTo(offset.dx + 34 * factor / 64, offset.dy + 34 * factor / 64)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black
        ..style = ui.PaintingStyle.fill,
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white
        ..style = ui.PaintingStyle.stroke
        ..strokeJoin = ui.StrokeJoin.miter
        ..strokeWidth = 3.5 * factor / 64,
    );
  }

  @override
  bool shouldRepaint(covariant MouseCursorPainter oldDelegate) {
    return oldDelegate.offset != offset;
  }
}

class SoftwareMouseCursor extends StatelessWidget {
  SoftwareMouseCursor({Key? key, required this.child}) : super(key: key);

  final cursorPos = ValueNotifier(Offset.zero);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) {
        if (event.kind == PointerDeviceKind.mouse) {
          cursorPos.value = event.position;
        }
      },
      onPointerMove: (event) {
        if (event.kind == PointerDeviceKind.mouse) {
          cursorPos.value = event.position;
        }
      },
      onPointerUp: (event) {
        if (event.kind == PointerDeviceKind.mouse) {
          cursorPos.value = event.position;
        }
      },
      onPointerHover: (event) {
        if (event.kind == PointerDeviceKind.mouse) {
          cursorPos.value = event.position;
        }
      },
      behavior: HitTestBehavior.translucent,
      child: ValueListenableBuilder<Offset>(
        valueListenable: cursorPos,
        builder: (context, pos, child) {
          return CustomPaint(
            foregroundPainter: MouseCursorPainter(
              offset: pos,
              factor: ui.window.devicePixelRatio * 64,
            ),
            child: child,
          );
        },
        child: RepaintBoundary(
          child: child,
        ),
      ),
    );
  }
}

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
  runApp(
    SoftwareMouseCursor(
      child: const GalleryApp(),
    ),
  );
}

class GalleryApp extends StatelessWidget {
  const GalleryApp({
    Key? key,
    this.initialRoute,
    this.isTestMode = false,
  }) : super(key: key);

  final bool isTestMode;
  final String? initialRoute;

  @override
  Widget build(BuildContext context) {
    return ModelBinding(
      initialModel: GalleryOptions(
        themeMode: ThemeMode.system,
        textScaleFactor: systemTextScaleFactorOption,
        customTextDirection: CustomTextDirection.localeBased,
        locale: null,
        timeDilation: timeDilation,
        platform: defaultTargetPlatform,
        isTestMode: isTestMode,
      ),
      child: Builder(
        builder: (context) {
          return MaterialApp(
            // By default on desktop, scrollbars are applied by the
            // ScrollBehavior. This overrides that. All vertical scrollables in
            // the gallery need to be audited before enabling this feature,
            // see https://github.com/flutter/gallery/issues/523
            scrollBehavior:
                const MaterialScrollBehavior().copyWith(scrollbars: false),
            restorationScopeId: 'rootGallery',
            title: 'Flutter Gallery',
            debugShowCheckedModeBanner: false,
            themeMode: GalleryOptions.of(context).themeMode,
            theme: GalleryThemeData.lightThemeData.copyWith(
              platform: GalleryOptions.of(context).platform,
            ),
            darkTheme: GalleryThemeData.darkThemeData.copyWith(
              platform: GalleryOptions.of(context).platform,
            ),
            localizationsDelegates: const [
              ...GalleryLocalizations.localizationsDelegates,
              LocaleNamesLocalizationsDelegate()
            ],
            initialRoute: initialRoute,
            supportedLocales: GalleryLocalizations.supportedLocales,
            locale: GalleryOptions.of(context).locale,
            localeListResolutionCallback: (locales, supportedLocales) {
              deviceLocale = locales?.first;
              return basicLocaleListResolution(locales, supportedLocales);
            },
            onGenerateRoute: RouteConfiguration.onGenerateRoute,
          );
        },
      ),
    );
  }
}

class RootPage extends StatelessWidget {
  const RootPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ApplyTextOptions(
      child: SplashPage(
        child: Backdrop(),
      ),
    );
  }
}
