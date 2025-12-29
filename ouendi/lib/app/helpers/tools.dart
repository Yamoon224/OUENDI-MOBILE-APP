import 'package:intl/intl.dart';

bool isProfileCompleted(Map<String, dynamic> user) {
  // Vérifie les champs obligatoires
  final requiredFields = [
    'last_name',
    'first_name',
    'email',
    'status',
    'role',
    'cni_path',
    //'photo',
    'student_card_path',
    'level_class',
    'university'
  ];

  // Vérifie null ou vide
  for (var field in requiredFields) {
    if (user[field] == null) return false;
    if (user[field] is String && (user[field] as String).trim().isEmpty) {
      return false;
    }
  }

  // Vérifie conditions spécifiques
  if (user['status'] != 'ENABLE') return false;
  if (user['role'] != 'student') return false;

  return true;
}

final NumberFormat _numberFormat = NumberFormat("#,##0", "fr_FR"); // <-- format FR
String formatAmount(dynamic amount) {
  if (amount == null) return "0";
  try {
    return _numberFormat.format(num.parse(amount.toString()));
  } catch (e) {
    return amount.toString();
  }
}

double getFeeRate(int amount) {
  if (amount >= 20000 && amount <= 80000) return 0.02;
  if (amount >= 81000 && amount <= 150000) return 0.03;
  if (amount >= 151000 && amount <= 300000) return 0.04;
  if (amount >= 301000 && amount <= 600000) return 0.05;
  return 0.0;
}

double getCurrentFeeRate(String amountCredited) {
  final text = amountCredited.trim();
  if (text.isEmpty) return 0.0;
  int montantPret = int.tryParse(text) ?? 0;
  return getFeeRate(montantPret);
}
