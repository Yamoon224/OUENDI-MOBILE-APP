import 'package:flutter/material.dart';
import 'package:ouendi/screens/pincode.dart';
import 'package:ouendi/app/colors/appTheme.dart';
import 'package:ouendi/app/helpers/widgets.dart';
import 'package:ouendi/app/helpers/inactivity_scope.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Phone extends StatefulWidget {
  @override
  _PhoneState createState() => _PhoneState();
}

class _PhoneState extends State<Phone> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPhoneFromLocal();
  }

  Future<void> _loadPhoneFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    String? storedPhone = prefs.getString('phone');
    if (storedPhone != null && storedPhone.isNotEmpty) {
      setState(() {
        _phoneController.text = _formatPhone(storedPhone);
      });
    }
  }

  String _formatPhone(String digits) {
    String formatted = '';
    for (int i = 0; i < digits.length; i++) {
      if (i == 3 || i == 5 || i == 7) formatted += ' ';
      formatted += digits[i];
    }
    return formatted;
  }

  void addDigit(String digit) {
    String currentDigits = _phoneController.text.replaceAll(' ', '');
    if (currentDigits.length < 9) {
      if (currentDigits.length == 0 || currentDigits.length == 1) {
        List<String> allowedPrefixes = ['61', '62', '63', '64', '65', '66', '67'];
        String newPrefix = currentDigits + digit;
        if (allowedPrefixes.contains(newPrefix) || (currentDigits.isEmpty && digit == '6')) {
          currentDigits += digit;
        } else {
          return;
        }
      } else {
        currentDigits += digit;
      }
      setState(() {
        _phoneController.text = _formatPhone(currentDigits);
      });
    }
  }

  void removeDigit() {
    if (_phoneController.text.isNotEmpty) {
      String currentText = _phoneController.text;
      if (currentText.endsWith(' ')) {
        currentText = currentText.substring(0, currentText.length - 1);
      }
      String digitsOnly = currentText.replaceAll(' ', '');
      if (digitsOnly.isNotEmpty) {
        digitsOnly = digitsOnly.substring(0, digitsOnly.length - 1);
      }
      setState(() {
        _phoneController.text = _formatPhone(digitsOnly);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return InactivityScope(
      enable: false,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 30),
              appLogo(),
              SizedBox(height: 40),
              Text(
                'Entrez le numéro de téléphone sur PayCard',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppTheme.primary, width: 2),
                  ),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/flags/gn.png',
                            width: 24,
                            height: 16,
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            '+224',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                          const Icon(Icons.arrow_drop_down, size: 28),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.none,
                        readOnly: true,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                        decoration: const InputDecoration(
                          hintText: '6xx xx xx xx',
                          hintStyle: TextStyle(fontSize: 24, color: Colors.grey),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: (_phoneController.text.replaceAll(' ', '').length == 9)
                    ? () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString(
                      'phone', _phoneController.text.replaceAll(' ', ''));
                  Future.delayed(const Duration(milliseconds: 250), () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => PinCode()),
                    );
                  });
                }
                    : null,
                child: Text('Suivant', style: TextStyle(color: AppTheme.bgwhite, fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  backgroundColor: (_phoneController.text.replaceAll(' ', '').length == 9)
                      ? AppTheme.primary
                      : AppTheme.primary.withOpacity(0.5),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(children: [
                  buildNumpadRow(
                    context,
                    ["1", "2", "3"],
                    addDigit: addDigit,
                    removeDigit: removeDigit,
                  ),
                  buildNumpadRow(
                    context,
                    ["4", "5", "6"],
                    addDigit: addDigit,
                    removeDigit: removeDigit,
                  ),
                  buildNumpadRow(
                    context,
                    ["7", "8", "9"],
                    addDigit: addDigit,
                    removeDigit: removeDigit,
                  ),
                  buildNumpadRow(
                    context,
                    ["", "0", "⌫"],
                    addDigit: addDigit,
                    removeDigit: removeDigit,
                  ),
                ]),
              )
            ],
          ),
        ),
      )
    );
  }
}