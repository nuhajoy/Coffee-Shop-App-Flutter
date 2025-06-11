import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:coffee_management/core/theme.dart';
import 'package:coffee_management/features/auth/providers/auth_provider.dart';
import 'package:coffee_management/features/auth/models/user_model.dart';
import 'package:coffee_management/shared/widgets/custom_text_field.dart';
import 'package:coffee_management/shared/widgets/custom_button.dart';
import 'package:coffee_management/shared/utils/validators.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}
class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    // Keep your original listener - this handles database authentication
    ref.listen<AsyncValue<void>>(authNotifierProvider, (_, state) async {
      state.whenOrNull(
        data: (_) async {
          // Wait a moment for the user data to load from database
          await Future.delayed(const Duration(milliseconds: 300));

          try {
            // Get user role from database
            final userRole = await ref.read(userRoleProvider.future);
            final user = await ref.read(currentUserProvider.future);

            if (mounted) {
              // Show welcome message with role
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Welcome ${user?.fullName ?? 'User'}! Logged in as ${userRole.displayName}',
                  ),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );

              // Navigate to dashboard
              context.go('/dashboard');
            }
          } catch (e) {
            // If role fetching fails, still navigate but without role message
            if (mounted) {
              context.go('/dashboard');
            }
          }
        },
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login failed: $error'),
              backgroundColor: AppTheme.error,
            ),
          );
        },
      );
    });

    return Scaffold(
      backgroundColor: AppTheme.darkBrown,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),

                // Logo/Icon
                Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    color: AppTheme.lightBrown,
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: const Icon(
                    Icons.coffee,
                    size: 60,
                    color: AppTheme.darkBrown,
                  ),
                ),

                const SizedBox(height: 40),

                // Title
                const Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                const Text(
                  'Sign in to your account',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // Email Field
                CustomTextField(
                  controller: _emailController,
                  labelText: 'Email',
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),

                const SizedBox(height: 20),

                // Password Field
                CustomTextField(
                  controller: _passwordController,
                  labelText: 'Password',
                  prefixIcon: Icons.lock,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: AppTheme.textSecondary,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: Validators.password,
                ),

                const SizedBox(height: 30),

                // Login Button - BACK TO YOUR ORIGINAL
                CustomButton(
                  text: 'Sign In',
                  isLoading: authState.isLoading,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ref.read(authNotifierProvider.notifier).signIn(
                            email: _emailController.text.trim(),
                            password: _passwordController.text,
                          );
                    }
                  },
                ),

                const SizedBox(height: 20),

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Colors.white70),
                    ),
                    TextButton(
                      onPressed: () => context.go('/register'),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: AppTheme.lightBrown,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
