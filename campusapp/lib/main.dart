import 'package:campusapp/core/app_colors.dart';
import 'package:campusapp/pages/community_page.dart';
import 'package:campusapp/pages/create_post.dart';
import 'package:campusapp/pages/dashboard.dart';
import 'package:campusapp/pages/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
//import 'package:campusapp/pages/study_page.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
//import 'package:google_fonts/google_fonts.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['supabase_url'] ?? '',
    anonKey: dotenv.env['supabase_key'] ?? '',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Campus App',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,

        scaffoldBackgroundColor: AppColors.accentBorder,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          brightness: Brightness.dark,
          surface: AppColors.cardGrey, // Global card color
          onSurface: AppColors.textMain,
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          //centerTitle: true,
          iconTheme: IconThemeData(color: AppColors.textMain),
          titleTextStyle: TextStyle(
            color: AppColors.textMain,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColors.textMain),
          bodyMedium: TextStyle(color: AppColors.textSecondary),
        ),
      ),
      //home: LoginPage(),
      // home: StudyPage(),
      home:  Dashboard(),
      //home: CreatePost(),
    );
  }
}
