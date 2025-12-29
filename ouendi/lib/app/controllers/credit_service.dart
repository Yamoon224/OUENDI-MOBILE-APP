import 'dart:convert';
import 'package:ouendi/app/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CreditService {

  /// Récupère les crédits depuis l'API et met à jour le localStorage
  static Future<List<dynamic>?> refreshCredits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');

      if (userJson == null) return null;

      Map<String, dynamic> user = jsonDecode(userJson);
      final userId = user["id"];

      final url = Uri.parse("${Api.BASE_URL}/credits?user_id=$userId");

      final response = await http.get(url, headers: {"Accept": "application/json"});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> credits = data["data"];

        // Mise à jour du user local
        user["credits"] = credits;
        await prefs.setString("user", jsonEncode(user));

        return credits; // retourne la nouvelle liste
      }
    } catch (e) {
      print("Erreur refreshCredits(): $e");
    }

    return null;
  }

  /// Envoie une demande de crédit et met à jour user['credits'] dans SharedPreferences
  static Future<bool> submitCredit({
    required BuildContext context,
    required int amount,
  }) async {
    if (amount < 20000 || amount > 600000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Montant invalide")),
      );
      return false;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString('user');
    if (userJson == null) return false;

    Map<String, dynamic> user = json.decode(userJson);
    int userId = user['id'];

    Map<String, dynamic> payload = {
      "user_id": userId,
      "amount": amount,
      "status": "pending",
      "request_at": DateTime.now().toString(),
    };

    final response = await http.post(
      Uri.parse("${Api.BASE_URL}/credits"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(payload),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      Map<String, dynamic> resData = json.decode(response.body)['data'];

      List<dynamic> credits = user['credits'] ?? [];
      credits.add(resData);
      user['credits'] = credits;

      await prefs.setString('user', json.encode(user));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Demande de crédit envoyée avec succès")),
      );

      return true; // succès
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : ${response.statusCode}")),
      );
      return false;
    }
  }
}