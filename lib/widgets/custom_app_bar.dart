import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showUserInfo;
  final String? prenom;

  const CustomAppBar({
    Key? key,
    this.title = '',
    this.actions,
    this.showUserInfo = true,
    this.prenom,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      iconTheme: const IconThemeData(color: Colors.black),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (showUserInfo) _buildUserInfo(),
          const Spacer(),
          if (title.isNotEmpty)
            Text(
              title,
              style: TextStyle(
                color: AppColors.primaryColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          const Spacer(),
          // Logo GymTech avec ses dimensions d'origine
          Image.asset(
            'assets/images/gymtech_logo.png',
            width: null, // Utilise la largeur d'origine
            height: kToolbarHeight * 0.8, // 80% de la hauteur de l'AppBar
            fit: BoxFit.scaleDown, // Conserve les proportions d'origine
          ),
        ],
      ),
      elevation: 2,
      shadowColor: Colors.black12,
      actions: const [
        SizedBox(width: 15), // Pour équilibrer l'espace avec le logo à droite
      ],
    );
  }

  Widget _buildUserInfo() {
    return Row(
      children: [
        // Icône utilisateur en noir
        const Icon(
          Icons.person_outline,
          color: Colors.black,
          size: 28,
        ),
        if (prenom?.isNotEmpty ?? false) ...[
          const SizedBox(width: 8),
          Text(
            prenom!,
            style: TextStyle(
              color: AppColors.primaryColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
