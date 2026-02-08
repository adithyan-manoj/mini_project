import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isPassword;
  final TextEditingController textController;

  const CustomTextField({super.key, required this.icon, required this.isPassword, required this.label, required this.textController});

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {

  late bool _obscureText;
  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword; 
  }

  @override
  Widget build(BuildContext context) {

    double responsiveWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: responsiveWidth*0.9,
        height: 65,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color.fromARGB(255, 212, 212, 212)),
        ),
        child: TextFormField(
          controller: widget.textController,
          obscureText: _obscureText,
          // validator: (value) {
          //   if(value == null || value.isEmpty) {
          //     return 'Please enter your ${widget.label}';
          //   }
          //   if(widget.label == "Email Address" && !value.contains('@')) {
          //     return 'Enter a valid email';
          //   }
          //   return null;
          // },
          decoration: InputDecoration(
            prefixIcon: Icon(widget.icon, color: const Color.fromARGB(255, 92, 92, 92),size: 30),
            labelText: widget.label,
            //hintText: widget.label,
            border: InputBorder.none,
            //contentPadding: EdgeInsets.symmetric(vertical: 13),
            errorStyle: const TextStyle(
              fontSize: 10,
              color: Colors.red,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 13, horizontal: 50),
            errorMaxLines: 1,
            suffixIcon: widget.isPassword? IconButton(
              icon: Icon(_obscureText? Icons.visibility_outlined :Icons.visibility_off_outlined , color: Colors.grey,size:25,),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
              ) : null,
          ),
        )
      
      ),
    );
  }
}