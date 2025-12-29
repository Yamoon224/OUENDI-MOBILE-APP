import 'home.dart';
import 'package:flutter/material.dart';
import 'package:ouendi/screens/phone.dart';
import 'package:ouendi/app/helpers/tools.dart';
import 'package:ouendi/app/colors/appTheme.dart';
import 'package:ouendi/app/helpers/inactivity_scope.dart';
import 'package:ouendi/app/controllers/credit_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Credit extends StatefulWidget {
  const Credit({super.key});

  @override
  State<Credit> createState() => _CreditState();
}

class _CreditState extends State<Credit> {
  String? phone;

  final _creditAmountController = TextEditingController();
  final _obtainAmountController = TextEditingController();

  bool isUpdating = false; // empêche les updates circulaires
  bool _isSubmitting = false; // <-- loader de soumission

  @override
  void initState() {
    super.initState();
    _loadPhone();
  }

  @override
  void dispose() {
    _creditAmountController.dispose();
    _obtainAmountController.dispose();
    super.dispose();
  }

  Future<void> _loadPhone() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedPhone = prefs.getString("phone");

    if (storedPhone == null || storedPhone.isEmpty) {
      Future.microtask(() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => Phone()),
        );
      });
    } else {
      setState(() => phone = storedPhone);
    }
  }

  // -----------------------------
  //       FEE CALCULATOR
  // -----------------------------
  void _updateObtenuFromPret() {
    if (isUpdating) return;
    isUpdating = true;

    final text = _creditAmountController.text.trim();
    if (text.isEmpty) {
      _obtainAmountController.text = "";
      isUpdating = false;
      return;
    }

    int montantPret = int.tryParse(text) ?? 0;

    if (montantPret < 20000 || montantPret > 600000) {
      _obtainAmountController.text = "";
      isUpdating = false;
      return;
    }

    final feeRate = getFeeRate(montantPret);
    final obtenu = montantPret - (montantPret * feeRate);

    _obtainAmountController.text = obtenu.toInt().toString();

    isUpdating = false;
  }

  void _updatePretFromObtenu() {
    if (isUpdating) return;
    isUpdating = true;

    final text = _obtainAmountController.text.trim();
    if (text.isEmpty) {
      _creditAmountController.text = "";
      isUpdating = false;
      return;
    }

    int obtenu = int.tryParse(text) ?? 0;

    List<Map<String, dynamic>> tranches = [
      {"min": 20000, "max": 80000, "rate": 0.02},
      {"min": 81000, "max": 150000, "rate": 0.03},
      {"min": 151000, "max": 300000, "rate": 0.04},
      {"min": 301000, "max": 600000, "rate": 0.05},
    ];

    int? pretCalcule;

    for (var t in tranches) {
      final candidate = (obtenu / (1 - t["rate"])).toInt();
      if (candidate >= t["min"] && candidate <= t["max"]) {
        pretCalcule = candidate;
        break;
      }
    }

    if (pretCalcule == null) {
      _creditAmountController.text = "";
      isUpdating = false;
      return;
    }

    _creditAmountController.text = pretCalcule.toString();

    isUpdating = false;
  }

  Future<void> _handleSubmit() async {
    final amount = int.tryParse(_creditAmountController.text.trim());
    if (amount == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Montant Incorrect")));
      return;
    }

    setState(() => _isSubmitting = true);

    bool success = await CreditService.submitCredit(context: context, amount: amount);

    if (success) {
      // succès : redirection
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => Home()),
        );
      }
    } else {
      // échec : loader désactivé, formulaire reste actif
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Échec lors de la demande")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (phone == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return InactivityScope(
      enable: true,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: AppTheme.primary,
          foregroundColor: AppTheme.bgwhite,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.bgwhite),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "Demande de Prêt",
            style: TextStyle(color: AppTheme.bgwhite, fontSize: 20),
          ),
          centerTitle: false,
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("A", style: TextStyle(color: Colors.grey, fontSize: 18)),
                  const SizedBox(height: 4),
                  const Text(
                    "Compte PayCard",
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    phone!,
                    style: const TextStyle(fontSize: 18, color: Colors.black87),
                  ),
                  const SizedBox(height: 15),
                  Divider(color: Colors.grey.shade300),
                  const SizedBox(height: 20),
                  const Text(
                    "Montant Prêt",
                    style: TextStyle(color: AppTheme.primary, fontSize: 18),
                  ),
                  TextField(
                    controller: _creditAmountController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _updateObtenuFromPret(),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      hintText: 'Xxxx',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppTheme.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Min 20 000 – Max 600 000 GNF",
                    style: TextStyle(color: Colors.redAccent, fontSize: 14),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "Montant Obtenu",
                    style: TextStyle(color: Colors.grey, fontSize: 18),
                  ),
                  TextField(
                    controller: _obtainAmountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    onChanged: (_) => _updatePretFromObtenu(),
                    decoration: InputDecoration(
                      hintText: 'Xxxx',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppTheme.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _creditAmountController,
                      builder: (context, value, child) {
                        double rate = getCurrentFeeRate(_creditAmountController.text);
                        String rateText = rate > 0 ? "${(rate * 100).toInt()}%" : "-";
                        return Text(
                          "Frais selon tranche automatique : $rateText",
                          style: const TextStyle(color: AppTheme.primary, fontSize: 14),
                        );
                      },
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _isSubmitting ? null : _handleSubmit,
                    child: Container(
                      width: double.infinity,
                      height: 55,
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: _isSubmitting
                            ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                            : const Text(
                          "Confirmer",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      )
    );
  }
}