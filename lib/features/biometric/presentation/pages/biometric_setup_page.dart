import 'package:flutter/material.dart';
import '../../../../core/services/biometric_auth_service.dart';
import '../../../../core/services/auth_service.dart';

class BiometricSetupPage extends StatefulWidget {
  const BiometricSetupPage({super.key});

  @override
  State<BiometricSetupPage> createState() => _BiometricSetupPageState();
}

class _BiometricSetupPageState extends State<BiometricSetupPage> {
  final BiometricAuthService _biometricService = BiometricAuthService();
  final AuthService _authService = AuthService();
  
  bool _isLoading = true;
  bool _isBiometricEnabled = false;
  Map<String, dynamic> _biometricInfo = {};
  
  @override
  void initState() {
    super.initState();
    _loadBiometricStatus();
  }
  
  Future<void> _loadBiometricStatus() async {
    setState(() => _isLoading = true);
    
    try {
      await _biometricService.initialize();
      final user = await _authService.getCurrentUser();
      
      if (user != null) {
        final enabled = await _biometricService.isBiometricEnabled(user.id);
        final info = await _biometricService.getBiometricInfo();
        
        setState(() {
          _isBiometricEnabled = enabled;
          _biometricInfo = info;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading biometric status: $e')),
        );
      }
    }
  }
  
  Future<void> _toggleBiometric(bool value) async {
    final user = await _authService.getCurrentUser();
    if (user == null) return;
    
    if (value) {
      // Enable biometric
      final success = await _biometricService.enableBiometricAuth(user.id);
      if (success) {
        setState(() => _isBiometricEnabled = true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Biometric authentication enabled!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Failed to enable biometric authentication'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      // Disable biometric
      await _biometricService.disableBiometricAuth(user.id);
      setState(() => _isBiometricEnabled = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Biometric authentication disabled'),
          ),
        );
      }
    }
  }
  
  Future<void> _testBiometric() async {
    final success = await _biometricService.authenticate(
      reason: 'Test biometric authentication',
    );
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? '✅ Authentication successful!' : '❌ Authentication failed'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biometric Authentication'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _isBiometricEnabled ? Icons.fingerprint : Icons.fingerprint_outlined,
                                size: 48,
                                color: _isBiometricEnabled ? Colors.green : Colors.grey,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Biometric Login',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _isBiometricEnabled ? 'Enabled' : 'Disabled',
                                      style: TextStyle(
                                        color: _isBiometricEnabled ? Colors.green : Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _isBiometricEnabled,
                                onChanged: _biometricInfo['canCheckBiometrics'] == true
                                    ? _toggleBiometric
                                    : null,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Device Capabilities
                  Text(
                    'Device Capabilities',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildCapabilityCard(
                    'Biometric Support',
                    _biometricInfo['isDeviceSupported'] == true,
                    'Your device supports biometric authentication',
                    'Your device does not support biometric authentication',
                  ),
                  
                  _buildCapabilityCard(
                    'Biometric Enrolled',
                    _biometricInfo['canCheckBiometrics'] == true,
                    'Biometric data is enrolled on this device',
                    'No biometric data enrolled. Please set up in device settings',
                  ),
                  
                  if (_biometricInfo['hasFingerprint'] == true)
                    _buildCapabilityCard(
                      'Fingerprint',
                      true,
                      'Fingerprint authentication available',
                      '',
                    ),
                  
                  if (_biometricInfo['hasFace'] == true)
                    _buildCapabilityCard(
                      'Face Recognition',
                      true,
                      'Face recognition available',
                      '',
                    ),
                  
                  const SizedBox(height: 24),
                  
                  // Test Button
                  if (_biometricInfo['canCheckBiometrics'] == true)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _testBiometric,
                        icon: const Icon(Icons.fingerprint),
                        label: const Text('Test Biometric Authentication'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 24),
                  
                  // Information
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue.shade700),
                            const SizedBox(width: 8),
                            Text(
                              'About Biometric Authentication',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '• Biometric authentication provides quick and secure access\n'
                          '• Your biometric data never leaves your device\n'
                          '• You can use fingerprint or face recognition\n'
                          '• Fallback to password is always available\n'
                          '• Can be used for attendance marking and session creation',
                          style: TextStyle(height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
  
  Widget _buildCapabilityCard(
    String title,
    bool isAvailable,
    String availableMessage,
    String unavailableMessage,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isAvailable
                ? Colors.green.withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isAvailable ? Icons.check_circle : Icons.cancel,
            color: isAvailable ? Colors.green : Colors.grey,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          isAvailable ? availableMessage : unavailableMessage,
          style: TextStyle(
            color: isAvailable ? Colors.grey[700] : Colors.grey[500],
          ),
        ),
      ),
    );
  }
}
