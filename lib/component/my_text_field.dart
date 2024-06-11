import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final bool? obscure;
  final FocusNode? focusNode;

  const MyTextField({
    super.key,
    this.obscure,
    required this.hintText,
    this.controller,
    this.focusNode
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
            ),
          ],
        ),
        child: TextField(
          style: const TextStyle(
            color: Colors.black87,
          ),
          obscureText: obscure!,
          controller: controller,
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.purpleAccent.shade400),
            ),
            border: InputBorder.none,
            hintText: hintText,
            hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
        ),
      ),
    );
  }
}