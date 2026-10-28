import 'package:flutter/material.dart';
import 'package:lifebeat/common/Color_extension.dart';
import 'package:lifebeat/view/on_boarding/on_boarding_view.dart';
import '../../common_widget/round_button.dart';

class StartedView extends StatefulWidget {
  const StartedView({super.key});

  @override
  State<StartedView> createState() => _StartedViewState();
}

class _StartedViewState extends State<StartedView> {
  bool isChangeColor = false;

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: TColor.white,
      body: Container(
        width: media.width,
        decoration: BoxDecoration(
          gradient: isChangeColor
              ? LinearGradient(
                  colors: TColor.primaryG,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            
            // ✅ Logo
            Image.asset(
              isChangeColor
                  ? 'assets/img/logo2.png'
                  : 'assets/img/logo1.png',
              height: 120,
            ),

            const SizedBox(height: 50),

            // Title
            Text(
              "LifeBeat",
              style: TextStyle(
                color: TColor.black,
                fontSize: 36,
                fontWeight: FontWeight.w700,
              ),
            ),

            Text(
              "Monitor Everything",
              style: TextStyle(
                color: TColor.grey,
                fontSize: 18,
              ),
            ),

            const Spacer(),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30),
                child: RoundButton(
                  title: "Start Now",
                  type: isChangeColor
                      ? RoundButtonType.textGradient
                      : RoundButtonType.bgGradient,
                  onPressed: () {
                    if (isChangeColor) {
                      // Go to next screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OnBoardingView(),
                        ),
                      );
                    } else {
                      // Change color and logo
                      setState(() {
                        isChangeColor = true;
                      });
                    }
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
