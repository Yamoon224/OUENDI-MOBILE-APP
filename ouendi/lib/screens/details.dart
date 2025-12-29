import 'package:flutter/material.dart';
import 'package:ouendi/app/colors/appTheme.dart';
import 'package:ouendi/app/helpers/widgets.dart';
import 'package:ouendi/app/helpers/inactivity_scope.dart';

class Details extends StatelessWidget {
  final String amountCredited;
  final String receiver;
  final String amountObtain;
  final String status;
  final String fee;
  final String dateTime;
  final String transactionId;

  const Details({
    super.key,
    required this.amountCredited,
    required this.receiver,
    required this.amountObtain,
    required this.status,
    required this.fee,
    required this.dateTime,
    required this.transactionId,
  });

  @override
  Widget build(BuildContext context) {
    return InactivityScope(
      enable: true,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Détails Crédit"),
          backgroundColor: AppTheme.primary,
          foregroundColor: AppTheme.bgwhite,
          elevation: 0,
        ),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 10),

              // --- AVATAR & AMOUNT ---
              Column(
                children: [
                  appLogo(),
                  const SizedBox(height: 15),
                  Text(
                    amountCredited,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    receiver,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // --- CARD WITH DETAILS ---
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _rowInfo("Montant Credit", amountCredited),
                    _rowInfo("Montant Obtenu", amountObtain),
                    _rowInfo("Status", status),
                    _rowInfo("Fee", fee),
                    _rowInfo("Date & time", dateTime),
                  ],
                ),
              ),

              const Expanded(child: SizedBox()),

              const Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Text(
                  "In partnership with PayCard.",
                  style: TextStyle(color: Colors.black45),
                ),
              ),
            ],
          ),
        ),
      )
    );
  }

  Widget _rowInfo(String title, String value) {
    // Normalisation du texte
    final status = value.toLowerCase().trim();

    // Définition couleurs & icônes selon statut
    IconData? icon;
    Color? color;

    if (status == "approved") {
      icon = Icons.check_circle;
      color = Colors.green;
    } else if (status == "pending") {
      icon = Icons.hourglass_empty;
      color = Colors.orange;
    } else if (status == "rejected") {
      icon = Icons.cancel;
      color = Colors.red;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
            ),
          ),

          Row(
            children: [
              if (icon != null)
                Icon(icon, color: color, size: 18),

              if (icon != null) const SizedBox(width: 5),

              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: color ?? Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
