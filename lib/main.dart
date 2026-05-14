import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Farah's Pages
import 'screens/admin_dashboard.dart'; 
import 'screens/parent_dashboard.dart'; 
import 'screens/forgot_password.dart'; 

// --- YOUR PAGE IMPORT ---
// Updated to match your original main.dart import path
import 'screens/teacher_dashboard.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Using the shared Firebase project configuration
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KindiSync',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Using Teal to match your Teacher Dashboard theme
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      // App starts at Login; redirected to TeacherDashboard based on credentials
      home: const LoginPage(), 
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError("Please fill in all fields.");
      return;
    }

    setState(() => _isLoading = true);

    // 1. ADMIN LOGIN (Farah's Logic)
    if (email == "admin@kindisync.com" && password == "admin123") {
      _logToFirestore('admin_login', email);
      _navigateTo(const AdminDashboard());
      return;
    }

    // 2. TEACHER LOGIN (Added for your module)
    // Use these credentials to view your Teacher Dashboard
    if (email == "teacher@kindisync.com" && password == "teacher123") {
      _logToFirestore('teacher_login', email);
      _navigateTo(const TeacherDashboard());
      return;
    }

    // 3. PARENT LOGIN (Firebase Auth)
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _logToFirestore('parent_login', email);
      _navigateTo(const ParentDashboard());
      
    } on FirebaseAuthException catch (e) {
      String message = "An error occurred.";
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        message = "User does not exist or incorrect password.";
      }
      _showError(message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateTo(Widget page) {
    setState(() => _isLoading = false);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => page),
      );
    }
  }

  void _logToFirestore(String action, String email) {
    FirebaseFirestore.instance.collection('logs').add({
      'action': action,
      'email': email,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            width: 380, 
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.child_care, size: 80, color: Colors.teal),
                const SizedBox(height: 16),
                const Text("KindiSync", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 32),
                
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: "Email", 
                    border: OutlineInputBorder(), 
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 16),
                
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Password", 
                    border: OutlineInputBorder(), 
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
                      );
                    },
                    child: const Text("Forgot Password?", style: TextStyle(color: Colors.teal, fontWeight: FontWeight.w600)),
                  ),
                ),

                const SizedBox(height: 12),
                
                _isLoading 
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("Login"),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}