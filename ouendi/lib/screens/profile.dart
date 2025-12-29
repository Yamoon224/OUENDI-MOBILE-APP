import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ouendi/app/colors/appTheme.dart';
import 'package:ouendi/app/helpers/widgets.dart';
import 'package:ouendi/app/helpers/inactivity_scope.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ouendi/app/controllers/profile_service.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController lastNameController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController levelClassController = TextEditingController();
  TextEditingController universityController = TextEditingController();

  File? cniFile;
  File? studentCardFile;
  File? photoFile;

  Map<String, dynamic>? user;
  bool _isLoading = true;

  String? selectedLevelClass;

  final List<String> levelClasses = [
    'LICENCE I',
    'LICENCE II',
    'LICENCE III',
    'MASTER I',
    'MASTER II',
    'DOCTORAT'
  ];

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString('user');
    if (userJson != null) {
      user = jsonDecode(userJson);
      lastNameController.text = user!['last_name'] ?? '';
      firstNameController.text = user!['first_name'] ?? '';
      emailController.text = user!['email'] ?? '';
      levelClassController.text = user!['level_class'] ?? '';
      universityController.text = user!['university'] ?? '';
      selectedLevelClass = user!['level_class'];

      // Récupérer les fichiers stockés si existants
      String? cniPath = prefs.getString('cniFile');
      String? studentCardPath = prefs.getString('studentCardFile');
      String? photoPath = prefs.getString('photoFile');

      if (cniPath != null && cniPath.isNotEmpty) cniFile = File(cniPath);
      if (studentCardPath != null && studentCardPath.isNotEmpty) studentCardFile = File(studentCardPath);
      if (photoPath != null && photoPath.isNotEmpty) photoFile = File(photoPath);
    }
    setState(() => _isLoading = false);
  }

  Future<void> pickFile(ImageSource source, String type) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        if (type == 'cni') cniFile = File(pickedFile.path);
        if (type == 'student_card') studentCardFile = File(pickedFile.path);
        if (type == 'photo') photoFile = File(pickedFile.path);
      });
    }
  }

  Widget filePickerField(String label, File? file, String type) {
    IconData icon;
    switch (type) {
      case 'cni':
        icon = Icons.badge;
        break;
      case 'student_card':
        icon = Icons.school;
        break;
      case 'photo':
        icon = Icons.person;
        break;
      default:
        icon = Icons.upload_file;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (file != null)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.primary),
              image: DecorationImage(image: FileImage(file), fit: BoxFit.cover),
            ),
          ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => pickFile(ImageSource.gallery, type),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary.withOpacity(0.8),
              minimumSize: const Size.fromHeight(50),
            ),
            icon: Icon(icon, color: AppTheme.bgwhite),
            label: Text(
              file != null ? "$label sélectionné" : "Sélectionner $label",
              style: const TextStyle(fontSize: 18, color: AppTheme.bgwhite),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return InactivityScope(
      enable: true,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Profil", style: TextStyle(color: AppTheme.bgwhite, fontSize: 24)),
          backgroundColor: AppTheme.primary,
          foregroundColor: AppTheme.bgwhite,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 10),
                TextFormField(
                  controller: lastNameController,
                  style: const TextStyle(fontSize: 16),
                  decoration: inputDecoration("Nom"),
                  validator: (v) => v == null || v.isEmpty ? "Obligatoire" : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: firstNameController,
                  style: const TextStyle(fontSize: 16),
                  decoration: inputDecoration("Prénom"),
                  validator: (v) => v == null || v.isEmpty ? "Obligatoire" : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: emailController,
                  style: const TextStyle(fontSize: 16),
                  decoration: inputDecoration("Email"),
                  validator: (v) => v == null || v.isEmpty ? "Obligatoire" : null,
                ),
                const SizedBox(height: 15),
                // Dropdown pour la classe
                DropdownButtonFormField<String>(
                  value: selectedLevelClass,
                  decoration: inputDecoration("Classe"),
                  items: levelClasses.map((level) {
                    return DropdownMenuItem<String>(
                      value: level,
                      child: Text(level),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedLevelClass = value;
                      levelClassController.text = value ?? '';
                    });
                  },
                  validator: (v) => v == null || v.isEmpty ? "Obligatoire" : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: universityController,
                  style: const TextStyle(fontSize: 16),
                  decoration: inputDecoration("Université"),
                  validator: (v) => v == null || v.isEmpty ? "Obligatoire" : null,
                ),
                const SizedBox(height: 20),
                filePickerField("CNI", cniFile, 'cni'),
                const SizedBox(height: 15),
                filePickerField("Carte Étudiante", studentCardFile, 'student_card'),
                const SizedBox(height: 15),
                filePickerField("Photo", photoFile, 'photo'),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () async {
                    await ProfileService.edit(
                      formKey: _formKey,
                      user: user,
                      context: context,
                      lastNameController: lastNameController,
                      firstNameController: firstNameController,
                      emailController: emailController,
                      levelClassController: levelClassController,
                      universityController: universityController,
                      cniFile: cniFile,
                      studentCardFile: studentCardFile,
                      photoFile: photoFile,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: const Text("Mettre A Jour", style: TextStyle(fontSize: 18, color: AppTheme.bgwhite)),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      )
    );
  }
}