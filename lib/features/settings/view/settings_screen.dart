import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

import '../../auth/controller/auth_controller.dart';
import '../../auth/view/auth_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthController _authController = AuthController();
  bool _isSecurityEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkSecurityStatus();
  }

  Future<void> _checkSecurityStatus() async {
    final hasPin = await _authController.hasPin();
    if (mounted) {
      setState(() {
        _isSecurityEnabled = hasPin;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ClipPath(
            clipper: _HeaderCurveClipper(),
            child: Container(
              height: 240,
              width: double.infinity,
              color: AppColors.primary,
              child: const SafeArea(
                child: Center(
                  child: Text(
                    "Settings",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildSecurityItem(),
                _buildItem(Icons.notifications_outlined, "Notifications"),
                _buildItem(Icons.person_outline, "About"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityItem() {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.security, color: Colors.black54),
      ),
      title: const Text("Security"),
      trailing: Switch(
        value: _isSecurityEnabled,
        activeThumbColor: AppColors.primary,
        onChanged: (value) async {
          if (value) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AuthScreen(isSetupMode: true),
              ),
            );
            _checkSecurityStatus();
          } else {
            await _authController.removePin();
            _checkSecurityStatus();
          }
        },
      ),
    );
  }

  Widget _buildItem(IconData icon, String text) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.black54),
      ),
      title: Text(text),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }
}

class _HeaderCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 50);
    var controlPoint = Offset(size.width / 2, size.height + 30);
    var endPoint = Offset(size.width, size.height - 50);
    path.quadraticBezierTo(
      controlPoint.dx,
      controlPoint.dy,
      endPoint.dx,
      endPoint.dy,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
