import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:frontend/home_page.dart';
import 'package:frontend/login_page.dart';

class SignUpPage extends StatefulWidget {
  static route() => MaterialPageRoute(
        builder: (context) => const SignUpPage(),
      );
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> createUserWithEmailAndPassword() async {
    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailController.text.trim(),
              password: passwordController.text.trim());
      // print(userCredential.user?.uid); // конкретный идентификатор

      if (userCredential.user != null) {
        print("Пользователь успешно вошел: ${userCredential.user!.uid}");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      print("Ошибка входа: ${e.message}");
      ScaffoldMessenger.of(context).showSnackBar(
        // SnackBar(content: Text("Ошибка входа: ${e.message}")),
        const SnackBar(content: Text("Ошибка входа")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: Center(
              child: Container(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context)
                        .size
                        .height, // Минимальная высота экрана
                  ),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Form(
                          key: formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                'Sign Up.',
                                style: TextStyle(
                                  fontSize: 50,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: emailController,
                                decoration: const InputDecoration(
                                  hintText: 'Email',
                                ),
                              ),
                              const SizedBox(height: 15),
                              TextFormField(
                                controller: passwordController,
                                decoration: const InputDecoration(
                                  hintText: 'Password',
                                ),
                                obscureText: true,
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () async {
                                  await createUserWithEmailAndPassword();
                                },
                                child: const Text(
                                  'SIGN UP',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(context, LoginPage.route());
                                },
                                child: RichText(
                                  text: TextSpan(
                                    text: 'Already have an account? ',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                    children: [
                                      TextSpan(
                                        text: 'Sign In',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ])),
            )));
  }
}
