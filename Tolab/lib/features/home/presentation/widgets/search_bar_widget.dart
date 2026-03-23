import 'dart:ui';

import 'package:flutter/cupertino.dart';
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE2EAF6)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A0E2A47),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: TextField(
              onChanged: onChanged,
              decoration: const InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(color: Color(0xFF7D8BA0)),
                prefixIcon: Icon(
                  CupertinoIcons.search,
                  color: Color(0xFF3469C8),
                  size: 20,
                ),
                suffixIcon: Padding(
                  padding: EdgeInsets.all(10),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Color(0xFFF1F6FF),
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        CupertinoIcons.slider_horizontal_3,
                        size: 18,
                        color: Color(0xFF3469C8),
                      ),
                    ),
                  ),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 18),
              ).copyWith(hintText: hintText),
            ),
          ),
        ),
      ),
    );
  }
}
