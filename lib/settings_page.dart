import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend/home_page.dart';

class MySettingsPage extends StatefulWidget {
  @override
  _MySettingsPageState createState() => _MySettingsPageState();
}

class _MySettingsPageState extends State<MySettingsPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _updateEmail() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateEmail(_emailController.text.trim());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email успешно обновлен')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Пользователь не авторизован')),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при обновлении email: ${e.message}')),
      );
    }
  }

  Future<void> _updatePassword() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(_newPasswordController.text.trim());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Пароль успешно обновлен')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Пользователь не авторизован')),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при обновлении пароля: ${e.message}')),
      );
    }
  }

  Future<void> _reauthenticateAndUpdatePassword() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Запросите у пользователя текущий пароль для повторной аутентификации
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: _passwordController.text.trim(),
        );

        // Повторная аутентификация
        await user.reauthenticateWithCredential(credential);

        // Обновление пароля
        await user.updatePassword(_newPasswordController.text.trim());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Пароль успешно обновлен')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Пользователь не авторизован')),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: ${e.message}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MyHomePage()),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'New email',
                hintText: 'Enter new email',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateEmail,
              child: const Text(
                'Update email',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Current password',
                hintText: 'Enter your current password',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _newPasswordController,
              decoration: const InputDecoration(
                labelText: 'New password',
                hintText: 'Enter new password',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _reauthenticateAndUpdatePassword,
              child: const Text(
                'Change password',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
