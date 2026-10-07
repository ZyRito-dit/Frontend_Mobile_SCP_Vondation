import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/di/injection.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/scp/presentation/pages/main_navigation_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const SCPApp());
}

class SCPApp extends StatefulWidget {
  const SCPApp({super.key});

  @override
  State<SCPApp> createState() => _SCPAppState();
}

class _SCPAppState extends State<SCPApp> {
  bool isDarkMode = true;

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthBloc>()..add(CheckAuthEvent()),
      child: MaterialApp(
        title: 'SCP Secure Archive',
        debugShowCheckedModeBanner: false,
        themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
        theme: ThemeData.light().copyWith(
          primaryColor: Colors.grey[300],
          scaffoldBackgroundColor: const Color(0xFFF0F0F0),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 1,
          ),
          cardTheme: CardThemeData(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
              side: const BorderSide(color: Colors.black12, width: 1),
            ),
          ),
          textTheme: GoogleFonts.firaCodeTextTheme(ThemeData.light().textTheme),
        ),
        darkTheme: ThemeData.dark().copyWith(
          primaryColor: Colors.black,
          scaffoldBackgroundColor: const Color(0xFF121212),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 1,
          ),
          cardTheme: CardThemeData(
            color: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
              side: const BorderSide(color: Color(0xFF333333), width: 1),
            ),
          ),
          textTheme: GoogleFonts.firaCodeTextTheme(ThemeData.dark().textTheme),
        ),
        home: MainNavigationPage(toggleTheme: toggleTheme, isDarkMode: isDarkMode),
      ),
    );
  }
}
