import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/customer/splash/presentation/splash_controller.dart';
import 'package:jinbeanpod_83904710/app/theme/app_colors.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SplashController>();
    final size = MediaQuery.of(context).size;
    final titleFontSize = size.width * 0.08; // 8% of screen width
    final descriptionFontSize = size.width * 0.045; // 4.5% of screen width
    
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: [
          PageView.builder(
            controller: controller.pageController,
            itemCount: controller.onboardingPages.length,
            onPageChanged: controller.onPageChanged,
            itemBuilder: (context, index) {
              final page = controller.onboardingPages[index];
              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    page.imagePath,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                          Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                          Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: size.width * 0.06, // 6% of screen width
                    bottom: size.height * 0.15, // 15% of screen height
                    width: size.width * 0.8, // 80% of screen width
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          page.title,
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                            shadows: [
                              Shadow(
                                offset: const Offset(1, 1),
                                blurRadius: 3.0,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: size.height * 0.02), // 2% of screen height
                        Text(
                          page.description,
                          style: TextStyle(
                            fontSize: descriptionFontSize,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.9),
                            shadows: [
                              Shadow(
                                offset: const Offset(1, 1),
                                blurRadius: 3.0,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          Positioned(
            bottom: size.height * 0.05, // 5% of screen height
            left: size.width * 0.06, // 6% of screen width
            right: size.width * 0.06, // 6% of screen width
            child: Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => controller.navigateToLogin(),
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Theme.of(context).colorScheme.onSurface,
                    size: size.width * 0.06, // 6% of screen width
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(controller.onboardingPages.length, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      height: 8.0,
                      width: controller.currentPageIndex.value == index ? 24.0 : 8.0,
                      decoration: BoxDecoration(
                        color: controller.currentPageIndex.value == index
                            ? Theme.of(context).colorScheme.onSurface
                            : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    );
                  }),
                ),
                IconButton(
                  onPressed: () {
                    if (controller.currentPageIndex.value == controller.onboardingPages.length - 1) {
                      controller.navigateToLogin();
                    } else {
                      controller.goToNextPage();
                    }
                  },
                  icon: Icon(
                    controller.currentPageIndex.value == controller.onboardingPages.length - 1
                        ? Icons.check_circle
                        : Icons.arrow_forward_ios,
                    color: Theme.of(context).colorScheme.onSurface,
                    size: size.width * 0.06, // 6% of screen width
                  ),
                ),
              ],
            )),
          ),
        ],
      ),
    );
  }
} 