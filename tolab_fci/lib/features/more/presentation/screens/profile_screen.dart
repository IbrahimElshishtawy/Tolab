import 'package:flutter/material.dart';
import 'package:tolab_fci/features/more/presentation/widgets/lang_card.dart';
import 'package:tolab_fci/features/more/presentation/widgets/personal_info_card.dart';
import 'package:tolab_fci/features/more/presentation/widgets/profile_avatar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F4F4),
      body: Stack(
        children: [
          /// 🔹 Top Gradient Background
          Container(
            height: 180,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xff0F2B6B), Color(0xff1B4DB1)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          /// 🔹 Main Content
          SafeArea(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 60),

                  /// Avatar
                  const ProfileAvatar(),

                  const SizedBox(height: 12),

                  const Text(
                    "أحمد محمد السيد",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  ),

                  const Text(
                    "طالب جامعي",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),

                  const SizedBox(height: 16),

                  /// Cards
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          Directionality(
                            textDirection: TextDirection.rtl,
                            child: PersonalInfoCard(),
                          ),
                          SizedBox(height: 12),
                          Directionality(
                            textDirection: TextDirection.rtl,
                            child: LanguageCard(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
