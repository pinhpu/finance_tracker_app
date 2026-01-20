import 'package:finance_tracker_app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import '../../../../main.dart'; // Import MainScaffold
import '../controller/auth_controller.dart';

class AuthScreen extends StatefulWidget {
  final bool isSetupMode;
  const AuthScreen({super.key, this.isSetupMode = false});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  String _pin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  final AuthController _controller = AuthController();

  @override
  Widget build(BuildContext context) {
    String title = '';
    String subTitle = '';

    if (widget.isSetupMode) {
      if (_isConfirming) {
        title = 'Confirm your PIN';
        subTitle = 'Re-enter your 4-digit PIN';
      } else {
        title = 'Create a PIN';
        subTitle = 'Enter a 4-digit PIN to secure your wallet';
      }
    } else {
      title = 'Enter PIN';
      subTitle = 'Enter your 4-digit PIN to login';
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryLight, AppColors.primary],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white30,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_outline,
                  size: 64,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subTitle,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final length = widget.isSetupMode
                      ? (_isConfirming ? _confirmPin.length : _pin.length)
                      : _pin.length;

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index < length ? Colors.white : Colors.white30,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  );
                }),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildNumberRow(['1', '2', '3']),
                    const SizedBox(height: 16),
                    _buildNumberRow(['4', '5', '6']),
                    const SizedBox(height: 16),
                    _buildNumberRow(['7', '8', '9']),
                    const SizedBox(height: 16),
                    _buildNumberRow(['', '0', 'back']),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberRow(List<String> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: numbers.map((number) {
        if (number.isEmpty) {
          return const SizedBox(width: 80, height: 80);
        }
        if (number == 'back') {
          return _buildNumberButton(
            child: const Icon(Icons.backspace_outlined, color: Colors.white),
            onTap: () {
              setState(() {
                if (widget.isSetupMode) {
                  if (_isConfirming && _confirmPin.isNotEmpty) {
                    _confirmPin = _confirmPin.substring(
                      0,
                      _confirmPin.length - 1,
                    );
                  } else if (!_isConfirming && _pin.isNotEmpty) {
                    _pin = _pin.substring(0, _pin.length - 1);
                  }
                } else {
                  if (_pin.isNotEmpty) {
                    _pin = _pin.substring(0, _pin.length - 1);
                  }
                }
              });
            },
          );
        }
        return _buildNumberButton(
          child: Text(
            number,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w500,
            ),
          ),
          onTap: () => _onNumberTap(number),
        );
      }).toList(),
    );
  }

  void _onNumberTap(String number) {
    setState(() {
      if (widget.isSetupMode) {
        if (_isConfirming) {
          if (_confirmPin.length < 4) {
            _confirmPin += number;
            if (_confirmPin.length == 4) _handlePinConfirmation();
          }
        } else {
          if (_pin.length < 4) {
            _pin += number;
            if (_pin.length == 4) _isConfirming = true;
          }
        }
      } else {
        if (_pin.length < 4) {
          _pin += number;
          if (_pin.length == 4) _verifyPin();
        }
      }
    });
  }

  Widget _buildNumberButton({
    required Widget child,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white30, width: 1),
        ),
        child: Center(child: child),
      ),
    );
  }

  Future<void> _handlePinConfirmation() async {
    if (_pin == _confirmPin) {
      final success = await _controller.setupPin(_pin);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PIN setup successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainScaffold()),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save PIN. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      _showError('PINs do not match. Please try again.');
      setState(() {
        // _pin = '';
        _confirmPin = '';
        _isConfirming = true;
      });
    }
  }

  Future<void> _verifyPin() async {
    final isValid = await _controller.verifyPin(_pin);
    if (isValid && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScaffold()),
      );
    } else {
      _showError('Incorrect PIN');
      setState(() {
        _pin = '';
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
