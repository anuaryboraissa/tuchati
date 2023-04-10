import 'package:tuchati/utils.dart';
import 'package:flutter/material.dart';

import '../../../../constants/app_colors.dart';
import '../../../../widgets/spacer/spacer_custom.dart';

class CallViewWidget extends StatelessWidget {
  const CallViewWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CallCardWidget(
          name: 'Pelican Steve',
          image: "assets/images/user_2.jpg",
          isOnline: true,
          secondTitle: 'Missed Call',
          secondColor: AppColors.redColor,
          time: '32 min',
        ),
        GroupCallCardWidget(),
        CallCardWidget(
          name: 'Jarvis Pepperspray',
          image: "assets/images/user_3.jpg",
          isOnline: true,
          secondTitle: 'Missed Call',
          secondColor: AppColors.redColor,
          time: '1 hour',
        ),
        CallCardWidget(
          name: 'Carnegie Mondover',
          image: "assets/images/user_4.jpg",
          isOnline: true,
          secondTitle: 'Incoming Call',
          secondColor: AppColors.gray,
          time: '2 hour',
        ),
        CallCardWidget(
          name: 'Carnegie Mondover',
          image: "assets/images/user_5.jpg",
          isOnline: false,
          secondTitle: 'Incoming Call',
          secondColor: AppColors.gray,
          time: '2 hour',
        ),
        CallCardWidget(
          name: 'Theodore Handle',
          image: "assets/images/user_6.jpg",
          isOnline: false,
          secondTitle: 'Video Call',
          secondColor: AppColors.gray,
          time: '2 days',
        ),
        CallCardWidget(
          name: 'Theodore Handle',
          image: "assets/images/user_7.jpg",
          isOnline: false,
          secondTitle: 'Video Call',
          secondColor: AppColors.gray,
          time: '2 days',
        ),
        CallCardWidget(
          name: 'Justin Case',
          image: "assets/images/user_8.jpg",
          isOnline: false,
          secondTitle: 'Outgoing Call (2)',
          secondColor: AppColors.gray,
          time: '2 days',
        ),
      ],
    );
  }
}

class GroupCallCardWidget extends StatelessWidget {
  const GroupCallCardWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  image:
                      DecorationImage(image: AssetImage(""), fit: BoxFit.fill),
                  shape: BoxShape.circle,
                ),
              ),
              CustomHeightSpacer(),
              Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  image:
                      DecorationImage(image: AssetImage(""), fit: BoxFit.fill),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          CustomWidthSpacer(),
          Column(
            children: [
              Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  image:
                      DecorationImage(image: AssetImage(""), fit: BoxFit.fill),
                  shape: BoxShape.circle,
                ),
              ),
              CustomHeightSpacer(),
              Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  image:
                      DecorationImage(image: AssetImage(""), fit: BoxFit.fill),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          CustomWidthSpacer(
            size: 0.03,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Friends Group Call",
                  style: SafeGoogleFont(
                    'SF Pro Text',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.2575,
                    letterSpacing: 1,
                    color: Color(0xff1e2022),
                  ),
                ),
                CustomHeightSpacer(
                  size: 0.006,
                ),
                Text(
                  'Video Call',
                  style: SafeGoogleFont(
                    'SF Pro Text',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 1.2575,
                    letterSpacing: 1,
                    color: Color(0xff77838f),
                  ),
                ),
                CustomHeightSpacer(
                  size: 0.006,
                ),
                Text(
                  '34 min',
                  style: SafeGoogleFont(
                    'SF Pro Text',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 1.2575,
                    letterSpacing: 1,
                    color: Color(0xff77838f),
                  ),
                ),
              ],
            ),
          ),
          CustomWidthSpacer(),
          Image.asset(
            "assets/images/user_2.jpg",
            width: 20,
            height: 20,
          ),
          CustomWidthSpacer(
            size: 0.05,
          ),
          Image.asset(
            "assets/images/user_7.jpg",
            width: 15,
            height: 15,
          )
        ],
      ),
    );
  }
}

class CallCardWidget extends StatelessWidget {
  const CallCardWidget({
    super.key,
    required this.name,
    required this.image,
    required this.isOnline,
    required this.secondTitle,
    required this.secondColor,
    required this.time,
  });
  final String name;
  final String image;
  final bool isOnline;

  final String secondTitle;
  final Color secondColor;

  final String time;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(image), fit: BoxFit.fill),
                  shape: BoxShape.circle,
                ),
              ),
              if (isOnline)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.backGroundColor,
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(1.5),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          CustomWidthSpacer(
            size: 0.03,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: SafeGoogleFont(
                    'SF Pro Text',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.2575,
                    letterSpacing: 1,
                    color: Color(0xff1e2022),
                  ),
                ),
                CustomHeightSpacer(
                  size: 0.006,
                ),
                Text(
                  secondTitle,
                  style: SafeGoogleFont(
                    'SF Pro Text',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 1.2575,
                    letterSpacing: 1,
                    color: secondColor,
                  ),
                ),
                CustomHeightSpacer(
                  size: 0.006,
                ),
                Text(
                  '15 min',
                  style: SafeGoogleFont(
                    'SF Pro Text',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 1.2575,
                    letterSpacing: 1,
                    color: Color(0xff77838f),
                  ),
                ),
              ],
            ),
          ),
          CustomWidthSpacer(),
          Image.asset(
            "assets/icons/ic_delete.png",
            width: 20,
            height: 20,
          ),
          CustomWidthSpacer(
            size: 0.05,
          ),
          Image.asset(
            "assets/icons/ic_call.png",
            width: 15,
            height: 15,
          )
        ],
      ),
    );
  }
}
