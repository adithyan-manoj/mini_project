import 'package:flutter/material.dart';




class CustomButton extends StatelessWidget {

  final VoidCallback onPressed;
  final String label;
  final bool isLoading;

  CustomButton({super.key, required this.onPressed, required this.label, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    double responsiveWidth = MediaQuery.of(context).size.width * 0.9;
    return SizedBox(
      width: responsiveWidth,
      height: 60,
      child: ElevatedButton(
        onPressed: isLoading? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 255, 159, 80),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(15),
            
          ),
          elevation: 3,
          shadowColor: Color.fromARGB(255, 255, 159, 80).withOpacity(0.4),
        ),
        child: isLoading? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
        
        
        : Text(label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 25,
          letterSpacing: 1.5,
        ),) ,
        
        ),
    );
  }
}