import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'onboarding_viewmodel.dart';

/// [OnboardingView] collects user's basic profile information.
///
/// Presents simple inputs for name and phone number with validation handled
/// by the [OnboardingViewModel]. After successful submission, navigation will
/// proceed to the home screen.
class OnboardingView extends StackedView<OnboardingViewModel> {
  const OnboardingView({super.key});

  @override
  Widget builder(BuildContext context, OnboardingViewModel viewModel, Widget? child) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil Singkat')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Lengkapi profil dasar untuk mulai menggunakan PaPa.'),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(labelText: 'Nama lengkap'),
                onChanged: viewModel.setName,
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(labelText: 'Nomor HP'),
                keyboardType: TextInputType.phone,
                onChanged: viewModel.setPhone,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: viewModel.canSubmit ? viewModel.submitProfile : null,
                  child: const Text('Simpan & Lanjut'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  OnboardingViewModel viewModelBuilder(BuildContext context) => OnboardingViewModel();
}