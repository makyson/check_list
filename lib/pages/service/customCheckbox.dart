
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class CustomCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final bool? initialValue;

  const CustomCheckbox({
    Key? key,
    required this.value,
    required this.onChanged, this.initialValue,
  }) : super(key: key);

  @override
  _CustomCheckboxState createState() => _CustomCheckboxState();
}

class _CustomCheckboxState extends State<CustomCheckbox> {

  @override
  void initState() {
    super.initState();
    if(widget.initialValue != null){
      widget.onChanged(widget.initialValue!);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onChanged(!widget.value);
      },
      child: Container(
        width: 24, // Adjust the size as needed
        height: 24,

        decoration: BoxDecoration(
          shape: BoxShape.rectangle, // Use BoxShape.circle
          color: widget.value ? Color.fromRGBO(149, 13, 255, 1.0) : Colors.transparent,
          border: Border.all(
            color:  widget.value ?
            Color.fromRGBO(149, 13, 255, 1.0) :

            Color.fromRGBO(94, 94, 94, 1.0) ,
            width: 2.0,
          ),
        ),
        child: widget.value
            ? Icon(
          Icons.check,
          size: 20,
          color: Color.fromRGBO(255, 255, 255, 1.0),
        )
            : null,
      ),
    );
  }
}

