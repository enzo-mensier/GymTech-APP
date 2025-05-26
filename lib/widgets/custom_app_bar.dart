import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/colors.dart';
import '../utils/text_styles.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final bool showUserInfo;

  const CustomAppBar({
    Key? key,
    this.title = '',
    this.actions,
    this.showBackButton = false,
    this.showUserInfo = true,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: showBackButton,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (showUserInfo) _buildUserInfo(),
          if (title.isNotEmpty)
            Text(
              title,
              style: AppTextStyles.medium.copyWith(
                color: AppColors.primaryColor,
                fontSize: 18,
              ),
            )
          else
            const Spacer(),
          Image.asset(
            'assets/images/gymtech_logo.png',
            width: 45,
            fit: BoxFit.contain,
          ),
        ],
      ),
      backgroundColor: AppColors.backgroundColor,
      elevation: 0,
      actions: actions,
    );
  }

  Widget _buildUserInfo() {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        final prefs = snapshot.data!;
        final email = prefs.getString('email') ?? 'Mon Compte';

        return Row(
          children: [
            Icon(Icons.person_outline, color: AppColors.textColor, size: 20),
            const SizedBox(width: 8),
            Text(
              email,
              style: AppTextStyles.medium.copyWith(
                color: AppColors.primaryColor,
                fontSize: 16,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        );
      },
    );
  }
}
