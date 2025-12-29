import 'dart:convert';
import 'package:ouendi/app/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class AuthService {
  static Future<bool> login({
    required String phone,
    required String password,
    required GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey,
  }) async {
    try {
      // Envoyer la requête POST à l'API
      final response = await http.post(
        Uri.parse('${Api.BASE_URL}/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"phone": phone, "password": password}),
      );

      // Vérifier le statut de la réponse
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          // Récupérer SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          // Stocker le token et les données utilisateur
          await prefs.setString('password', password);

          await prefs.setString('token', responseData['token']);
          await prefs.setString('user', jsonEncode(responseData['user']));
          return true; // Succès
        } else {
          String errorMessage = responseData['message'] ?? 'Identifiants incorrects';
          scaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
          return false; // Échec
        }
      } else {
        // Afficher un message d'erreur si la requête échoue
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text("Erreur lors de la connexion : ${response.statusCode}"),
            backgroundColor: Colors.red,
          ),
        );
        return false; // Échec
      }
    } catch (e) {
      // Gérer les erreurs de requête
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text("Erreur réseau : $e"),
          backgroundColor: Colors.red,
        ),
      );
      return false; // Échec
    }
  }
}
