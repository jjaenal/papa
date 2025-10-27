import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'login_viewmodel.dart';

class LoginView extends StackedView<LoginViewModel> {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    LoginViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    'Login',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Masukkan nomor telepon untuk melanjutkan',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  
                  // Phone input field
                  TextField(
                    key: const Key('phone_input'),
                    decoration: InputDecoration(
                      labelText: 'Nomor Telepon',
                      hintText: '+628123456789',
                      prefixIcon: const Icon(Icons.phone),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      errorText: viewModel.phoneError,
                    ),
                    keyboardType: TextInputType.phone,
                    onChanged: viewModel.setPhone,
                  ),
                  
                  // OTP field (shown only when OTP sent)
                  if (viewModel.otpSent) ...[
                    const SizedBox(height: 20),
                    TextField(
                      key: const Key('otp_input'),
                      decoration: InputDecoration(
                        labelText: 'Kode OTP',
                        hintText: '123456',
                        prefixIcon: const Icon(Icons.lock),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        errorText: viewModel.otpError,
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: viewModel.setOtp,
                    ),
                  ],
                  
                  const SizedBox(height: 30),
                  
                  // Login button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      key: const Key('send_otp_button'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: viewModel.isLoading
                          ? null
                          : viewModel.otpSent
                              ? viewModel.verifyOtp
                              : viewModel.sendOtp,
                      child: viewModel.isLoading
                          ? const CircularProgressIndicator()
                          : Text(
                              viewModel.otpSent ? 'Verifikasi' : 'Kirim OTP',
                              style: const TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Google login button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      key: const Key('google_signin_button'),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.login),
                      label: const Text('Login dengan Google'),
                      onPressed: viewModel.isLoading ? null : viewModel.loginWithGoogle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  LoginViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      LoginViewModel();
}