import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_physics/flutter_physics.dart';

import 'smooth_hover_scope.dart';

/// Signature for the builder function of a widget that responds to hover,
/// focus, and press states.
typedef HoverBuilder = Widget Function(
  BuildContext context,
  bool isHovered,
  bool isFocused,
  bool isPressed,
  Widget? child,
);

/// A widget that provides smooth, physics-based hover effects and tooltips.
///
/// The [SmoothHover] widget must be used within a [SmoothHoverScope] ancestor widget
/// to function properly. It provides several features:
///
/// * Physics-based hover animations with customizable ink effects
/// * Smart tooltips with configurable delays and styles
/// * Built-in focus and press state handling
/// * Customizable mouse cursor behavior
///
/// Example usage:
///
/// ```dart
/// SmoothHover(
///   inkDecoration: BoxDecoration(
///     color: Colors.grey.withOpacity(0.1),
///     borderRadius: BorderRadius.circular(16.0),
///   ),
///   tooltipText: 'Hello World',
///   tooltipDelay: Duration(milliseconds: 500),
///   child: Container(
///     width: 200,
///     height: 60,
///     child: Center(
///       child: Text('Hover me!'),
///     ),
///   ),
/// )
/// ```
///
/// For more complex hover behaviors, you can use the [builder] parameter:
///
/// ```dart
/// SmoothHover(
///   builder: (context, isHovered, isFocused, isPressed, child) {
///     return AnimatedScale(
///       scale: isHovered ? 1.1 : 1.0,
///       duration: Duration(milliseconds: 200),
///       child: child,
///     );
///   },
///   child: YourWidget(),
/// )
/// ```
class SmoothHover extends StatefulWidget {
  /// Creates a smooth hover effect widget.
  ///
  /// Either [builder] or [child] must be provided.
  const SmoothHover({
    super.key,
    this.autofocus = false,
    this.focusNode,
    this.onFocusChange,
    this.inkDecoration,
    this.inkPhysics,
    this.inkAnimationDuration,
    this.tooltipText,
    this.tooltipSpan,
    this.tooltipDecoration,
    this.tooltipPhysics,
    this.tooltipAnimationDuration,
    this.tooltipDelay = const Duration(milliseconds: 1000),
    this.cursor = MouseCursor.defer,
    this.opaque = true,
    this.onEnter,
    this.onHover,
    this.onExit,
    this.onTap,
    this.actions,
    this.shortcuts,
    this.builder,
    this.child,
  })  : assert(
          builder != null || child != null,
          'Either builder or child must be provided',
        ),
        assert(
          inkAnimationDuration != null || inkPhysics is PhysicsSimulation?,
          'inkAnimationDuration must be provided if inkPhysics is not a PhysicsSimulation',
        ),
        assert(
          tooltipAnimationDuration != null ||
              tooltipPhysics is PhysicsSimulation?,
          'tooltipAnimationDuration must be provided if tooltipPhysics is not a PhysicsSimulation',
        );

  /// Whether this widget should be focused initially.
  final bool autofocus;

  /// An optional focus node to control the focus state of this widget.
  final FocusNode? focusNode;

  /// Called when the focus state of this widget changes.
  final ValueChanged<bool>? onFocusChange;

  /// The mouse cursor to show when hovering over this widget.
  ///
  /// Defaults to [MouseCursor.defer], which means the cursor will be determined by
  /// the platform.
  final MouseCursor cursor;

  /// Whether the widget is opaque for hit testing purposes.
  ///
  /// If true, this widget can receive hover events even if there are other
  /// interactive widgets above it in the widget tree.
  final bool opaque;

  /// The decoration to apply to the ink effect when hovering.
  ///
  /// If null, the decoration from the nearest [SmoothHoverScope] ancestor will be used.
  /// If that is also null, a default decoration will be used.
  final Decoration? inkDecoration;

  /// The decoration to apply to the tooltip.
  ///
  /// If null, a default tooltip decoration will be used.
  final Decoration? tooltipDecoration;

  /// The text to display in the tooltip.
  ///
  /// If both [tooltipText] and [tooltipSpan] are provided, [tooltipText] takes precedence.
  final String? tooltipText;

  /// The rich text to display in the tooltip.
  ///
  /// This allows for more complex tooltip content with different styles and spans.
  final InlineSpan? tooltipSpan;

  /// The delay before showing the tooltip after hover begins.
  ///
  /// Defaults to 1000 milliseconds (1 second).
  final Duration tooltipDelay;

  /// The physics configuration for the ink effect animation.
  ///
  /// If null, the physics from the nearest [SmoothHoverScope] ancestor will be used.
  /// If that is also null, default spring physics will be used.
  final Physics? inkPhysics;

  /// The physics configuration for the tooltip animation.
  ///
  /// If null, default physics will be used.
  final Physics? tooltipPhysics;

  /// The duration of the ink animation.
  ///
  /// If null, the duration from the nearest [SmoothHoverScope] ancestor will be used.
  /// If that is also null, a default duration will be used.
  final Duration? inkAnimationDuration;

  /// The duration of the tooltip animation.
  ///
  /// If null, the duration from the nearest [SmoothHoverScope] ancestor will be used.
  /// If that is also null, a default duration will be used.
  final Duration? tooltipAnimationDuration;

  /// Called when the pointer enters the widget's bounds.
  final ValueChanged<PointerEnterEvent>? onEnter;

  /// Called when the pointer moves within the widget's bounds.
  final ValueChanged<PointerHoverEvent>? onHover;

  /// Called when the pointer exits the widget's bounds.
  final ValueChanged<PointerExitEvent>? onExit;

  /// Called when the widget is tapped.
  final VoidCallback? onTap;

  /// The map of [Intent] to [Action] that defines the widget's keyboard shortcuts.
  final Map<Type, Action<Intent>>? actions;

  /// The map of [LogicalKeySet] to [Intent] that defines the widget's keyboard shortcuts.
  final Map<LogicalKeySet, Intent>? shortcuts;

  /// An optional builder that provides access to the widget's hover, focus, and press states.
  ///
  /// Use this for custom hover effects beyond the built-in ink effect.
  final HoverBuilder? builder;

  /// The widget below this widget in the tree.
  ///
  /// This widget will receive the hover effect and tooltip.
  final Widget? child;

  @override
  State<SmoothHover> createState() => SmoothHoverState();
}

class SmoothHoverState extends State<SmoothHover> {
  bool isHovered = false, isFocused = false, isPressed = false;

  BuildContext? _childContext;
  Size? size;
  Offset? offset;

  @override
  Widget build(BuildContext context) {
    final scope = SmoothHoverScope.of(context);
    return FocusableActionDetector(
      autofocus: widget.autofocus,
      mouseCursor: widget.cursor,
      focusNode: widget.focusNode,
      onFocusChange: widget.onFocusChange,
      onShowFocusHighlight: (isFocused) =>
          setState(() => this.isFocused = isFocused),
      actions: widget.actions,
      shortcuts: widget.shortcuts,
      child: GestureDetector(
        onTapDown: (_) => setState(() => isPressed = true),
        onTapUp: (_) => setState(() => isPressed = false),
        onTapCancel: () => setState(() => isPressed = false),
        onTap: widget.onTap,
        child: _ExclusiveMouseRegion(
          onEnter: (event) {
            widget.onEnter?.call(event);
            _childContext = context;
            if (!(_childContext?.mounted ?? false)) return;
            setState(() => isHovered = true);
            // Let the frame render with `isHovered = true` before calculating size.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              size = _childContext!.size;
              final box = _childContext!.findRenderObject() as RenderBox;
              offset = box.localToGlobal(
                box.size.center(Offset.zero),
                ancestor: scope.context.findRenderObject(),
              );
              scope.onHover(this);
            });
          },
          onHover: (event) {
            widget.onHover?.call(event);
          },
          onExit: (event) {
            widget.onExit?.call(event);
            if (!(_childContext?.mounted ?? false)) return;
            setState(() {
              isHovered = false;
              size = null;
              offset = null;
            });
            scope.onHoverExit(this);
          },
          child: Builder(
            builder: (context) {
              _childContext = context;
              return widget.builder?.call(
                      context, isHovered, isFocused, isPressed, widget.child) ??
                  widget.child!;
            },
          ),
        ),
      ),
    );
  }
}

/// Copied from Flutter's [Tooltip].
class _ExclusiveMouseRegion extends MouseRegion {
  const _ExclusiveMouseRegion({
    super.onEnter,
    super.onHover,
    super.onExit,
    super.child,
  });

  @override
  _RenderExclusiveMouseRegion createRenderObject(BuildContext context) {
    return _RenderExclusiveMouseRegion(
      onEnter: onEnter,
      onHover: onHover,
      onExit: onExit,
    );
  }
}

class _RenderExclusiveMouseRegion extends RenderMouseRegion {
  _RenderExclusiveMouseRegion({
    super.onEnter,
    super.onHover,
    super.onExit,
  });

  static bool isOutermostMouseRegion = true;
  static bool foundInnermostMouseRegion = false;

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    bool isHit = false;
    final bool outermost = isOutermostMouseRegion;
    isOutermostMouseRegion = false;
    if (size.contains(position)) {
      isHit =
          hitTestChildren(result, position: position) || hitTestSelf(position);
      if ((isHit || behavior == HitTestBehavior.translucent) &&
          !foundInnermostMouseRegion) {
        foundInnermostMouseRegion = true;
        result.add(BoxHitTestEntry(this, position));
      }
    }

    if (outermost) {
      // The outermost region resets the global states.
      isOutermostMouseRegion = true;
      foundInnermostMouseRegion = false;
    }
    return isHit;
  }
}
