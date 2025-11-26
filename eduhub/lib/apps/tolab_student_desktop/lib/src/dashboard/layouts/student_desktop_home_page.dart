// TODO Implement this library.
// lib/apps/tolab_student_desktop/lib/src/dashboard/layouts/student_desktop_home_page.dart
import 'package:flutter/material.dart';

class StudentDesktopHomePage extends StatelessWidget {
  const StudentDesktopHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // ==== Sidebar ====
          Container(
            width: 260,
            decoration: const BoxDecoration(
              color: Color(0xFF020617),
              border: Border(
                right: BorderSide(color: Color(0xFF1E293B), width: 1),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 32),
                _buildLogo(),
                const SizedBox(height: 32),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: const [
                      _NavItem(
                        icon: Icons.home_rounded,
                        label: 'Home',
                        isActive: true,
                      ),
                      _NavItem(
                        icon: Icons.menu_book_rounded,
                        label: 'Academic Subjects',
                      ),
                      _NavItem(
                        icon: Icons.schedule_rounded,
                        label: 'Class Schedule',
                      ),
                      _NavItem(
                        icon: Icons.people_alt_rounded,
                        label: 'Tolab Community',
                      ),
                      _NavItem(
                        icon: Icons.notifications_rounded,
                        label: 'Notifications',
                      ),
                      _NavItem(icon: Icons.person_rounded, label: 'My Profile'),
                      _NavItem(icon: Icons.more_horiz_rounded, label: 'More'),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    '© 2025 TOLAB',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                  ),
                ),
              ],
            ),
          ),

          // ==== Main Content ====
          Expanded(
            child: Column(
              children: [
                _buildTopBar(context),
                const Divider(height: 1, color: Color(0xFF1E293B)),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left column: account details + upcoming lectures
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              _AccountDetailsCard(),
                              SizedBox(height: 24),
                              _UpcomingLecturesCard(),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        // Right column: calendar + quizzes
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              _DayCalendarCard(),
                              SizedBox(height: 24),
                              _UpcomingQuizzesCard(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: const LinearGradient(
              colors: [Color(0xFF22C55E), Color(0xFF3B82F6)],
            ),
          ),
          alignment: Alignment.center,
          child: const Text(
            'T',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'TOLAB',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      color: const Color(0xFF020617),
      child: Row(
        children: [
          const Text(
            'Home',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFF1E293B)),
            ),
            child: const Text(
              'Student Desktop',
              style: TextStyle(color: Color(0xFF38BDF8), fontSize: 11),
            ),
          ),
          const Spacer(),
          // هنا لاحقاً نعرض اسم الطالب وصورته
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              const CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFF1E293B),
                child: Text('S', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 8),
              const Text(
                'Student Name',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ================== Widgets داخل نفس الملف ==================

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;

  const _NavItem({
    required this.icon,
    required this.label,
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
        onTap: () {
          // TODO: ربط بالـ routing لاحقاً
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: color),
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
          ),
        ),
      ),
    );
  }
}

class _AccountDetailsCard extends StatelessWidget {
  const _AccountDetailsCard();

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      title: 'Account details',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _DetailRow(label: 'Student name', value: 'Student Name'),
          _DetailRow(label: 'Department', value: 'Computer Science'),
          _DetailRow(label: 'Academic year', value: 'Second Year'),
        ],
      ),
    );
  }
}

class _UpcomingLecturesCard extends StatelessWidget {
  const _UpcomingLecturesCard();

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      title: 'Upcoming online lectures',
      child: Column(
        children: const [
          _ListItemRow(
            title: 'Data Structures',
            subtitle: 'Dr. Ahmed Hassan',
            trailing: 'Today 10:00 AM',
          ),
          SizedBox(height: 8),
          _ListItemRow(
            title: 'Operating Systems',
            subtitle: 'Dr. Sara Ali',
            trailing: 'Tomorrow 12:00 PM',
          ),
        ],
      ),
    );
  }
}

class _UpcomingQuizzesCard extends StatelessWidget {
  const _UpcomingQuizzesCard();

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      title: 'Upcoming online quizzes',
      child: Column(
        children: const [
          _ListItemRow(
            title: 'Database Quiz 1',
            subtitle: 'Assistant: Mohamed',
            trailing: 'Thu 03:00 PM',
          ),
          SizedBox(height: 8),
          _ListItemRow(
            title: 'Math Quiz 2',
            subtitle: 'Assistant: Ali',
            trailing: 'Sun 09:00 AM',
          ),
        ],
      ),
    );
  }
}

class _DayCalendarCard extends StatelessWidget {
  const _DayCalendarCard();

  @override
  Widget build(BuildContext context) {
    // Placeholder لعرض أيام الأسبوع – هنوصلها بالـ schedule بعدين
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return _CardShell(
      title: 'Day calendar',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: days
            .map(
              (d) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    d,
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: d == 'Wed'
                          ? const Color(0xFF22C55E)
                          : const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      d == 'Wed' ? '27' : '--',
                      style: TextStyle(
                        color: d == 'Wed' ? Colors.black : Colors.white,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  final String title;
  final Widget child;

  const _CardShell({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF020617),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B)),
        boxShadow: const [
          BoxShadow(
            blurRadius: 18,
            offset: Offset(0, 8),
            color: Colors.black54,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ListItemRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final String trailing;

  const _ListItemRow({
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF020617),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            trailing,
            style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 11),
          ),
        ],
      ),
    );
  }
}
