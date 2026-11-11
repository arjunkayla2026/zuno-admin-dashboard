import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';

class AppPageRoute<T> extends PageRoute<T> {
  AppPageRoute({
    required this.builder,
    required RouteSettings super.settings,
    this.fadeIn = false,
  });

  final WidgetBuilder builder;
  final bool fadeIn;

  static final Animatable<double> _fadeCurve = CurveTween(
    curve: AppTheme.pageTransitionCurve,
  );

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration =>
      fadeIn ? AppTheme.pageTransitionDuration : Duration.zero;

  @override
  Duration get reverseTransitionDuration => Duration.zero;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) => builder(context);

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (!fadeIn) return child;
    return FadeTransition(opacity: animation.drive(_fadeCurve), child: child);
  }
}
