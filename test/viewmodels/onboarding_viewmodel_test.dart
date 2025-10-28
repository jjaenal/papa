import 'package:flutter_test/flutter_test.dart';
import 'package:papa/ui/views/onboarding/onboarding_viewmodel.dart';
import 'package:stacked_services/stacked_services.dart';

void main() {
  group('OnboardingViewModel validation', () {
    test('validateName returns true for names length >= 2', () {
      expect(OnboardingViewModel.validateName('Al'), isTrue);
      expect(OnboardingViewModel.validateName(' A '), isFalse);
    });

    test('validatePhone allows 10-15 digits', () {
      expect(OnboardingViewModel.validatePhone('0812345678'), isTrue);
      expect(OnboardingViewModel.validatePhone('+62 812-3456-7890'), isTrue);
      expect(OnboardingViewModel.validatePhone('12345'), isFalse);
      expect(OnboardingViewModel.validatePhone('0' * 16), isFalse);
    });

    test('canSubmit true only when both valid', () {
      final vm = OnboardingViewModel(navigationService: NavigationService());
      vm.setName('Budi');
      vm.setPhone('08123456789');
      expect(vm.canSubmit, isTrue);
    });
  });
}
