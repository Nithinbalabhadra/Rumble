import 'package:flutter/material.dart';

class DraggableCard extends StatefulWidget {
  final String cardId;
  final String label;
  final Offset initialPosition;
  final ValueChanged<Offset>? onDragEnd;

  const DraggableCard({
    super.key,
    required this.cardId,
    required this.label,
    this.initialPosition = const Offset(40, 400),
    this.onDragEnd,
  });

  @override
  State<DraggableCard> createState() => _DraggableCardState();
}

class _DraggableCardState extends State<DraggableCard> {
  late Offset pos;

  @override
  void initState() {
    super.initState();
    pos = widget.initialPosition;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: pos.dx,
      top: pos.dy,
      child: GestureDetector(
        onPanUpdate: (d) => setState(() => pos += d.delta),
        onPanEnd: (_) => widget.onDragEnd?.call(pos),
        child: Card(
          child: SizedBox(
            width: 60,
            height: 90,
            child: Center(child: Text(widget.label)),
          ),
        ),
      ),
    );
  }
}
