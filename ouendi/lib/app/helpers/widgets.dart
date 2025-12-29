import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:ouendi/screens/phone.dart';
import 'package:ouendi/app/helpers/tools.dart';
import 'package:ouendi/app/colors/appTheme.dart';

import '../../screens/details.dart';

Widget actionItem(IconData icon, String label, VoidCallback onTap) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(50),
    child: Column(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: AppTheme.lightgreen,
          child: Icon(icon, color: AppTheme.primary),
        ),
        const SizedBox(height: 3),
        Text(label, style: TextStyle(fontSize: 16)),
      ],
    ),
  );
}

Widget sectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.only(top: 25, bottom: 8),
    child: Text(title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
  );
}

Widget settingsItem(IconData icon, String label) {
  return ListTile(
    leading: Icon(icon),
    title: Text(label, style: TextStyle(fontSize: 16)),
    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
  );
}

Widget appLogo({double width = 80.0, double height = 80.0}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(5), // arrondi des coins
    child: Image.asset(
      'assets/images/appstore.png',
      width: width,
      height: height,
      fit: BoxFit.contain, // conserve les proportions
    ),
  );
}

Widget buildNumpadRow(
    BuildContext context,
    List<String> digits, {
      required Function(String) addDigit,
      required Function removeDigit,
    }) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: digits.map((d) {
      if (d.isEmpty) {
        return const SizedBox(width: 70);
      }
      return InkWell(
        onTap: () {
          if (d == "⌫") {
            removeDigit();
          } else if(d == '←') {
            Future.delayed(const Duration(milliseconds: 250), () {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => Phone()));
            });
          } else {
            addDigit(d);
          }
        },
        child: Container(
          height: 70,
          width: 70,
          alignment: Alignment.center,
          child: Text(
            d,
            style: const TextStyle(fontSize: 30),
          ),
        ),
      );
    }).toList(),
  );
}

InputDecoration inputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(fontSize: 16),
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(vertical: 12),
    border: const UnderlineInputBorder(
      borderSide: BorderSide(width: 2, color: AppTheme.primary),
    ),
    enabledBorder: const UnderlineInputBorder(
      borderSide: BorderSide(width: 2, color: AppTheme.primary),
    ),
    focusedBorder: const UnderlineInputBorder(
      borderSide: BorderSide(width: 2, color: AppTheme.primary),
    ),
  );
}
