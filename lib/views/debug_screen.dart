import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  String _debugInfo = '';
  bool _isTesting = false;

  @override
  void initState() {
    super.initState();
    _loadDebugInfo();
  }

  Future<void> _loadDebugInfo() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    
    setState(() {
      _debugInfo = '''
=== Biometric Authentication Debug Info ===

Biometric Available: ${authService.isBiometricAvailable}
Is Authenticated: ${authService.isAuthenticated}
Last Error: ${authService.lastError}

=== Testing Biometric Authentication ===
''';
    });
  }

  Future<void> _testBiometricAuth() async {
    setState(() {
      _isTesting = true;
      _debugInfo += '\n🔄 Testing biometric authentication...\n';
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    
    try {
      // Test biometric availability
      final canCheck = await authService.isBiometricSupported();
      _debugInfo += 'Can check biometrics: $canCheck\n';
      
      // Get available biometrics
      final biometrics = await authService.getAvailableBiometrics();
      _debugInfo += 'Available biometrics: $biometrics\n';
      
      // Test authentication
      final result = await authService.manualAuthenticate();
      _debugInfo += 'Authentication result: $result\n';
      _debugInfo += 'Last error: ${authService.lastError}\n';
      
    } catch (e) {
      _debugInfo += 'Error during test: $e\n';
    }

    setState(() {
      _isTesting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Biometric Auth'),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isTablet ? 800 : double.infinity,
          ),
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 32 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Cards
                Consumer<AuthService>(
                  builder: (context, authService, child) {
                    return Column(
                      children: [
                        _buildStatusCard(
                          context,
                          'Biometric Available',
                          authService.isBiometricAvailable ? '✅ Yes' : '❌ No',
                          authService.isBiometricAvailable ? Colors.green : Colors.red,
                        ),
                        SizedBox(height: isTablet ? 12 : 8),
                        _buildStatusCard(
                          context,
                          'Authentication Status',
                          authService.isAuthenticated ? '✅ Authenticated' : '❌ Not Authenticated',
                          authService.isAuthenticated ? Colors.green : Colors.orange,
                        ),
                        SizedBox(height: isTablet ? 12 : 8),
                        _buildStatusCard(
                          context,
                          'Last Error',
                          authService.lastError.isEmpty ? 'None' : authService.lastError,
                          authService.lastError.isEmpty ? Colors.green : Colors.red,
                        ),
                      ],
                    );
                  },
                ),
                
                SizedBox(height: isTablet ? 32 : 24),
                
                // Test Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isTesting ? null : _testBiometricAuth,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.all(isTablet ? 20 : 16),
                    ),
                    child: _isTesting
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: isTablet ? 24 : 20,
                                height: isTablet ? 24 : 20,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              SizedBox(width: isTablet ? 12 : 8),
                              Text(
                                'Testing...',
                                style: TextStyle(
                                  fontSize: isTablet ? 18 : 16,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            'Test Biometric Authentication',
                            style: TextStyle(
                              fontSize: isTablet ? 18 : 16,
                            ),
                          ),
                  ),
                ),
                
                SizedBox(height: isTablet ? 32 : 24),
                
                // Debug Info
                Text(
                  'Debug Information:',
                  style: TextStyle(
                    fontSize: isTablet ? 22 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: isTablet ? 12 : 8),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(isTablet ? 16 : 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        _debugInfo,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: isTablet ? 14 : 12,
                        ),
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: isTablet ? 20 : 16),
                
                // Help Section
                Container(
                  padding: EdgeInsets.all(isTablet ? 16 : 12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '💡 Troubleshooting Tips:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isTablet ? 20 : 16,
                        ),
                      ),
                      SizedBox(height: isTablet ? 12 : 8),
                      Text(
                        '• Make sure fingerprint is set up in device settings\n'
                        '• Try placing finger on the bottom center of screen\n'
                        '• Check if biometric authentication is enabled in device settings\n'
                        '• Some devices require screen to be on for fingerprint to work\n'
                        '• Try both fingerprint and face recognition if available',
                        style: TextStyle(
                          fontSize: isTablet ? 16 : 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(
    BuildContext context,
    String title, 
    String value, 
    Color color,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: isTablet ? 18 : 16,
            ),
          ),
          SizedBox(height: isTablet ? 8 : 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: isTablet ? 14 : 12,
            ),
          ),
        ],
      ),
    );
  }
} 