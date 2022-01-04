import 'package:flutter/material.dart';

class CustomPageRoute extends PageRouteBuilder {
  final Widget child;
  final AxisDirection direction;

  CustomPageRoute({required this.child, required this.direction})
      : super(
            transitionDuration: const Duration(milliseconds: 320),
            reverseTransitionDuration: const Duration(milliseconds: 320),
            pageBuilder: (context, animation, secondaryAnimation) => child);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    // TODO: implement buildTransitions
    return SlideTransition(
      position: Tween<Offset>(begin: getBeginOffset(), end: Offset.zero)
          .animate(animation),
      child: child,
    );
  }

  Offset getBeginOffset() {
    switch (direction) {
      case AxisDirection.down:
        return Offset(0, -1);
      case AxisDirection.up:
        return Offset(0, 1);
      case AxisDirection.left:
        return Offset(-1, 0);
      case AxisDirection.right:
        return Offset(1, 0);
    }
  }
}
