import 'package:flutter/material.dart';
import 'package:tpi_mybi/CostumColor.dart';
import 'package:tpi_mybi/ui/views/Login/login.dart';
import 'package:tpi_mybi/ui/views/Registration/registration.dart';
import 'package:tpi_mybi/ui/widget/custom_theme.dart';
import 'package:tpi_mybi/ui/widget/home_btn.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomTheme(
      child: Column(
        children: [
          Flexible(
              flex: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 40.0,
                ),
                child: Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      children: [
                        TextSpan(
                            text: 'Welcome !\n',
                            style: TextStyle(
                              color: myPrimaryColor,
                              fontSize: 45.0,
                              fontWeight: FontWeight.w600,
                            )),

                      ],
                    ),
                  ),
                ),
              )),
          Flexible(
            flex: 1,
            child: Align(
              alignment: Alignment.bottomRight,
              child: Row(
                children: [
                  const Expanded(
                    child: HomeBtn(
                      buttonText: 'Sign in',
                      onClick: SignInScreen(),
                      color: Colors.transparent,
                      textColor: myPrimaryColor,
                    ),
                  ),
                  Expanded(
                    child: HomeBtn(
                      buttonText: 'Sign up',
                      onClick: const SignUpScreen(),
                      color: Colors.transparent,
                      textColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}