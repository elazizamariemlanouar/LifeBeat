import 'package:flutter/material.dart';
//import 'package:flutter/rendering.dart';
import 'package:lifebeat/common/Color_extension.dart';
import 'package:lifebeat/common_widget/on_boarding_page.dart';
import 'package:lifebeat/view/login/signup_view.dart';

class OnBoardingView extends StatefulWidget {
  const OnBoardingView({super.key});

  @override
  State<OnBoardingView> createState() => _OnBoardingViewState();
}

class _OnBoardingViewState extends State<OnBoardingView> {
  int selectPage = 0;
  PageController controller = PageController();

  @override
  void initState() {
    super.initState();

    controller.addListener(() {
      selectPage = controller.page?.round() ?? 0;

      setState(() {});
    });
  }

  List pageList = [
    {
      "title": "Track Your Patient",
      "subtitle":
          "Don't worry if you're unsure about your patient's condition, our system helps you monitor their vital signs in real time.","image": "assets/img/1.png",
    },
    {
      "title": "Stay Connected, Stay Informed",
      "subtitle":
          "Stay connected to your patients anytime, anywhere we keep you informed with live health updates.",
      "image": "assets/img/22.png",
    },
    {
      "title": "Real-Time Health Monitoring",
      "subtitle":
          "Need help keeping track of multiple patients? Our platform simplifies remote monitoring and alerts you instantly when needed.",
      "image": "assets/img/33.png",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      body: Stack(
        alignment: Alignment.bottomRight,
        children: [
          PageView.builder(
              controller: controller,
              itemCount: pageList.length,
              itemBuilder: (context, index) {
                var pObj = pageList[index] as Map? ?? {};
                return OnBoardingPage(
                  pObj: pObj,
                );
              }),
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 70,
                  height: 70,
                  child: CircularProgressIndicator(
                    color: TColor.primaryColor1,
                    value: (selectPage + 1) / 3,
                    strokeWidth: 2,
                  ),
                ),
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                      color: TColor.primaryColor1,
                      borderRadius: BorderRadius.circular(35)),
                  child: IconButton(
                    icon: Icon(
                      Icons.navigate_next,
                      color: TColor.white,
                    ),
                    onPressed: () {
                      if (selectPage < 2) {
                        selectPage = selectPage + 1;

                        controller.animateToPage(selectPage,
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.bounceInOut);

                        // controller.jumpToPage(selectPage);

                        setState(() {});
                      } else {
                        // Open Welcome Screen
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignUpView()));
                      }
                    },
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
