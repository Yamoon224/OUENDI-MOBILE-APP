import 'credit.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:ouendi/screens/details.dart';
import 'package:ouendi/screens/profile.dart';
import 'package:ouendi/screens/pincode.dart';
import 'package:ouendi/screens/settings.dart';
import 'package:ouendi/app/helpers/tools.dart';
import 'package:ouendi/app/colors/appTheme.dart';
import 'package:ouendi/app/helpers/widgets.dart';
import 'package:ouendi/app/helpers/inactivity_scope.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ouendi/app/controllers/credit_service.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool showBalance = false;
  bool _isLoading = true;

  Map<String, dynamic>? user;
  List<dynamic> credits = [];
  List<dynamic> filteredCredits = [];

  DateTimeRange? selectedRange;

  @override
  void initState() {
    super.initState();
    _isAuth();
  }

  /// Vérifie l'auth et charge les crédits
  Future<void> _isAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final phone = prefs.getString('phone');
    final userJson = prefs.getString('user');

    if (token == null || phone == null || userJson == null) {
      Future.delayed(const Duration(milliseconds: 250), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => PinCode()),
        );
      });
      return;
    }

    // Ici on effectue les opérations async AVANT setState()
    final parsedUser = jsonDecode(userJson);
    final refreshedCredits = await CreditService.refreshCredits();

    setState(() {
      user = parsedUser;
      credits = refreshedCredits ?? [];
      filteredCredits = List.from(credits);
      _isLoading = false;
    });
  }

  /// Filtre par date
  void filterCreditsByDate() {
    if (selectedRange == null) {
      setState(() => filteredCredits = List.from(credits));
      return;
    }

    final start = selectedRange!.start;
    final end = selectedRange!.end;

    setState(() {
      filteredCredits = credits.where((c) {
        final date = DateTime.parse(c['request_at']);
        return date.isAfter(start.subtract(const Duration(days: 1))) &&
            date.isBefore(end.add(const Duration(days: 1)));
      }).toList();
    });
  }

  /// Sélection du DateRangePicker
  Future<void> pickDateRange() async {
    final initialRange = selectedRange ??
        DateTimeRange(
          start: DateTime.now().subtract(const Duration(days: 30)),
          end: DateTime.now(),
        );

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: initialRange,
    );

    if (picked != null) {
      setState(() => selectedRange = picked);
      filterCreditsByDate();
    }
  }

  void _openCreditDetails(Map<String, dynamic> credit) {
    final double amount = (credit['amount'] as num).toDouble();

    final double rate = getCurrentFeeRate(amount.toString());
    final double fee = amount * rate;
    final double amountReceived = amount - fee;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Details(
          amountCredited: "-${formatAmount(amount)}F",
          receiver: "Crédit ID ${credit['id']}",
          amountObtain: "${formatAmount(amountReceived)}F",
          status: credit['status'],
          fee: "${formatAmount(fee)}F",
          dateTime: DateFormat('d MMM yyyy h:mm a')
              .format(DateTime.parse(credit['request_at'])),
          transactionId: (credit['id'] ?? "N/A").toString(),
        ),
      ),
    );
  }

  Widget historyItem(Map<String, dynamic> credit) {
    return InkWell(
      onTap: () => _openCreditDetails(credit),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Crédit ${credit['id']}",
            style: const TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('dd/MM/yyyy HH:mm:ss')
                    .format(DateTime.parse(credit['request_at'])),
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                "+${formatAmount(credit['amount'])} F",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),

          const Divider(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    int totalApproved = user?['credits'] != null
        ? user!['credits']
        .where((c) => c['status'] == 'approved')
        .fold(0, (sum, c) => sum + c['amount'])
        : 0;

    return InactivityScope(
      enable: true,
      child: Scaffold(
        backgroundColor: AppTheme.bgwhite,
        drawer: Drawer(),
        body: Column(
          children: [
            const SizedBox(height: 8),

            /// HEADER BALANCE
            Container(
              color: AppTheme.primary,
              padding: const EdgeInsets.all(20),
              child: GestureDetector(
                onTap: () => setState(() => showBalance = !showBalance),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      showBalance
                          ? "${formatAmount(totalApproved)} F"
                          : "•••••••••",
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.remove_red_eye, color: Colors.white),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            /// ACTIONS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                isProfileCompleted(user!)
                    ? actionItem(Icons.account_balance, "Crédit", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => Credit()),
                  );
                })
                    : actionItem(Icons.person, "Profil", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => Profile()),
                  );
                }),
              ],
            ),

            const SizedBox(height: 8),

            /// FILTRE PAR DATE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton.icon(
                onPressed: pickDateRange,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  minimumSize: const Size.fromHeight(45),
                ),
                icon: const Icon(Icons.date_range, color: Colors.white),
                label: Text(
                  selectedRange != null
                      ? "${selectedRange!.start.toLocal().toString().split(' ')[0]} → ${selectedRange!.end.toLocal().toString().split(' ')[0]}"
                      : "Filtrer par date",
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),

            const SizedBox(height: 8),

            /// LISTE DES CRÉDITS
            Expanded(
              child: RefreshIndicator(
                onRefresh: _isAuth,
                color: AppTheme.primary,
                backgroundColor: Colors.white,
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: filteredCredits.length,
                  itemBuilder: (context, index) {
                    final credit = filteredCredits[index];
                    return historyItem(credit);
                  },
                ),
              ),
            ),
          ],
        ),

        /// FAB SETTINGS
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppTheme.primary,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => Settings()),
          ),
          child: const Icon(Icons.settings, color: Colors.white),
        ),
      ),
    );
  }
}