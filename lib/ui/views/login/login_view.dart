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
        child: Stack(
          children: [
            Padding(
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
                      const SizedBox(height: 20),

                      // Error banner
                      if (viewModel.lastError != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.error,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Theme.of(context).colorScheme.error,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  viewModel.lastError!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onErrorContainer,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

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
                        enabled: !viewModel.isLoading,
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
                          enabled: !viewModel.isLoading,
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
                                  viewModel.otpSent
                                      ? 'Verifikasi'
                                      : 'Kirim OTP',
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
                          onPressed: viewModel.isLoading
                              ? null
                              : viewModel.loginWithGoogle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (viewModel.isLoading)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.15),
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(),
                  ),
                ),
              ),
          ],
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
