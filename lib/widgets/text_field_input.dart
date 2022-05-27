import 'package:flutter/material.dart';

class TextFieldInput extends StatefulWidget {
  final TextEditingController textEditingController;
  final String hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? errorText;
  final Function(String) onChanged;

  const TextFieldInput(
      {Key? key,
      required this.textEditingController,
      this.obscureText = false,
      required this.hintText,
      required this.keyboardType,
      this.errorText,
      required this.onChanged})
      : super(key: key);

  @override
  State<TextFieldInput> createState() => _TextFieldInputState();
}

class _TextFieldInputState extends State<TextFieldInput> {
  @override
  Widget build(BuildContext context) {
    final inputBorder =
        OutlineInputBorder(borderSide: Divider.createBorderSide(context));
    return TextField(
      controller: widget.textEditingController,
      decoration: InputDecoration(
        hintText: widget.hintText,
        border: inputBorder,
        focusedBorder: inputBorder,
        enabledBorder: inputBorder,
        filled: true,
        contentPadding: const EdgeInsets.all(10),
        errorText: widget.errorText,
      ),
      keyboardType: widget.keyboardType,
      obscureText: widget.obscureText,
      onChanged: widget.onChanged,
    );
  }
}
