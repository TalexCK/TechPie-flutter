import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:techpie/utils/platform.dart';

enum IosGlassActionButtonVariant { automatic, glass, clearGlass }

class IosGlassActionButton extends StatefulWidget {
  const IosGlassActionButton({
    super.key,
    required this.onPressed,
    this.label,
    this.icon,
    required this.sfSymbol,
    this.destructive = false,
    this.enabled = true,
    this.width,
    this.height = 44,
    this.variant = IosGlassActionButtonVariant.automatic,
  });

  final VoidCallback onPressed;
  final String? label;
  final IconData? icon;
  final String sfSymbol;
  final bool destructive;
  final bool enabled;
  final double? width;
  final double height;
  final IosGlassActionButtonVariant variant;

  @override
  State<IosGlassActionButton> createState() => _IosGlassActionButtonState();
}

class _IosGlassActionButtonState extends State<IosGlassActionButton> {
  MethodChannel? _channel;

  bool get _usesNative => isIos();

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    _channel = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_usesNative) {
      if (widget.label == null || widget.label!.isEmpty) {
        return IconButton(
          onPressed: widget.enabled ? widget.onPressed : null,
          icon: Icon(widget.icon ?? Icons.circle, size: 18),
        );
      }

      if (widget.icon == null) {
        return TextButton(
          onPressed: widget.enabled ? widget.onPressed : null,
          child: Text(widget.label!),
        );
      }

      return TextButton.icon(
        onPressed: widget.enabled ? widget.onPressed : null,
        icon: Icon(widget.icon, size: 18),
        label: Text(widget.label!),
      );
    }

    final width = widget.width ?? _intrinsicWidth(context);
    final height = _scaledHeight(context);

    return SizedBox(
      width: width,
      height: height,
      child: UiKitView(
        viewType: _viewType,
        layoutDirection: Directionality.of(context),
        creationParams: <String, Object?>{
          'label': widget.label,
          'sfSymbol': widget.sfSymbol,
          'destructive': widget.destructive,
          'enabled': widget.enabled,
          'glassVariant': widget.variant.name,
        },
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onPlatformViewCreated,
      ),
    );
  }

  double _intrinsicWidth(BuildContext context) {
    final label = widget.label;
    final hasLabel = label != null && label.isNotEmpty;
    final textScaler = MediaQuery.textScalerOf(context);

    if (!hasLabel) {
      return math.max(44, textScaler.scale(36));
    }

    final style = DefaultTextStyle.of(context).style.copyWith(
          fontSize: 17,
          fontWeight: FontWeight.w400,
        );
    final painter = TextPainter(
      text: TextSpan(text: label, style: style),
      textDirection: Directionality.of(context),
      textScaler: textScaler,
      maxLines: 1,
    )..layout();

    final hasIcon = widget.sfSymbol != 'none' || widget.icon != null;
    final iconWidth = hasIcon ? textScaler.scale(18) + 6 : 0;
    return math.max(44, painter.width + iconWidth + textScaler.scale(32));
  }

  double _scaledHeight(BuildContext context) {
    final scaledBody = MediaQuery.textScalerOf(context).scale(17);
    return math.max(widget.height, scaledBody + 20);
  }

  @override
  void didUpdateWidget(covariant IosGlassActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!_usesNative) return;
    final channel = _channel;
    if (channel == null) return;

    final changed = oldWidget.label != widget.label ||
        oldWidget.sfSymbol != widget.sfSymbol ||
        oldWidget.destructive != widget.destructive ||
        oldWidget.enabled != widget.enabled ||
        oldWidget.variant != widget.variant;

    if (!changed) return;

    unawaited(_sendConfigurationUpdate(channel));
  }

  Future<void> _sendConfigurationUpdate(MethodChannel channel) async {
    try {
      await channel.invokeMethod<void>('updateConfiguration', <String, Object?>{
        'label': widget.label,
        'sfSymbol': widget.sfSymbol,
        'destructive': widget.destructive,
        'enabled': widget.enabled,
        'glassVariant': widget.variant.name,
      });
    } on PlatformException {
      // Platform view may be tearing down.
    } on MissingPluginException {
      // Platform view may not be wired yet.
    }
  }

  void _onPlatformViewCreated(int viewId) {
    final channel = MethodChannel('$_channelPrefix/$viewId');
    _channel?.setMethodCallHandler(null);
    _channel = channel;

    channel.setMethodCallHandler((call) async {
      if (call.method != 'onPressed') return null;
      widget.onPressed();
      return null;
    });
  }
}

const _viewType = 'techpie/native_glass_action_button';
const _channelPrefix = 'techpie/native_glass_action_button';
