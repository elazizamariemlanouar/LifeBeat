// ignore: duplicate_ignore
// ignore: file_names, duplicate_ignore
// ignore: file_names, duplicate_ignore
// ignore: file_names, duplicate_ignore
// ignore: file_names
// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:lifebeat/common/color_extension.dart';
import '../../common_widget/round_textfield.dart';
import '../../common_widget/round_button.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final TextEditingController txtFirstName = TextEditingController();
  final TextEditingController txtLastName = TextEditingController();
  final TextEditingController txtEmail = TextEditingController();
  final TextEditingController txtPassword = TextEditingController();
  final TextEditingController txtPhone = TextEditingController();
  final TextEditingController txtLocation = TextEditingController();
  final TextEditingController txtBirthdate = TextEditingController();

  String selectedGender = "Male";

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: TColor.white,
        elevation: 0,
        leading:IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, // Remplace par le chemin de ton icône flèche
            size: 20,

          ),
          onPressed: () {
            Navigator.pop(context); // Ferme la page actuelle
          },
        ),
        foregroundColor: TColor.black,
      ),
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Column(
          children: [
            RoundTextField(
              controller: txtFirstName,
              hitText: "First Name",
              icon: "assets/img/user.png",
            ),
            SizedBox(height: media.width * 0.04),
            RoundTextField(
              controller: txtLastName,
              hitText: "Last Name",
              icon: "assets/img/user.png",
            ),
            SizedBox(height: media.width * 0.04),
            RoundTextField(
              controller: txtEmail,
              hitText: "Email",
              icon: "assets/img/Message.png",
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: media.width * 0.04),
            RoundTextField(
              controller: txtPassword,
              hitText: "Password",
              icon: "assets/img/Lock.png",
              obscureText: true,
            ),
            SizedBox(height: media.width * 0.04),
            RoundTextField(
              controller: txtPhone,
              hitText: "Phone Number",
              icon: "assets/img/Message.png",
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: media.width * 0.04),
            Container(
              decoration: BoxDecoration(
                color: TColor.lightGray,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Container(
                    alignment: Alignment.center,
                    width: 50,
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Image.asset(
                      "assets/img/user.png",
                      width: 20,
                      height: 20,
                      fit: BoxFit.contain,
                      color: TColor.grey,
                    ),
                  ),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedGender,
                        items: ["Male", "Female"].map((name) {
                          return DropdownMenuItem(
                            value: name,
                            child: Text(
                              name,
                              style: TextStyle(
                                color: TColor.grey,
                                fontSize: 14,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedGender = value!;
                          });
                        },
                        isExpanded: true,
                        hint: Text(
                          "Choose Gender",
                          style: TextStyle(
                            color: TColor.grey,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
            SizedBox(height: media.width * 0.04),
            RoundTextField(
              controller: txtBirthdate,
              hitText: "Date of Birth",
              icon: "assets/img/Calendar.png",
            ),
            SizedBox(height: media.width * 0.04),
            RoundTextField(
              controller: txtLocation,
              hitText: "Location",
              icon: "assets/img/Location.png",
            ),
            SizedBox(height: media.width * 0.08),
            RoundButton(
              title: "Save",
              onPressed: () {
                // Ici, tu peux simplement afficher les infos pour test
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Profile Updated"),
                    content: Text(
                      "First Name: ${txtFirstName.text}\n"
                      "Last Name: ${txtLastName.text}\n"
                      "Email: ${txtEmail.text}\n"
                      "Phone: ${txtPhone.text}\n"
                      "Location: ${txtLocation.text}\n"
                      "Gender: $selectedGender\n"
                      "DOB: ${txtBirthdate.text}",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("OK"),
                      )
                    ],
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
