// lib/apps/tolab_student_desktop/lib/src/dashboard/widgets/student_sidebar.dart

import 'package:flutter/material.dart';
import '../ui/student_nav_item_data.dart';

class StudentSidebar extends StatelessWidget {
  final List<StudentNavItemData> items;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final bool isCollapsed;
  final VoidCallback? onLogoTap;

  // تقدر لاحقاً تمرّرهم من الـ Home Page أو من fake_data
  final String studentName;
  final String studentEmail;

  const StudentSidebar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.studentName,
    required this.studentEmail,
    this.isCollapsed = false,
    this.onLogoTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      width: isCollapsed ? 80 : 260,
      decoration: const BoxDecoration(
        color: Color(0xFF020617),
        border: Border(right: BorderSide(color: Color(0xFF1E293B), width: 1)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),

          _buildLogo(),

          const SizedBox(height: 16),

          // ====== بروفايل الطالب + الملفات ======
          _buildStudentProfileSection(),

          const SizedBox(height: 16),

          // قائمة الناف
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 8 : 16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isActive = index == selectedIndex;
                return _NavItem(
                  icon: item.icon,
                  label: item.label,
                  isActive: isActive,
                  isCollapsed: isCollapsed,
                  onTap: () => onItemSelected(index),
                );
              },
            ),
          ),

          if (!isCollapsed)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                '© 2025 EduHuB',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return GestureDetector(
      onTap: onLogoTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: isCollapsed ? 8 : 16),
          padding: EdgeInsets.symmetric(
            horizontal: isCollapsed ? 8 : 16,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF020617),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF1E293B)),
          ),
          child: Row(
            mainAxisAlignment: isCollapsed
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 32,
                child: Image.asset(
                  'assets/icons/logo-horizontal.png',
                  fit: BoxFit.contain,
                ),
              ),
              if (!isCollapsed) ...[
                const SizedBox(width: 8),
                const Text(
                  'EduHuB',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// ====== بروفايل الطالب + شريط الملفات ======
  Widget _buildStudentProfileSection() {
    if (isCollapsed) {
      // في حالة الـ collapse: نعرض الأفاتار فقط
      return CircleAvatar(
        radius: 24,
        backgroundColor: const Color(0xFF1E293B),
        child: Text(
          _initialsFromName(studentName),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    // حالة الـ expanded
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الصف الأول: صورة + اسم + إيميل
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFF1E293B),
                child: Text(
                  _initialsFromName(studentName),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      studentName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      studentEmail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // الصف الثاني: ملفات نازلة (chips أفقية)
          SizedBox(
            height: 30,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                _FileChip(
                  icon: Icons.picture_as_pdf_rounded,
                  label: 'OS Lecture 1.pdf',
                ),
                SizedBox(width: 6),
                _FileChip(
                  icon: Icons.video_library_rounded,
                  label: 'DS Tutorial 02.mp4',
                ),
                SizedBox(width: 6),
                _FileChip(
                  icon: Icons.assignment_turned_in_rounded,
                  label: 'AI HW #1.docx',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _initialsFromName(String name) {
    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts.first.isNotEmpty ? parts.first[0].toUpperCase() : 'S';
    }
    final first = parts[0].isNotEmpty ? parts[0][0] : '';
    final last = parts[1].isNotEmpty ? parts[1][0] : '';
    final res = (first + last).toUpperCase();
    return res.isEmpty ? 'S' : res;
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool isCollapsed;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isCollapsed,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? Colors.white : const Color(0xFF94A3B8);
    final bgColor = isActive ? const Color(0xFF0F172A) : Colors.transparent;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isCollapsed ? 12 : 10,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: isCollapsed
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: color),
              if (!isCollapsed) ...[
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FileChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FileChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 13, color: const Color(0xFF38BDF8)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(color: Color(0xFFCBD5F5), fontSize: 10),
          ),
        ],
      ),
    );
  }
}
