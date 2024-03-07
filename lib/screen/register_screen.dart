import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:story_app/common.dart';
import 'package:story_app/provider/auth_provider.dart';
import 'package:story_app/utils/result_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Consumer<AuthProvider>(builder: (context, state, _) {
              return Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset(
                      'assets/my_logo.png',
                      width: 100.0,
                      height: 100.0,
                    ),
                    const Center(
                      child: Text(
                        "Story App",
                        style: TextStyle(
                            color: Colors.deepOrange,
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: nameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.pleaseEntName;
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.nameInput,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: emailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.pleaseEntEmail;
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        hintText: "Email",
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: "Password",
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!
                              .pleaseEntPassword;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    context.watch<AuthProvider>().isLoadingRegister
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            style: const ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll<Color>(
                                  Colors.deepOrange),
                              foregroundColor:
                                  MaterialStatePropertyAll(Colors.white),
                            ),
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                final scaffoldMessenger =
                                    ScaffoldMessenger.of(context);
                                await state.register(
                                  nameController.text,
                                  emailController.text,
                                  passwordController.text,
                                );

                                if (state.state.status == Status.registered) {
                                  // ignore: use_build_context_synchronously
                                  context.pop();
                                } else {
                                  scaffoldMessenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        AppLocalizations.of(context)!
                                            .snackbarInvalidAuth,
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                            child: Text(
                                AppLocalizations.of(context)!.buttonRegister),
                          ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(AppLocalizations.of(context)!.textHaveAccount),
                        TextButton(
                          onPressed: () => context.pop(),
                          child:
                              Text(AppLocalizations.of(context)!.buttonLogin),
                        )
                      ],
                    )
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
