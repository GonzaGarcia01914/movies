import 'package:flutter/material.dart';

class DragScrollRow extends StatefulWidget {
  const DragScrollRow({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.separatorWidth = 12,
    this.height = 260,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final double separatorWidth;
  final double height;

  @override
  State<DragScrollRow> createState() => _DragScrollRowState();
}

class _DragScrollRowState extends State<DragScrollRow> {
  final _ctrl = ScrollController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // cursor "agarre" al pasar por encima
    return MouseRegion(
      cursor: SystemMouseCursors.grab,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragUpdate: (d) {
          // mueve en sentido del drag
          _ctrl.jumpTo(
            (_ctrl.offset - d.delta.dx).clamp(
              0.0,
              _ctrl.position.maxScrollExtent,
            ),
          );
        },
        onHorizontalDragEnd: (d) {
          // un toque de inercia
          final target = (_ctrl.offset - d.velocity.pixelsPerSecond.dx / 2)
              .clamp(0.0, _ctrl.position.maxScrollExtent);
          _ctrl.animateTo(
            target,
            duration: const Duration(milliseconds: 250),
            curve: Curves.decelerate,
          );
        },
        child: SizedBox(
          height: widget.height,
          child: ListView.separated(
            controller: _ctrl,
            scrollDirection: Axis.horizontal,
            // evitamos que el ListView intente capturar el drag
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (c, i) => widget.itemBuilder(c, i),
            separatorBuilder: (_, __) => SizedBox(width: widget.separatorWidth),
            itemCount: widget.itemCount,
          ),
        ),
      ),
    );
  }
}
