import 'package:flutter/material.dart';

/// A pill-styled text field (styled via [InputDecorationTheme]).
class LedgerTextField extends StatelessWidget {
  const LedgerTextField({
    super.key,
    required this.controller,
    required this.label,
    this.errorText,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.prefixIcon,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String? errorText;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final IconData? prefixIcon;
  final void Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
      ),
    );
  }
}

/// Same pill styling, with a visibility toggle for password entry.
class LedgerPasswordField extends StatefulWidget {
  const LedgerPasswordField({
    super.key,
    required this.controller,
    required this.label,
    this.errorText,
    this.prefixIcon = Icons.lock_outline,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String? errorText;
  final IconData? prefixIcon;
  final void Function(String)? onChanged;

  @override
  State<LedgerPasswordField> createState() => _LedgerPasswordFieldState();
}

class _LedgerPasswordFieldState extends State<LedgerPasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscure,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        labelText: widget.label,
        errorText: widget.errorText,
        prefixIcon: widget.prefixIcon == null ? null : Icon(widget.prefixIcon),
        suffixIcon: IconButton(
          icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
    );
  }
}
