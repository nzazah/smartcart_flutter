import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../provider/cart_provider.dart';
import '../theme_notifier.dart';
import 'edit_profile_page.dart';
import 'cart_history_page.dart';

class ProfilePage extends StatefulWidget {
  final VoidCallback onLogout;

  const ProfilePage({super.key, required this.onLogout});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = '';
  String email = '';
  String phone = '';

  @override
  void initState() {
    super.initState();
    _loadUserDataFromSupabase();
  }

  Future<void> _loadUserDataFromSupabase() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final response = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      setState(() {
        name = response['name'] ?? 'Guest';
        email = user.email ?? 'Not available';
        phone = response['phone'] ?? 'Not set';
      });
    }
  }

  Future<void> _handleLogout() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.clearCart();
    await Supabase.instance.client.auth.signOut();
    widget.onLogout();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDarkMode = themeNotifier.currentTheme == ThemeMode.dark;
    final width = MediaQuery.of(context).size.width;

    final bool isTablet = width >= 600;
    final double avatarSize = isTablet ? 80 : 50;
    final double headerFontSize = isTablet ? 22 : 18;
    final double subHeaderFontSize = isTablet ? 16 : 14;
    final double titleFontSize = isTablet ? 18 : 16;
    final double iconSize = isTablet ? 28 : 24;
    final double padding = isTablet ? 24 : 16;

    final body = SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: padding),
        child: Column(
          children: [
            _buildProfileHeader(context, avatarSize, headerFontSize, subHeaderFontSize),
            const SizedBox(height: 24),
            _buildProfileMenu(context, iconSize, titleFontSize),
            const Divider(),
            Platform.isIOS
                ? _buildCupertinoSwitch(
              "Dark Mode",
              isDarkMode,
                  (value) {
                themeNotifier.setTheme(value ? ThemeMode.dark : ThemeMode.light);
              },
              iconSize,
              titleFontSize,
            )
                : SwitchListTile(
              title: Text("Dark Mode", style: TextStyle(fontSize: titleFontSize)),
              secondary: Icon(Icons.brightness_6, size: iconSize),
              value: isDarkMode,
              onChanged: (value) {
                themeNotifier.setTheme(value ? ThemeMode.dark : ThemeMode.light);
              },
            ),
          ],
        ),
      ),
    );

    return Platform.isIOS
        ? CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("Profile", style: TextStyle(fontSize: headerFontSize)),
      ),
      child: body,
    )
        : Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          "Profile",
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: headerFontSize,
          ),
        ),
        centerTitle: true,
      ),
      body: body,
    );
  }

  Widget _buildProfileHeader(
      BuildContext context, double avatarSize, double headerFontSize, double subHeaderFontSize) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(color: Colors.grey.shade300, blurRadius: 5, spreadRadius: 2),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: avatarSize,
            backgroundImage: const AssetImage("assets/profile.jpg"),
          ),
          const SizedBox(height: 16),
          Text(name, style: TextStyle(fontSize: headerFontSize, fontWeight: FontWeight.bold)),
          Text(email, style: TextStyle(fontSize: subHeaderFontSize, color: Colors.grey)),
          Text("Phone: $phone", style: TextStyle(fontSize: subHeaderFontSize, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildProfileMenu(BuildContext context, double iconSize, double fontSize) {
    return Column(
      children: [
        _buildMenuItem(Icons.edit, "Edit Profile", () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EditProfilePage()),
          );
          _loadUserDataFromSupabase();
        }, iconSize, fontSize),
        _buildMenuItem(Icons.history, "Shopping History", () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CartHistoryPage()),
          );
        }, iconSize, fontSize),
        _buildMenuItem(Icons.settings, "Settings", () {}, iconSize, fontSize),
        _buildMenuItem(Icons.logout, "Log Out", _handleLogout, iconSize, fontSize, isLogout: true),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap, double iconSize,
      double fontSize, {bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon, color: isLogout ? Colors.deepPurple : null, size: iconSize),
      title: Text(
        title,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: isLogout ? FontWeight.bold : FontWeight.normal,
          color: isLogout ? Colors.deepPurple : null,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: iconSize * 0.6, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildCupertinoSwitch(String title, bool value, ValueChanged<bool> onChanged,
      double iconSize, double fontSize) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(CupertinoIcons.brightness, size: iconSize),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontSize: fontSize),
            ),
          ),
          CupertinoSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
