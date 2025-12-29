import 'package:flutter/material.dart';
import 'package:ouendi/app/controllers/inactivity_service.dart';

class InactivityScope extends StatefulWidget {
  final Widget child;
  final bool enable;

  const InactivityScope({
    super.key,
    required this.child,
    this.enable = true,
  });

  @override
  State<InactivityScope> createState() => _InactivityScopeState();
}

class _InactivityScopeState extends State<InactivityScope> {
  final inactivity = InactivityService();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    inactivity.setContext(context); // stocker un context valide et monté
  }

  @override
  void dispose() {
    inactivity.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.enable) {
      inactivity.start();
    } else {
      inactivity.stop();
    }

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => inactivity.userActivityDetected(),
      onPointerMove: (_) => inactivity.userActivityDetected(),
      onPointerHover: (_) => inactivity.userActivityDetected(),
      child: widget.child,
    );
  }
}
