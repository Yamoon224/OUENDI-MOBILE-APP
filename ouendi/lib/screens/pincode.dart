import 'package:flutter/material.dart';
import 'package:ouendi/screens/home.dart';
import 'package:ouendi/screens/phone.dart';
import 'package:ouendi/app/colors/appTheme.dart';
import 'package:ouendi/app/helpers/widgets.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ouendi/app/controllers/auth_service.dart';
import 'package:ouendi/app/helpers/inactivity_scope.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PinCode extends StatefulWidget {
  @override
  State<PinCode> createState() => _PinCodeState();
}

class _PinCodeState extends State<PinCode> {
  List<String> pin = [];
  bool _isLoading = true;       // Pour vérifier si le téléphone existe
  bool _isSubmitting = false;   // Pour loader pendant la soumission

  @override
  void initState() {
    super.initState();
    _isPhoneExistInLocal();
  }

  Future<void> _isPhoneExistInLocal() async {
    final prefs = await SharedPreferences.getInstance();
    String? phone = prefs.getString('phone');

    if (phone == null || phone.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => Phone()),
        );
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  void addDigit(String digit) async {
    if (_isSubmitting) return;

    if (pin.length < 4) {
      setState(() => pin.add(digit));

      if (pin.length == 4) {
        setState(() => _isSubmitting = true);

        final prefs = await SharedPreferences.getInstance();
        String? phone = prefs.getString('phone');
        String? localPassword = prefs.getString('password');

        if (phone == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Numéro non trouvé")),
          );
          pin.clear();
          setState(() => _isSubmitting = false);
          return;
        }

        // Vérifier la connexion Internet
        var connectivityResult = await Connectivity().checkConnectivity();
        bool isOnline = connectivityResult != ConnectivityResult.none;

        String enteredPin = pin.join();

        // ------------------------------------------------------
        // CAS 1 : Pas d'internet → Vérifier uniquement en local
        // ------------------------------------------------------
        if (!isOnline) {
          if (localPassword == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Aucun mot de passe local trouvé")),
            );
            pin.clear();
            setState(() => _isSubmitting = false);
            return;
          }

          if (enteredPin == localPassword) {
            // Succès en mode offline
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => Home()),
              );
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Code Incorrect (mode hors-ligne)")),
            );
            pin.clear();
            setState(() => _isSubmitting = false);
          }
          return;
        }

        // ------------------------------------------------------
        // CAS 2 : Internet disponible → Authentification API
        // ------------------------------------------------------
        bool success = await AuthService.login(
          phone: phone,
          password: enteredPin,
          scaffoldMessengerKey: GlobalKey<ScaffoldMessengerState>(),
        );

        if (success) {
          // Enregistrer le password localement pour mode offline
          prefs.setString('password', enteredPin);

          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => Home()),
            );
          });
        } else {
          pin.clear();
          setState(() => _isSubmitting = false);
        }
      }
    }
  }

  void removeDigit() {
    if (_isSubmitting) return; // Bloquer pendant le submit
    if (pin.isNotEmpty) setState(() => pin.removeLast());
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return InactivityScope(
      enable: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        /* appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Future.delayed(const Duration(milliseconds: 250), () {
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (_) => Phone()));
              });
            },
          ),
        ), */
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 40),
              Column(
                children: [
                  // Logo du pingouin
                  appLogo(),
                  const SizedBox(height: 30),
                  const Text(
                    "Votre code secret est obligatoire",
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 25),

                  // Loader ou PIN
                  _isSubmitting
                      ? const Center(child: CircularProgressIndicator())
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      4,
                          (i) => Container(
                        margin:
                        const EdgeInsets.symmetric(horizontal: 8),
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: i < pin.length
                              ? AppTheme.primary
                              : Colors.black12,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Clavier
              if (!_isSubmitting)
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
                      ["←", "0", "⌫"],
                      addDigit: addDigit,
                      removeDigit: removeDigit,
                    ),
                  ]),
                )
            ],
          ),
        ),
      ),
    );
  }
}