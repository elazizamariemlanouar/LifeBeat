import 'package:flutter/material.dart';
import 'package:lifebeat/common/color_extension.dart';
import 'package:lifebeat/view/home/home_view.dart';
import '../../common_widget/round_button.dart';
import '../../common_widget/round_textfield.dart';
import 'package:lifebeat/view/main_tab/main_tab_view.dart';
class FormPopup {
static void showFormDialog(BuildContext context) {
    TextEditingController txtDate = TextEditingController();
    TextEditingController txtFirstName = TextEditingController();
    TextEditingController txtLastName = TextEditingController();
    TextEditingController txtDisease = TextEditingController();
    TextEditingController txtLocation = TextEditingController();

    var media = MediaQuery.of(context).size;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: TColor.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: SafeArea(
            child: Column(
              children: [
                Text(
                  "Let’s complete your patient profile",
                  style: TextStyle(
                    color: TColor.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  "It will help us to know more about your patient!",
                  style: TextStyle(color: TColor.grey, fontSize: 12),
                ),
                SizedBox(height: media.width * 0.03),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Column(
                    children: [
                      // Last Name
                      RoundTextField(
                        controller: txtLastName,
                        hitText: "Last Name",
                        icon: "assets/img/user.png",
                      ),

                      SizedBox(height: media.width * 0.04),

                      // First Name
                      RoundTextField(
                        controller: txtFirstName,
                        hitText: "First Name",
                        icon: "assets/img/user.png",
                      ),

                      SizedBox(height: media.width * 0.04),

                      // Gender Dropdown
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
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
                                child: DropdownButton(
                                  items: ["Male", "Female"]
                                      .map((name) => DropdownMenuItem(
                                            value: name,
                                            child: Text(
                                              name,
                                              style: TextStyle(
                                                color: TColor.grey,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                  onChanged: (value) {},
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

                      // Date of Birth (Age)
                      RoundTextField(
                        controller: txtDate,
                        hitText: "Date of Birth",
                        icon: "assets/img/Calendar.png",
                      ),

                      SizedBox(height: media.width * 0.04),

                      // Disease
                      RoundTextField(
                        controller: txtDisease,
                        hitText: "Disease",
                        icon: "assets/img/stethoscope.png",
                      ),

                      SizedBox(height: media.width * 0.04),

                      // Location
                      RoundTextField(
                        controller: txtLocation,
                        hitText: "Location",
                        icon: "assets/img/Location.png",
                      ),

                      SizedBox(height: media.width * 0.07),

                      // Button
                      RoundButton(
                        title: "Next >",
                        onPressed: () {
                        String fullName = "${txtLastName.text} ${txtFirstName.text}";
                        HomeView.addPatient(fullName);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const MainTabView()),
                          );

                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
