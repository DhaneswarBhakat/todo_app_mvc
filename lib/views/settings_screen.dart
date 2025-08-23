import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/theme_service.dart';
import '../services/api_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    // Create animations
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
    
    // Start animations
    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
  }
  
  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF1a1a2e),
                    const Color(0xFF16213e),
                    const Color(0xFF0f3460),
                  ]
                : [
                    const Color(0xFF667eea),
                    const Color(0xFF764ba2),
                    const Color(0xFFf093fb),
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      // Back Button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Title
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.settings,
                                size: 28,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              'Settings',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Content
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1e1e2e) : Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 5,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: isTablet ? 800 : double.infinity,
                            ),
                            child: ListView(
                              padding: EdgeInsets.all(isTablet ? 32 : 24),
                              children: [
                                // Authentication Section
                                ScaleTransition(
                                  scale: _scaleAnimation,
                                  child: _buildSection(
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
                                ),
                                
                                SizedBox(height: isTablet ? 32 : 24),
                                
                                // Appearance Section
                                ScaleTransition(
                                  scale: _scaleAnimation,
                                  child: _buildSection(
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
                                ),
                                
                                SizedBox(height: isTablet ? 32 : 24),
                                
                                // About Section
                                ScaleTransition(
                                  scale: _scaleAnimation,
                                  child: _buildSection(
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
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2a2a3e) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(isTablet ? 24 : 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.primaryColor.withOpacity(0.1),
                  theme.primaryColor.withOpacity(0.05),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: theme.primaryColor,
                    size: isTablet ? 28 : 24,
                  ),
                ),
                SizedBox(width: isTablet ? 16 : 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isTablet ? 22 : 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          ...children.map((child) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            child: child,
          )),
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

  void _showLogoutDialog(BuildContext context) async {
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
            onPressed: () async {
              Navigator.pop(context);
              
              try {
                // Call API logout
                await ApiService.logout();
                
                // Clear biometric authentication
                context.read<AuthService>().logout();
                
                if (context.mounted) {
                  // Navigate back to login screen
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login',
                    (route) => false, // Remove all previous routes
                  );
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Logged out successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (error) {
                print('❌ Logout error: $error');
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Logout failed: ${error.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
} 