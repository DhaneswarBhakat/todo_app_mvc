import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'todo_list_screen.dart';
import 'debug_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();
    _checkBiometricAvailability();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkBiometricAvailability() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.checkAuthenticationState();
  }

  Future<void> _authenticate() async {
    setState(() {
      _isAuthenticating = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final success = await authService.authenticateWithBiometrics();
      
      if (success && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const TodoListScreen()),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.8),
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.6),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Fingerprint sensor location indicator
              Positioned(
                bottom: screenHeight * 0.1,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: isTablet ? 80 : 60,
                    height: isTablet ? 80 : 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(isTablet ? 40 : 30),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.fingerprint,
                      color: Colors.white,
                      size: isTablet ? 40 : 30,
                    ),
                  ),
                ),
              ),
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isTablet ? 500 : double.infinity,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(isTablet ? 48 : 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // App Logo/Icon
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Container(
                            width: isTablet ? 160 : 120,
                            height: isTablet ? 160 : 120,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(isTablet ? 80 : 60),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.check_circle_outline,
                              size: isTablet ? 80 : 60,
                              color: Colors.green,
                            ),
                          ),
                        ),
                        
                        SizedBox(height: isTablet ? 60 : 40),
                        
                        // App Title
                        SlideTransition(
                          position: _slideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Text(
                              'Todo App',
                              style: TextStyle(
                                fontSize: isTablet ? 48 : 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Subtitle
                        SlideTransition(
                          position: _slideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Text(
                              'Secure your tasks with biometric authentication',
                              style: TextStyle(
                                fontSize: isTablet ? 20 : 16,
                                color: Colors.white70,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        
                        SizedBox(height: isTablet ? 80 : 60),
                        
                        // Biometric Authentication Button
                        SlideTransition(
                          position: _slideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Consumer<AuthService>(
                              builder: (context, authService, child) {
                                if (!authService.isBiometricAvailable) {
                                  return Container(
                                    padding: EdgeInsets.all(isTablet ? 24 : 16),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Biometric authentication not available',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isTablet ? 20 : 16,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  );
                                }
                                
                                return Column(
                                  children: [
                                    GestureDetector(
                                      onTap: _isAuthenticating ? null : _authenticate,
                                      child: Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.all(isTablet ? 28 : 20),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 10,
                                              offset: const Offset(0, 5),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            if (_isAuthenticating)
                                              SizedBox(
                                                width: isTablet ? 24 : 20,
                                                height: isTablet ? 24 : 20,
                                                child: const CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                                                ),
                                              )
                                            else
                                              Icon(
                                                Icons.fingerprint,
                                                size: isTablet ? 32 : 24,
                                                color: Colors.green,
                                              ),
                                            SizedBox(width: isTablet ? 16 : 12),
                                            Text(
                                              _isAuthenticating ? 'Authenticating...' : 'Authenticate with Fingerprint',
                                              style: TextStyle(
                                                fontSize: isTablet ? 22 : 18,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.green,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: isTablet ? 20 : 16),
                                    // Fallback button for difficult fingerprint sensors
                                    GestureDetector(
                                      onTap: _isAuthenticating ? null : _authenticate,
                                      child: Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.all(isTablet ? 20 : 16),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.touch_app,
                                              size: isTablet ? 24 : 20,
                                              color: Colors.white,
                                            ),
                                            SizedBox(width: isTablet ? 12 : 8),
                                            Text(
                                              'Try Again (Tap anywhere on screen)',
                                              style: TextStyle(
                                                fontSize: isTablet ? 16 : 14,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                        
                        SizedBox(height: isTablet ? 32 : 20),
                        
                        // Debug Button (for troubleshooting)
                        SlideTransition(
                          position: _slideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const DebugScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                '🔧 Debug Biometric Auth',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: isTablet ? 16 : 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        SizedBox(height: isTablet ? 32 : 20),
                        
                        // Info Text
                        SlideTransition(
                          position: _slideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Column(
                              children: [
                                Text(
                                  'Touch the fingerprint sensor to unlock your todo app',
                                  style: TextStyle(
                                    color: Colors.white60,
                                    fontSize: isTablet ? 18 : 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: isTablet ? 20 : 16),
                                Container(
                                  padding: EdgeInsets.all(isTablet ? 16 : 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    '💡 Tip: Look for the fingerprint sensor on your screen or try the bottom center area',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: isTablet ? 16 : 12,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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
} 