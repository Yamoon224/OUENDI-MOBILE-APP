// profile_service.dart
import 'dart:io';
import 'dart:convert';
import 'package:ouendi/app/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ouendi/screens/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
    static Future<void> edit({
      required GlobalKey<FormState> formKey,
      required Map<String, dynamic>? user,
      required BuildContext context,
      required TextEditingController lastNameController,
      required TextEditingController firstNameController,
      required TextEditingController emailController,
      required TextEditingController levelClassController,
      required TextEditingController universityController,
      File? cniFile,
      File? studentCardFile,
      File? photoFile,
    }) async {
        if (!formKey.currentState!.validate()) return;
        if (user == null) return;

        final userId = user['id'];
        SharedPreferences prefs = await SharedPreferences.getInstance();

        var request = http.MultipartRequest('POST', Uri.parse('${Api.BASE_URL}/users/$userId'));

        // Authorization si nécessaire
        String? token = prefs.getString('token');
        if (token != null) {
            request.headers['Authorization'] = 'Bearer $token';
        }
        request.fields['_method'] = 'PUT';

        // Champs texte
        request.fields['last_name'] = lastNameController.text.trim();
        request.fields['first_name'] = firstNameController.text.trim();
        request.fields['email'] = emailController.text.trim();
        request.fields['level_class'] = levelClassController.text.trim();
        request.fields['university'] = universityController.text.trim();

        // Fichiers
        if (cniFile != null) {
            request.files.add(await http.MultipartFile.fromPath('cni_path', cniFile.path));
        }
        if (studentCardFile != null) {
            request.files.add(await http.MultipartFile.fromPath('student_card_path', studentCardFile.path));
        }
        if (photoFile != null) {
            request.files.add(await http.MultipartFile.fromPath('photo', photoFile.path));
        }

        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200 || response.statusCode == 201) {
            final resData = jsonDecode(response.body);

            // Met à jour user dans SharedPreferences
            await prefs.setString('user', jsonEncode(resData));
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Profil mis à jour avec succès")),
            );

            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Home()));
        } else {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Erreur : ${response.statusCode}")),
            );
        }
    }
}