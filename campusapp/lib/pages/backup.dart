// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// class CreatePost extends StatelessWidget {
//   const CreatePost({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         backgroundColor: Colors.black,
//         appBar: AppBar(
//             title: Text(
//                 "New Post",
//                 style: GoogleFonts.oswald(
//                     textStyle: TextStyle(
//                         fontSize: 28,

//                     )
//                 ),
//             ),
//             centerTitle: true,
//             leading: Icon(Icons.arrow_back_ios_new),
//         ),
//         body: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20.0),
//           child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                     const SizedBox(height: 10,),
//                   Text('Title',
//                     style: GoogleFonts.robotoFlex(
//                         textStyle: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white
//                         )
//                     ),
//                   ),
//                   const SizedBox(height: 10,),
//                   Container(
//                       width: MediaQuery.of(context).size.width*0.9,
//                       height: 58,
//                       decoration: BoxDecoration(
//                           border: Border.all(
//                               color: const Color.fromARGB(162, 255, 255, 255)
//                           ),
//                           borderRadius: BorderRadius.circular(10)
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.only(left: 10.0),
//                         child: TextField(
//                             cursorHeight: 25,
//                             autocorrect: true,
//                             minLines: null,
//                             maxLines: null,
//                             expands: true,
//                           decoration: InputDecoration(
//                               border: InputBorder.none,
//                               //helperText: "title",
//                               hintText: "Title",
                              
//                           ),
//                         ),
//                       ),
//                   )
//               ],
//           ),
//         ),
//     );
//   }
// }
