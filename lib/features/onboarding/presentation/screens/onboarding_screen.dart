import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/stylo_button.dart';
import '../providers/onboarding_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();

  static const _slides = [
    _OnboardingSlide(
      title: 'Escaneá tu guardarropa',
      subtitle: 'Tomá una foto y la IA organiza todo por vos.\nTipo, color, estilo — automático.',
      icon: Icons.camera_alt_outlined,
    ),
    _OnboardingSlide(
      title: 'Outfits pensados para vos',
      subtitle: 'Decinos cómo te sentís, a dónde vas, y el clima.\nStylo arma el look perfecto.',
      icon: Icons.auto_awesome_outlined,
    ),
    _OnboardingSlide(
      title: 'Tu estilo evoluciona con vos',
      subtitle: 'Cada elección mejora las recomendaciones.\nStylo aprende tu estilo único.',
      icon: Icons.trending_up_outlined,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToAuth() {
    ref.read(onboardingDataSourceProvider).setOnboardingComplete();
    context.go('/auth');
  }

  @override
  Widget build(BuildContext context) {
    final currentPage = ref.watch(onboardingPageProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: currentPage < 2
                    ? TextButton(
                        onPressed: _goToAuth,
                        child: Text(
                          'Saltar',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      )
                    : const SizedBox(height: 48),
              ),
            ),

            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) => ref.read(onboardingPageProvider.notifier).state = index,
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: AppColors.accentSubtle,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Icon(
                            slide.icon,
                            size: 80,
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxxxl),
                        Text(
                          slide.title,
                          style: Theme.of(context).textTheme.headlineLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          slide.subtitle,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Page indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: currentPage == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: currentPage == i ? AppColors.accent : AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),

            // Bottom button
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: StyloButton(
                label: currentPage == 2 ? 'Empezar' : 'Siguiente',
                onPressed: () {
                  if (currentPage < 2) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    _goToAuth();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingSlide {
  final String title;
  final String subtitle;
  final IconData icon;

  const _OnboardingSlide({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}
