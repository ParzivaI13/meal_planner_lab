import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegistrationScreen extends StatefulWidget {
  final void Function()? onTap;

  const RegistrationScreen({super.key, required this.onTap});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );


      } on FirebaseAuthException catch (e) {
        String message = 'Сталася помилка. Спробуйте ще раз.';
        if (e.code == 'weak-password') {
          message = 'Пароль занадто слабкий.';
        } else if (e.code == 'email-already-in-use') {
          message = 'Акаунт з такою поштою вже існує.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Невідома помилка: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🍽️', style: TextStyle(fontSize: 60)),
                const SizedBox(height: 10),
                const Text('Створити акаунт', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF28a745))),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(hintText: "Ім'я"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Будь ласка, введіть ваше ім'я";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(hintText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty || !value.contains('@')) {
                      return 'Будь ласка, введіть коректний email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(hintText: 'Пароль'),
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Пароль має містити щонайменше 6 символів';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Зареєструватися'),
                  ),
                ),
                const SizedBox(height: 20),
                OutlinedButton(
                onPressed: widget.onTap,
                child: const Text('Вже маю акаунт'),
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}