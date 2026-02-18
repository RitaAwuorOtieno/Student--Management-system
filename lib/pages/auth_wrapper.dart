import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../services/auth_service.dart';
import '../provider/user_provider.dart';
import '../models/user_model.dart';
import 'landing_page.dart';
import 'home_page.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _auth = AuthService();
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<AppUser?>? _userSubscription;

  @override
  void initState() {
    super.initState();
    _authSubscription = _auth.authStateChanges().listen((User? user) async {
      if (user == null) {
        if (mounted) {
          Provider.of<UserProvider>(context, listen: false).setUser(null);
        }
      } else {
        // Load user data and subscribe to changes
        await Provider.of<UserProvider>(context, listen: false)
            .loadUser(user.uid);
            
        // Clear navigation stack (close Login Page) to show Home Page
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }

        _userSubscription = Provider.of<UserProvider>(context, listen: false)
            .userStream(user.uid)
            .listen((AppUser? appUser) {
          Provider.of<UserProvider>(context, listen: false).setUser(appUser);
        });
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _userSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        // Show loading while checking auth state
        if (userProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If no user is logged in, show landing page
        if (userProvider.currentUser == null) {
          return const LandingPage();
        }

        // If user is logged in, show home page with bottom navigation
        return const HomePage();
      },
    );
  }
}
