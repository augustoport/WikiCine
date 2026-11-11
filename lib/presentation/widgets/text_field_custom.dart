import 'package:flutter/material.dart';

class TextFieldCustom extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool? isPassword;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;

  final Function(String) onChanged;

  const TextFieldCustom({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onChanged,
    this.isPassword,
    this.padding,
    this.margin, this.backgroundColor,
  });

  @override
  State<TextFieldCustom> createState() => _TextFieldCustomState();
}

class _TextFieldCustomState extends State<TextFieldCustom> {
  late bool obscureText = widget.isPassword ?? false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 10),
      margin: widget.margin ?? const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: widget.controller,
              obscureText: obscureText,
              decoration: InputDecoration(
                hintText: widget.hintText,
                contentPadding: const EdgeInsets.only(left: 15),
                border: InputBorder.none,
              ),
              onChanged: widget.onChanged,
            ),
          ),
          if (widget.isPassword == true) ...[
            IconButton(
              onPressed: () {
                setState(() {
                  obscureText = !obscureText;
                });
              },
              icon: Icon(
                obscureText ? Icons.visibility : Icons.visibility_off,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
