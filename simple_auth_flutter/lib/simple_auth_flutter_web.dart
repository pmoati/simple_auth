import 'dart:async';
// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html show window;

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'dart:html';

/// A web implementation of the SimpleAuthFlutter plugin.
class SimpleAuthFlutterWeb {
  static String? _initialUrl;
  static StreamController<Map<Object?, Object?>>? _controller;

  static void registerWith(Registrar registrar) {
    final MethodChannel channel = MethodChannel(
      'simple_auth_flutter/showAuthenticator',
      const StandardMethodCodec(),
      registrar,
    );

    final pluginInstance = SimpleAuthFlutterWeb();
    // channel.setMethodCallHandler(pluginInstance.handleMethodCall);
    channel.setMethodCallHandler(pluginInstance.handleMethodCall);

    final PluginEventChannel<Map<Object?, Object?>> sendingChannel =
        PluginEventChannel<Map<Object?, Object?>>(
            'simple_auth_flutter/urlChanged',
            const StandardMethodCodec(),
            registrar);

    _controller = StreamController<Map<Object?, Object?>>();
    sendingChannel.setController(_controller);
    _initialUrl = window.location.toString();
  }

  /// Handles method calls over the MethodChannel of this plugin.
  /// Note: Check the "federated" architecture for a new way of doing this:
  /// https://flutter.dev/go/federated-plugins
  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'getPlatformVersion':
        return getPlatformVersion();
      case 'initAuthenticator':
        var redirectUrl = call.arguments['redirectUrl'];
        if (redirectUrl != null &&
            Uri.parse(redirectUrl).path == Uri.parse(_initialUrl!).path) {
          _controller!.add({
            "identifier": call.arguments['identifier'],
            "url": _initialUrl,
            "forceComplete": true,
            "description": ""
          });
        } else {
          html.window.location.replace(
              call.arguments['initialUrl'].toString() + "&prompt=none");
        }
        return true;
      case 'showAuthenticator':
        html.window.location.replace(call.arguments['initialUrl'].toString());
        return "code";
      case 'completed':
        return true;
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details:
              'simple_auth_flutter for web doesn\'t implement \'${call.method}\'',
        );
    }
  }

  /// Returns a [String] containing the version of the platform.
  Future<String> getPlatformVersion() {
    final version = html.window.navigator.userAgent;
    return Future.value(version);
  }
}
