import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_physics/flutter_physics.dart';

import 'smooth_hover.dart';

/// A widget that provides a scope for [SmoothHover] widgets to share hover effects
/// and configurations.
///
/// The [SmoothHoverScope] widget manages the hover ink effect for all [SmoothHover]
/// widgets within its subtree. It provides default decoration and physics configurations
/// that can be overridden by individual [SmoothHover] widgets.
///
/// Example usage:
///
/// ```dart
/// SmoothHoverScope(
///   decoration: BoxDecoration(
///     color: Colors.blue.withOpacity(0.1),
///     borderRadius: BorderRadius.circular(8.0),
///   ),
///   physics: Spring.withBounce(
///     duration: Duration(milliseconds: 200),
///     bounce: 0.2,
///   ),
///   child: Column(
///     children: [
///       SmoothHover(
///         child: Text('Hover me 1'),
///       ),
///       SmoothHover(
///         // Override the scope's decoration
///         inkDecoration: BoxDecoration(
///           color: Colors.red.withOpacity(0.1),
///           borderRadius: BorderRadius.circular(4.0),
///         ),
///         child: Text('Hover me 2'),
///       ),
///     ],
///   ),
/// )
/// ```
class SmoothHoverScope extends StatefulWidget {
  /// Creates a scope for smooth hover effects.
  ///
  /// The [child] parameter must not be null.
  const SmoothHoverScope({
    super.key,
    this.decoration,
    this.inkPhysics,
    this.inkAnimationDuration,
    this.tooltipDecoration,
    this.tooltipPhysics,
    this.tooltipAnimationDuration,
    this.tooltipDelay,
    required this.child,
  });

  /// The default decoration to apply to hover ink effects within this scope.
  ///
  /// Individual [SmoothHover] widgets can override this by providing their own
  /// [SmoothHover.inkDecoration].
  final Decoration? decoration;

  /// The default physics configuration for hover ink animations within this scope.
  ///
  /// Individual [SmoothHover] widgets can override this by providing their own
  /// [SmoothHover.inkPhysics].
  final Physics? inkPhysics;

  /// The default physics configuration for hover tooltip animations within this scope.
  ///
  /// Individual [SmoothHover] widgets can override this by providing their own
  /// [SmoothHover.tooltipPhysics].
  final Physics? tooltipPhysics;

  /// The default decoration to apply to hover tooltip effects within this scope.
  ///
  /// Individual [SmoothHover] widgets can override this by providing their own
  /// [SmoothHover.tooltipDecoration].
  final Decoration? tooltipDecoration;

  /// The default duration of the hover ink animation within this scope.
  ///
  /// Individual [SmoothHover] widgets can override this by providing their own
  /// [SmoothHover.inkAnimationDuration].
  final Duration? inkAnimationDuration;

  /// The default duration of the hover tooltip animation within this scope.
  ///
  /// Individual [SmoothHover] widgets can override this by providing their own
  /// [SmoothHover.tooltipAnimationDuration].
  final Duration? tooltipAnimationDuration;

  /// The default delay of the hover tooltip animation within this scope.
  ///
  /// Individual [SmoothHover] widgets can override this by providing their own
  /// [SmoothHover.tooltipDelay].
  final Duration? tooltipDelay;

  /// The widget below this widget in the tree.
  ///
  /// This is the root of the subtree that will share hover effect configurations.
  final Widget child;

  /// Returns the [SmoothHoverScopeState] from the closest [SmoothHoverScope]
  /// ancestor.
  ///
  /// This method is typically used by [SmoothHover] widgets to access the scope's
  /// state and configurations.
  ///
  /// Throws an exception if no [SmoothHoverScope] ancestor is found.
  static SmoothHoverScopeState of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_SmoothHoverScope>()!
        .state;
  }

  /// The default ink decoration used when no decoration is provided.
  ///
  /// This applies a subtle black overlay with rounded corners.
  static final defaultInkDecoration = BoxDecoration(
    color: Color.from(alpha: 0.05, red: 0.0, green: 0.0, blue: 0.0),
    borderRadius: BorderRadius.circular(8.0),
  );

  /// The default tooltip decoration used when no decoration is provided.
  static final defaultTooltipDecoration = BoxDecoration(
    color: Color.fromARGB(255, 250, 250, 250),
    borderRadius: BorderRadius.circular(8.0),
    boxShadow: [
      BoxShadow(
        color: Color.fromARGB(150, 200, 200, 200),
        blurRadius: 16.0,
      ),
    ],
  );

  /// The default physics configuration used when no physics is provided.
  ///
  /// This creates a spring animation with a slight bounce effect.
  static final defaultPhysics = Spring.withBounce(
    duration: Duration(milliseconds: 300),
    bounce: 0.05,
  );

  @override
  State<SmoothHoverScope> createState() => SmoothHoverScopeState();
}

/// The state for a [SmoothHoverScope] widget.
///
/// This class manages the currently hovered widget and provides methods for
/// [SmoothHover] widgets to register and unregister their hover states.
class SmoothHoverScopeState extends State<SmoothHoverScope> {
  /// The currently hovered widget's state, if any.
  SmoothHoverState? hoveredWidget;
  StateSetter? _setInkState, _setTooltipState;

  /// Called when a [SmoothHover] widget enters the hover state.
  ///
  /// This updates the scope to show the hover ink effect for the newly hovered widget.
  void onHover(SmoothHoverState state) {
    hoveredWidget = state;
    _setInkState?.call(() {});
    _setTooltipState?.call(() {});
  }

  /// Called when a [SmoothHover] widget exits the hover state.
  ///
  /// This updates the scope to remove the hover ink effect.
  void onHoverExit(SmoothHoverState state) {
    hoveredWidget = null;
    _setInkState?.call(() {});
    _setTooltipState?.call(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        StatefulBuilder(builder: (context, setInkState) {
          _setInkState = setInkState;
          final size = hoveredWidget?.size;
          final target = hoveredWidget?.offset;
          final effectiveDecoration = hoveredWidget?.widget.inkDecoration ??
              widget.decoration ??
              SmoothHoverScope.defaultInkDecoration;
          final effectivePhysics = hoveredWidget?.widget.inkPhysics ??
              widget.inkPhysics ??
              SmoothHoverScope.defaultPhysics;
          return _Ink(
            size: size,
            target: target,
            decoration: effectiveDecoration,
            physics: effectivePhysics,
            animationDuration: hoveredWidget?.widget.inkAnimationDuration ??
                widget.inkAnimationDuration,
          );
        }),
        _SmoothHoverScope(state: this, widget: widget),
        StatefulBuilder(builder: (context, setTooltipState) {
          _setTooltipState = setTooltipState;
          final size = hoveredWidget?.size;
          final target = hoveredWidget?.offset;
          final effectiveDecoration = hoveredWidget?.widget.tooltipDecoration ??
              widget.tooltipDecoration ??
              SmoothHoverScope.defaultTooltipDecoration;
          final effectivePhysics = hoveredWidget?.widget.tooltipPhysics ??
              widget.tooltipPhysics ??
              SmoothHoverScope.defaultPhysics;
          return _Tooltip(
            childSize: size,
            target: target,
            decoration: effectiveDecoration,
            physics: effectivePhysics,
            text: hoveredWidget?.widget.tooltipText,
            span: hoveredWidget?.widget.tooltipSpan,
            delay: hoveredWidget?.widget.tooltipDelay ??
                widget.tooltipDelay ??
                Duration.zero,
            animationDuration: hoveredWidget?.widget.tooltipAnimationDuration ??
                widget.tooltipAnimationDuration,
          );
        }),
      ],
    );
  }
}

class _SmoothHoverScope extends InheritedWidget {
  _SmoothHoverScope({
    required this.widget,
    required this.state,
  }) : super(child: widget.child);

  final SmoothHoverScope widget;
  final SmoothHoverScopeState state;

  @override
  bool updateShouldNotify(_SmoothHoverScope oldWidget) =>
      state != oldWidget.state ||
      widget.decoration != oldWidget.widget.decoration;
}

class _Ink extends StatefulWidget {
  const _Ink({
    required this.size,
    required this.target,
    required this.decoration,
    required this.physics,
    required this.animationDuration,
  });

  final Size? size;
  final Offset? target;
  final Decoration decoration;
  final Physics? physics;
  final Duration? animationDuration;

  @override
  State<_Ink> createState() => _InkState();
}

class _InkState extends State<_Ink> {
  double? _prevLeft, _prevTop;
  double _prevWidth = 0.0, _prevHeight = 0.0;

  Timer? _resetTimer;

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _resetTimer?.cancel();
    final size = widget.size;
    final target = widget.target;
    final uncertain = target == null || size == null;
    final effectiveLeft =
        _prevLeft = uncertain ? _prevLeft : target.dx - size.width / 2;
    final effectiveTop =
        _prevTop = uncertain ? _prevTop : target.dy - size.height / 2;
    final effectiveWidth = _prevWidth = size == null ? _prevWidth : size.width;
    final effectiveHeight =
        _prevHeight = size == null ? _prevHeight : size.height;
    if (uncertain &&
        !(_prevLeft == null &&
            _prevTop == null &&
            _prevWidth == 0.0 &&
            _prevHeight == 0.0)) {
      _resetTimer = Timer(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _prevLeft = null;
            _prevTop = null;
            _prevWidth = 0.0;
            _prevHeight = 0.0;
          });
        }
      });
    }
    return AnimatedPositioned(
      left: effectiveLeft,
      top: effectiveTop,
      curve: widget.physics ?? Spring.elegant,
      duration: widget.animationDuration ?? Duration(milliseconds: 450),
      child: ASizedBox(
        width: effectiveWidth,
        height: effectiveHeight,
        physics: widget.physics,
        duration: widget.animationDuration,
        child: AContainer(
          physics: widget.physics,
          duration: widget.animationDuration,
          decoration: uncertain
              ? () {
                  if (widget.decoration case final ShapeDecoration dec) {
                    return ShapeDecoration(
                      shape: dec.shape,
                      image: dec.image,
                      gradient: dec.gradient,
                      shadows: dec.shadows,
                      color: const Color.from(
                        alpha: 0.0,
                        red: 0.0,
                        green: 0.0,
                        blue: 0.0,
                      ),
                    );
                  } else if (widget.decoration case final BoxDecoration dec) {
                    return BoxDecoration(
                      image: dec.image,
                      gradient: dec.gradient,
                      border: dec.border,
                      borderRadius: dec.borderRadius,
                      boxShadow: dec.boxShadow,
                      shape: dec.shape,
                      color: const Color.from(
                        alpha: 0.0,
                        red: 0.0,
                        green: 0.0,
                        blue: 0.0,
                      ),
                    );
                  }
                  return widget.decoration;
                }()
              : widget.decoration,
        ),
      ),
    );
  }
}

class _Tooltip extends StatefulWidget {
  const _Tooltip({
    required this.childSize,
    required this.target,
    required this.decoration,
    required this.physics,
    required this.text,
    required this.span,
    required this.delay,
    required this.animationDuration,
  });

  final Size? childSize;
  final Offset? target;
  final Decoration decoration;
  final Physics? physics;
  final String? text;
  final InlineSpan? span;
  final Duration delay;
  final Duration? animationDuration;

  @override
  State<_Tooltip> createState() => __TooltipState();
}

class __TooltipState extends State<_Tooltip> {
  double? _prevLeft, _prevTop;

  Timer? _resetTimer;

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _resetTimer?.cancel();
    final childSize = widget.childSize;
    final target = widget.target;
    final uncertain = target == null || childSize == null;
    final effectiveLeft = _prevLeft = uncertain ? _prevLeft : target.dx;
    var effectiveTop = _prevTop = uncertain ? _prevTop : target.dy;
    effectiveTop = effectiveTop == null
        ? null
        : () {
            final above = effectiveTop! > MediaQuery.sizeOf(context).height / 2;
            return above
                ? effectiveTop - ((childSize?.height ?? 0) / 2) - 24.0
                : effectiveTop + ((childSize?.height ?? 0) / 2) + 24.0;
          }();
    if (uncertain && !(_prevLeft == null && _prevTop == null)) {
      _resetTimer = Timer(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        setState(() {
          _prevLeft = null;
          _prevTop = null;
        });
      });
    }
    final noText = widget.text == null && widget.span == null;
    return APositioned(
      left: effectiveLeft,
      top: effectiveTop,
      physics: widget.physics,
      duration: widget.animationDuration,
      child: Align(
        widthFactor: 0.0,
        heightFactor: 0.0,
        child: AContainer(
          physics: widget.physics,
          decoration: widget.decoration,
          duration: widget.animationDuration,
          padding: noText ? EdgeInsets.zero : EdgeInsets.all(8.0),
          child: AnimatedSwitcher(
            duration: widget.animationDuration ?? Duration(milliseconds: 300),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            transitionBuilder: (child, animation) {
              final isReversed =
                  animation.status == AnimationStatus.completed ||
                      animation.status == AnimationStatus.reverse;
              const offset = Offset(0.0, 0.5);
              return SlideTransition(
                position: Tween<Offset>(
                  begin: isReversed ? offset.scale(-1, -1) : offset,
                  end: Offset.zero,
                ).animate(animation),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            layoutBuilder: (currentChild, previousChildren) {
              return Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Visibility(
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    child: AnimatedSize(
                      duration: widget.animationDuration ??
                          Duration(milliseconds: 300),
                      curve: Curves.easeInCubic,
                      child: currentChild,
                    ),
                  ),
                  Align(
                    widthFactor: 0.0,
                    heightFactor: 0.0,
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        ...previousChildren,
                        if (currentChild != null) currentChild,
                      ],
                    ),
                  ),
                ],
              );
            },
            child: Text.rich(
              widget.span ?? TextSpan(text: widget.text),
              key: ValueKey('${widget.span}${widget.text}'),
            ),
          ),
        ),
      ),
    );
  }
}
