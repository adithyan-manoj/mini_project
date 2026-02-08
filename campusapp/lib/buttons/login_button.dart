import 'package:flutter/material.dart';

// not yet used in the code
class LoginButton extends StatelessWidget {
  final bool isActive;
  final String title;

  const LoginButton({super.key, required this.isActive, required this.title});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: AnimatedContainer(
        duration:const Duration(milliseconds: 100),
        curve: Curves.easeIn,
        //margin: EdgeInsets.only(left: 7),
        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 17),
        //width: 180,
        //height: 55,
        decoration: BoxDecoration(
          color: isActive
              ? Color.fromARGB(255, 255, 255, 255)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(50),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    offset: Offset(2, 2),
                    blurRadius: 8,
                    color: Colors.black.withOpacity(0.09),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 23,
              color: isActive ? Colors.black : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }
}
