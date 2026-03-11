// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;

  const SearchBarWidget({
    super.key,
    this.hintText = 'Search for courses, materials...',
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2EAF6)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A0E2A47),
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: TextField(
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Color(0xFF7D8BA0)),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: Color(0xFF3469C8),
            ),
            suffixIcon: const Padding(
              padding: EdgeInsets.all(12),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0xFFF1F6FF),
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                ),
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    Icons.tune_rounded,
                    size: 18,
                    color: Color(0xFF3469C8),
                  ),
                ),
              ),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
          ),
        ),
      ),
    );
  }
}
