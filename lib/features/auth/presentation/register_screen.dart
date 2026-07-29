import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../shared/widgets/app_logo.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_text_field.dart';
import '../services/auth_service.dart';

import '../../../shared/navigation/main_navigation_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;
  bool isLoading = false;

  final AuthService authService = AuthService();
  

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> register() async {
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill in all fields."),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final credential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      await credential.user?.updateDisplayName(
         nameController.text.trim(),
      );
      await credential.user?.reload();

     
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Account created successfully."),
        ),
      );

            
       Navigator.pushReplacement(
         context,
         MaterialPageRoute(
           builder: (_) => const MainNavigationScreen(),
         ),
       );

    } 
      on FirebaseAuthException catch (e) {
      String message = "Registration failed.";

      switch (e.code) {
        case "email-already-in-use":
          message = "An account already exists with this email.";
          break;

        case "invalid-email":
          message = "Please enter a valid email.";
          break;

        case "weak-password":
          message = "Password must be at least 6 characters.";
          break;

        default:
          message = e.message ?? message;
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );

    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );

    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              const Center(
                child: AppLogo(size: 130),
              ),

              const SizedBox(height: 30),

              const Text(
                "Create Account",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Join eLyon today",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 40),
              AuthTextField(
                hint: "Full Name",
                icon: Icons.person_outline,
                controller: nameController,
              ),

              const SizedBox(height: 20),

              AuthTextField(
                hint: "Email",
                icon: Icons.email_outlined,
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 20),

              AuthTextField(
                hint: "Password",
                icon: Icons.lock_outline,
                controller: passwordController,
                obscureText: obscurePassword,
              ),

              const SizedBox(height: 30),

              AuthButton(
                text: "Create Account",
                isLoading: isLoading,
                onPressed: register,
              ),

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account?"),

                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Login"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}