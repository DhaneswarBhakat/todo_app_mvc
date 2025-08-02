import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/theme_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isTablet ? 800 : double.infinity,
          ),
          child: ListView(
            padding: EdgeInsets.all(isTablet ? 32 : 16),
            children: [
              // Authentication Section
              _buildSection(
                context,
                title: 'Authentication',
                icon: Icons.security,
                children: [
                  Consumer<AuthService>(
                    builder: (context, authService, child) {
                      return ListTile(
                        leading: Icon(
                          Icons.fingerprint,
                          size: isTablet ? 28 : 24,
                        ),
                        title: Text(
                          'Biometric Authentication',
                          style: TextStyle(
                            fontSize: isTablet ? 18 : 16,
                          ),
                        ),
                        subtitle: Text(
                          authService.isBiometricAvailable
                              ? 'Available'
                              : 'Not available on this device',
                          style: TextStyle(
                            fontSize: isTablet ? 14 : 12,
                          ),
                        ),
                        trailing: Switch(
                          value: authService.isAuthenticated,
                          onChanged: (value) {
                            if (value) {
                              _showEnableBiometricDialog(context, authService);
                            } else {
                              _showDisableBiometricDialog(context, authService);
                            }
                          },
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.logout,
                      size: isTablet ? 28 : 24,
                    ),
                    title: Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                      ),
                    ),
                    subtitle: Text(
                      'Sign out and require authentication',
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 12,
                      ),
                    ),
                    onTap: () => _showLogoutDialog(context),
                  ),
                ],
              ),
              
              SizedBox(height: isTablet ? 32 : 24),
              
              // Appearance Section
              _buildSection(
                context,
                title: 'Appearance',
                icon: Icons.palette,
                children: [
                  Consumer<ThemeService>(
                    builder: (context, themeService, child) {
                      return ListTile(
                        leading: Icon(
                          Icons.dark_mode,
                          size: isTablet ? 28 : 24,
                        ),
                        title: Text(
                          'Dark Mode',
                          style: TextStyle(
                            fontSize: isTablet ? 18 : 16,
                          ),
                        ),
                        subtitle: Text(
                          'Toggle between light and dark theme',
                          style: TextStyle(
                            fontSize: isTablet ? 14 : 12,
                          ),
                        ),
                        trailing: Switch(
                          value: themeService.isDarkMode,
                          onChanged: (value) {
                            themeService.toggleTheme();
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
              
              SizedBox(height: isTablet ? 32 : 24),
              
              // About Section
              _buildSection(
                context,
                title: 'About',
                icon: Icons.info,
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.apps,
                      size: isTablet ? 28 : 24,
                    ),
                    title: Text(
                      'App Version',
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                      ),
                    ),
                    subtitle: Text(
                      '1.0.0',
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 12,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.description,
                      size: isTablet ? 28 : 24,
                    ),
                    title: Text(
                      'Privacy Policy',
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                      ),
                    ),
                    onTap: () {
                      // TODO: Navigate to privacy policy
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Privacy Policy coming soon')),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.help,
                      size: isTablet ? 28 : 24,
                    ),
                    title: Text(
                      'Help & Support',
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                      ),
                    ),
                    onTap: () {
                      // TODO: Navigate to help screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Help & Support coming soon')),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(isTablet ? 24 : 16),
            child: Row(
              children: [
                Icon(
                  icon, 
                  color: Colors.blue,
                  size: isTablet ? 28 : 24,
                ),
                SizedBox(width: isTablet ? 12 : 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isTablet ? 22 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  void _showEnableBiometricDialog(BuildContext context, AuthService authService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enable Biometric Authentication'),
        content: const Text(
          'This will enable fingerprint authentication for accessing your todo app. '
          'You will need to authenticate with your fingerprint each time you open the app.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await authService.authenticateWithBiometrics();
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Biometric authentication enabled'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to enable biometric authentication'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Enable'),
          ),
        ],
      ),
    );
  }

  void _showDisableBiometricDialog(BuildContext context, AuthService authService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disable Biometric Authentication'),
        content: const Text(
          'This will disable fingerprint authentication. '
          'You will no longer need to authenticate to access your todo app.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              authService.logout();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Biometric authentication disabled'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('Disable'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text(
          'Are you sure you want to logout? '
          'You will need to authenticate again to access your todos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthService>().logout();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logged out successfully'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
} 