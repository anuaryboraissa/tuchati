import 'dart:io';

import 'package:tuchati/screens/main_tab_bar/widgets/bottom_icon_widget.dart';
import 'package:tuchati/screens/page/friends.dart';
import 'package:tuchati/screens/page/page.dart';
import 'package:tuchati/screens/page/profile.dart';
import 'package:tuchati/screens/page/settings.dart';
import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../message_list/message_list.dart';

class MainTabBar extends StatefulWidget {
  const MainTabBar({Key? key}) : super(key: key);

  @override
  _MainTabBarState createState() => _MainTabBarState();
}

class _MainTabBarState extends State<MainTabBar> {
  int pageIndex = 0;

  final pages = [
    const MessageListPage(),
  
    const FriendsPage(),
    const ProfilePage(),
    const Settings(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: pages[pageIndex],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 60,
          color: Theme.of(context).bottomAppBarColor,
          margin: const EdgeInsets.only(top: 2, right: 0, left: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () {
                    setState(() {
                      pageIndex = 0;
                    });
                },
                child: BottomIconWidget(
                  title: 'Messages',
                  iconName: "assets/icons/ic_message.png",
                  iconColor: pageIndex == 0 ? AppColors.appColor : AppColors.gray,
                 
                ),
              ),

        
              GestureDetector(
                onTap: () {
                    setState(() {
                      pageIndex = 1;
                    });
                },
                child: BottomIconWidget(
                  title: 'Friends',
                  iconName: "assets/icons/users.png",
                  iconColor: pageIndex == 1 ? AppColors.appColor : AppColors.gray,
            
                ),
              ),
                    GestureDetector(
                onTap: () {
                     setState(() {
                      pageIndex = 2;
                    });
                },
                child: BottomIconWidget(
                  title: 'Profile',
                  iconName: "assets/icons/ic_user.png",
                  iconColor: pageIndex == 2 ? AppColors.appColor : AppColors.gray,
                
                ),
              ),

              GestureDetector(
                onTap: () {
                     setState(() {
                      pageIndex = 3;
                    });
                },
                child: BottomIconWidget(
                  title: 'Settings',
                  iconName: "assets/icons/ic_settings.png",
                  iconColor: pageIndex == 3 ? AppColors.appColor : AppColors.gray,
                 
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
