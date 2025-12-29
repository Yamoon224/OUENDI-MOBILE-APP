import 'package:flutter/material.dart';
import 'package:ouendi/screens/phone.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ouendi/app/helpers/widgets.dart';
import 'package:ouendi/app/colors/appTheme.dart';
import 'package:ouendi/app/helpers/inactivity_scope.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String phone = "";

  @override
  void initState() {
    super.initState();
    _loadPhone();
  }

  Future<void> _loadPhone() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      phone = prefs.getString("phone") ?? "";
    });
  }

  Future<void> _shareApp() async {
    // Tu peux mettre le texte ou lien réel de l'app ici
    await Share.share(
      "Viens découvrir Ouendi ! Télécharge l'application : https://ouendi.jss-gn.com",
      subject: "Rejoins Ouendi !",
    );
  }

  Future<void> _callSupport() async {
    const phone = "+224625800720";
    final Uri uri = Uri(scheme: "tel", path: phone);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication, // Obligatoire sur mobile
        );
      } else {
        throw "cannot launch";
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Impossible d'appeler le support")),
      );
    }
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // supprime toutes les données locales

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => Phone()), // ta page Profile
    );
  }

  @override
  Widget build(BuildContext context) {
    return InactivityScope(
      enable: true,
      child: Scaffold(
          appBar: AppBar(
            title: const Text("Paramètres"),
            backgroundColor: AppTheme.primary,
            foregroundColor: AppTheme.bgwhite,
            elevation: 0,
          ),
          body: ListView(
            padding: const EdgeInsets.all(15),
            children: [
              /* sectionTitle("Compte"),
              settingsItem(Icons.add_home, "Ajouter autre compte"), */

              sectionTitle("Partage"),
              GestureDetector(
                onTap: _shareApp,
                child: settingsItem(Icons.share, "Invitez un pote"),
              ),

              sectionTitle("Support"),
              GestureDetector(
                onTap: _callSupport,
                child: settingsItem(Icons.phone, "Contactez Support"),
              ),

              sectionTitle("Securité"),
              GestureDetector(
                onTap: _callSupport,
                child: settingsItem(Icons.lock, "Code Secret Oublié"),
              ),

              const SizedBox(height: 20),
              GestureDetector(
                onTap: _logout,
                child: settingsItem(
                  Icons.logout,
                  "Déconnexion ${phone.isNotEmpty ? "($phone)" : ""}",
                ),
              ),
            ],
          ),
        )
    );
  }
}