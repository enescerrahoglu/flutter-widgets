part of 'defer_pointer.dart';

class DeferredPointerHandler extends StatefulWidget {
  const DeferredPointerHandler({super.key, required this.child, this.link});
  final Widget child;
  final DeferredPointerHandlerLink? link;
  @override
  DeferredPointerHandlerState createState() => DeferredPointerHandlerState();

  static DeferredPointerHandlerState of(BuildContext context) {
    final inherited = context.dependOnInheritedWidgetOfExactType<_InheritedDeferredPaintSurface>();
    assert(inherited != null, 'DeferredPaintSurface was not found on this context.');
    return inherited!.state;
  }
}

class DeferredPointerHandlerState extends State<DeferredPointerHandler> {
  final DeferredPointerHandlerLink _link = DeferredPointerHandlerLink();
  get link => _link;

  @override
  void didUpdateWidget(covariant DeferredPointerHandler oldWidget) {
    if (widget.link != null) {
      _link.removeAll();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedDeferredPaintSurface(
      state: this,
      child: DeferredHitTargetRenderObjectWidget(link: widget.link ?? _link, child: widget.child),
    );
  }
}

class DeferredHitTargetRenderObjectWidget extends SingleChildRenderObjectWidget {
  const DeferredHitTargetRenderObjectWidget({required this.link, super.child, super.key});

  final DeferredPointerHandlerLink link;

  @override
  RenderObject createRenderObject(BuildContext context) => DeferredHitTargetRenderObject(link);

  @override
  void updateRenderObject(BuildContext context, DeferredHitTargetRenderObject renderObject) => renderObject.link = link;
}

class DeferredHitTargetRenderObject extends RenderProxyBox {
  DeferredHitTargetRenderObject(DeferredPointerHandlerLink link, [RenderBox? child]) : super(child) {
    this.link = link;
  }

  DeferredPointerHandlerLink? _link;
  DeferredPointerHandlerLink get link => _link!;
  set link(DeferredPointerHandlerLink link) {
    if (_link != null) {
      _link!.removeListener(markNeedsPaint);
    }
    _link = link;
    this.link.addListener(markNeedsPaint);
    markNeedsPaint();
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    for (final painter in link.painters.reversed) {
      final hit = result.addWithPaintTransform(
        transform: painter.child!.getTransformTo(this),
        position: position,
        hitTest: (BoxHitTestResult result, Offset? position) {
          return painter.child!.hitTest(result, position: position!);
        },
      );
      if (hit) {
        return true;
      }
    }
    return child?.hitTest(result, position: position) ?? false;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);
    for (final painter in link.painters) {
      if (painter.deferPaint == false) continue;
      context.paintChild(
        painter.child!,
        painter.child!.localToGlobal(Offset.zero, ancestor: this) + offset,
      );
    }
  }
}

class _InheritedDeferredPaintSurface extends InheritedWidget {
  const _InheritedDeferredPaintSurface({required super.child, required this.state});

  final DeferredPointerHandlerState state;
  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}
