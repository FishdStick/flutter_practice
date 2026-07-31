import 'package:flutter/material.dart';

class ResizeableTextArea extends StatefulWidget {
  final TextEditingController textFieldController;
  final String labelText;
  final String? Function(String?)? validator;
  final double initialHeight;
  final double minHeight;
  final double maxHeight;

  const ResizeableTextArea({
    super.key,
    required this.textFieldController,
    required this.labelText,
    this.validator,
    this.initialHeight = 160.0,
    this.minHeight = 120.0,
    this.maxHeight = 500.0,
  });

  @override
  State<ResizeableTextArea> createState() => _ResizeableTextAreaState();
}

class _ResizeableTextAreaState extends State<ResizeableTextArea> {

  late double _textFieldHeight;

  @override
  void initState(){
    super.initState();
    _textFieldHeight = _calculateInitialHeight();
  }

  double _calculateInitialHeight(){
    final text = widget.textFieldController.text;

    if(text.isEmpty){
      return  widget.initialHeight;
    }

    final lineCount = text.split('\n').fold<int>(0,(total, line) {
      return total + (line.length / 55).ceil().clamp(1, 100);
    });

    final estimatedHeight = (lineCount * 20.0) + 40.0;

    return estimatedHeight.clamp(widget.minHeight, widget.maxHeight);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _textFieldHeight,
      child: Stack(
        children: [
          TextFormField(
            controller: widget.textFieldController,
            maxLines: null,
            expands: true,
            keyboardType: TextInputType.multiline,
            textAlignVertical: TextAlignVertical.top,
            decoration: InputDecoration(
              labelText: widget.labelText,
              border: const OutlineInputBorder(),
              alignLabelWithHint: true,
              contentPadding:
              const EdgeInsets.fromLTRB(12, 16, 28, 16),
            ),
            validator: widget.validator
          ),
          Positioned(
            right: 2,
            bottom: 2,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onVerticalDragUpdate: (details) {
                setState(() {
                  _textFieldHeight =
                      (_textFieldHeight +
                          details.delta.dy)
                          .clamp(120.0, 500.0);
                });
              },
              child: const MouseRegion(
                cursor: SystemMouseCursors.resizeUpDown,
                child: Padding(
                    padding: EdgeInsets.all(6.0),
                    child: Icon(Icons.drag_indicator,
                        size: 16, color: Colors.grey)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
