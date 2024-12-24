import 'package:client/core/theme/app_pallete.dart';
import 'package:client/core/utils.dart';
import 'package:client/core/widgets/loader.dart';
import 'package:client/features/auth/view/pages/signin_page.dart';
import 'package:client/features/auth/view/widgets/auth_gradient_button.dart';
import 'package:client/core/widgets/custom_field.dart';
import 'package:client/viewmodel/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {

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
    formKey.currentState!.validate();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authViewmodelProvider.select((val) => val?.isLoading == true));
    ref.listen(authViewmodelProvider, 
    (_, next) {
      next?.when(
        data: (data) {
          showSnackBar(context, 'Account created successfully! Please Login.');
          Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
        }, 
        error: (error, st) {
          showSnackBar(context, error.toString());
        }, 
        loading: () {
          // Handling loading cannot allow any return any Loader widget 
          // This is because ref.listen is "void" method
        }
      );
    });

    return Scaffold(
      appBar: AppBar(),
      body: isLoading ? const CustomLoader()
      : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: formKey,
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Sign Up", style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold)),
                
                const SizedBox(height: 30),
                CustomField(hintText: "Name", controller: nameController),
                const SizedBox(height: 15),
                CustomField(hintText: "Email", controller: emailController),
                const SizedBox(height: 15),
                CustomField(hintText: "Password", controller: passwordController, isObscure: true),
                const SizedBox(height: 20),
                
                AuthGradientButton(
                  buttontext: "Sign Up", 
                  onPressed: () async {
                    if(formKey.currentState!.validate()){
                        await ref.read(authViewmodelProvider.notifier).signUpUser(
                        name: nameController.text, 
                        email: emailController.text, 
                        password: passwordController.text
                      );
                    }
                  }
                ),
                const SizedBox(height: 20),
                
                GestureDetector(
                  onTap: () async {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
                  },
                  child: RichText(
                    text: TextSpan(
                      text: 'Already have an account? ',
                       style: Theme.of(context).textTheme.titleMedium,
                      children: const [
                        TextSpan(
                          text: 'Sign In', 
                          style: TextStyle(color: Pallete.gradient2, fontWeight: FontWeight.bold)
                        )
                      ]
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}