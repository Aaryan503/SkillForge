import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class ThemeMethod {
  ThemeData themeData = ThemeData(
        useMaterial3: true,
        
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF021526),
          primary: const Color(0xFF021526),
          secondary: const Color(0xFF03346E),
          tertiary: const Color(0xFF6EACDA),
          surface: Colors.white,
          brightness: Brightness.light,
        ),
        
        textTheme: GoogleFonts.poppinsTextTheme().apply(
          bodyColor: const Color(0xFF1D1E20),
          displayColor: const Color(0xFFFAF8FC),
        ),

        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: const Color(0xFFFAF8FC),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1D1E20),
          ),
          iconTheme: const IconThemeData(
            color: Color(0xFF1D1E20),
          ),
        ),
        
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF021526),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 4,
          shadowColor: const Color(0xFF021526).withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        ),
        
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: const Color(0xFF021526),
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF021526), width: 2),
          ),
          hintStyle: GoogleFonts.poppins(
            color: Colors.grey[400],
            fontSize: 14,
          ),
        ),
        

        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF021526),
          unselectedItemColor: Color(0xFF9E9E9E),
          type: BottomNavigationBarType.fixed,
          elevation: 8,
          showSelectedLabels: true,
          showUnselectedLabels: true,
        ),
      );
}