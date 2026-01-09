import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/settings_service.dart';
import '../../services/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _autoLogin = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final autoLogin = await SettingsService.getAutoLogin();
    setState(() {
      _autoLogin = autoLogin;
      _isLoading = false;
    });
  }

  Future<void> _setAutoLogin(bool value) async {
    setState(() => _autoLogin = value);
    await SettingsService.setAutoLogin(value);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Column(
        children: [
          // Header with gradient
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [const Color(0xFF1E1E1E), const Color(0xFF121212)]
                    : [const Color(0xFFE4002B), const Color(0xFFB80024)],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                        ),
                        const Expanded(
                          child: Text(
                            'Pengaturan',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 48), // Balance the back button
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.settings,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Settings Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      // Dark Mode Setting
                      _buildSettingCard(
                        icon: Icons.dark_mode,
                        title: 'Mode Gelap',
                        subtitle: 'Menggunakan tema gelap untuk aplikasi',
                        trailing: Switch(
                          value: themeProvider.isDarkMode,
                          onChanged: (value) => themeProvider.setDarkMode(value),
                          activeColor: const Color(0xFFE4002B),
                        ),
                        isDark: isDark,
                      ),
                      const SizedBox(height: 16),

                      // Auto Login Setting
                      _buildSettingCard(
                        icon: Icons.login,
                        title: 'Login Otomatis',
                        subtitle: 'Tetap login saat membuka aplikasi',
                        trailing: Switch(
                          value: _autoLogin,
                          onChanged: _setAutoLogin,
                          activeColor: const Color(0xFFE4002B),
                        ),
                        isDark: isDark,
                      ),
                      const SizedBox(height: 32),

                      // Info Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.grey[850]
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Login otomatis akan aktif secara default setelah Anda login. Matikan jika Anda ingin selalu diminta login saat membuka aplikasi.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE4002B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFFE4002B)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
