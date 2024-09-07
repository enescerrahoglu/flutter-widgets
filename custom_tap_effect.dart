import 'package:flutter/material.dart';

enum TapEffectType {
  touchableOpacity,
  scaleDown,
}

class CustomTapEffect extends StatefulWidget {
  final Widget child;
  final TapEffectType? effect;
  final void Function()? onTap;
  final void Function()? onLongPressed;
  final Duration duration;
  final bool vibrate;
  final HitTestBehavior? behavior;

  const CustomTapEffect({
    super.key,
    required this.child,
    required this.onTap,
    this.duration = const Duration(milliseconds: 100),
    this.vibrate = false,
    this.behavior = HitTestBehavior.opaque,
    this.effect = TapEffectType.scaleDown,
    this.onLongPressed,
  });

  @override
  State<CustomTapEffect> createState() => _CustomTapEffectState();
}

class _CustomTapEffectState extends State<CustomTapEffect> with SingleTickerProviderStateMixin {
  final double scaleActive = 0.98;
  final double opacityActive = 0.6;
  late AnimationController controller;
  late Animation<double> animation;
  late Animation<double> animation2;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: widget.duration);
    animation = Tween<double>(begin: 1, end: scaleActive).animate(controller);
    animation2 = Tween<double>(begin: 1, end: opacityActive).animate(controller);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void onTapCancel() => controller.reverse();
  void onTapDown() => controller.forward();
  void onTapUp() => controller.reverse();
  void onTap() async {
    controller.forward();
    await Future.delayed(widget.duration);
    controller.reverse().then((value) => widget.onTap!());
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onTap != null) {
      return GestureDetector(
        behavior: widget.behavior,
        onLongPress: widget.onLongPressed,
        onTapDown: (detail) => onTapDown(),
        onTapUp: (detail) => onTapUp(),
        onTapCancel: () => onTapCancel(),
        onTap: widget.onTap,
        child: buildChild(controller, animation, animation2),
      );
    } else {
      return buildChild(controller, animation, animation2);
    }
  }

  AnimatedBuilder buildChild(
    AnimationController controller,
    Animation<double> animation,
    Animation<double> animation2,
  ) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        Widget result = child ?? const SizedBox();
        switch (widget.effect) {
          case TapEffectType.scaleDown:
            result = ScaleTransition(scale: animation, child: result);
            break;
          case TapEffectType.touchableOpacity:
            result = Opacity(opacity: animation2.value, child: result);
            break;
          case null:
            break;
        }
        return result;
      },
      child: widget.child,
    );
  }
}
