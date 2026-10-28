import 'package:lifebeat/common/Color_extension.dart';
import 'package:lifebeat/common/form_popup.dart';
import 'package:lifebeat/common_widget/tab_button.dart';
import 'package:flutter/material.dart';
import '../profile/profile_view.dart';
import '../home/home_view.dart';



class MainTabView extends StatefulWidget {
  const MainTabView({super.key});
  
  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView> {
  int selectTab = 0;
  final PageStorageBucket pageBucket = PageStorageBucket(); 
  Widget currentTab = const HomeView();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      body: PageStorage(bucket: pageBucket, child: currentTab),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: InkWell(
          onTap: () {FormPopup.showFormDialog(context);},
          child: Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: TColor.primaryG,
                ),
                borderRadius: BorderRadius.circular(35),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 2,)
                ]),
            child: Icon(Icons.add,color: TColor.white, size: 50, ),
          ),
        ),
      ),
      bottomNavigationBar: Container (
        height: 65,
        decoration: BoxDecoration(color: TColor.white, boxShadow: const  [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -3))
        ]),
         child: BottomAppBar(
          color: TColor.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TabButton(
                icon: "assets/img/Home.png",
                selectIcon: "assets/img/Home-Active.png",
                isActive: selectTab == 0,
                onTap: () {
                  selectTab = 0;
                  currentTab = const HomeView();
                  if (mounted) {
                    setState(() {});
                  }
                }),

              const  SizedBox(width: 50,),

            TabButton(
                icon: "assets/img/Profile.png" ,
                selectIcon: "assets/img/Profile-Active.png",
                isActive: selectTab == 3,
                onTap: () {
                  selectTab = 3;
                   currentTab = const ProfileView();
                  if (mounted) {
                    setState(() {});
                  }
                })
          ],
        ),
      )),
    );
  }
}