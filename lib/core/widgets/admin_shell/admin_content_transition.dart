import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/navigation/app_routes.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';

class AdminContentTransition extends StatefulWidget {
  const AdminContentTransition({super.key, required this.child});

  final Widget child;

  @override
  State<AdminContentTransition> createState() => _AdminContentTransitionState();
}

class _AdminContentTransitionState extends State<AdminContentTransition>
    with SingleTickerProviderStateMixin, RouteAware {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppTheme.pageTransitionDuration,
  );
  late final CurvedAnimation _progress = CurvedAnimation(
    parent: _controller,
    curve: AppTheme.pageTransitionCurve,
  );

  PageRoute<dynamic>? _route;
  bool _reduceMotion = false;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    final route = ModalRoute.of(context);
    if (route is PageRoute && route != _route) {
      AppRoutes.observer.unsubscribe(this);
      _route = route;
      AppRoutes.observer.subscribe(this, route);
    }
    if (!_started) {
      _started = true;
      _play();
    }
  }

  @override
  void didPopNext() => _play();

  void _play() {
    if (_reduceMotion) {
      _controller.value = 1;
    } else {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    AppRoutes.observer.unsubscribe(this);
    _progress.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _progress,
      child: AnimatedBuilder(
        animation: _progress,
        builder: (context, child) => Transform.translate(
          offset: Offset(
            0,
            (1 - _progress.value) * AppTheme.pageTransitionOffset,
          ),
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}
