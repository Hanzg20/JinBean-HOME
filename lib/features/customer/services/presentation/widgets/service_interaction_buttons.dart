import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/utils/app_logger.dart';

/// 服务交互按钮组件
class ServiceInteractionButtons extends StatefulWidget {
  final String serviceId;
  final String serviceTitle;
  final String serviceDescription;
  final bool isFavorite;
  final VoidCallback? onFavoriteChanged;
  final VoidCallback? onBookService;
  final VoidCallback? onContactProvider;

  const ServiceInteractionButtons({
    super.key,
    required this.serviceId,
    required this.serviceTitle,
    required this.serviceDescription,
    this.isFavorite = false,
    this.onFavoriteChanged,
    this.onBookService,
    this.onContactProvider,
  });

  @override
  State<ServiceInteractionButtons> createState() =>
      _ServiceInteractionButtonsState();
}

class _ServiceInteractionButtonsState extends State<ServiceInteractionButtons>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 主要操作按钮
          Row(
            children: [
              Expanded(
                child: _buildPrimaryButton(
                  icon: Icons.favorite,
                  label: _isFavorite ? 'Favorited' : 'Add to Favorites',
                  color: _isFavorite ? Colors.red : Colors.grey[600],
                  onPressed: _toggleFavorite,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPrimaryButton(
                  icon: Icons.share,
                  label: 'Share',
                  color: Colors.blue,
                  onPressed: _shareService,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 次要操作按钮
          Row(
            children: [
              Expanded(
                child: _buildSecondaryButton(
                  icon: Icons.calendar_today,
                  label: 'Book Now',
                  color: Colors.green,
                  onPressed: _bookService,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSecondaryButton(
                  icon: Icons.message,
                  label: 'Contact',
                  color: Colors.orange,
                  onPressed: _contactProvider,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton({
    required IconData icon,
    required String label,
    required Color? color,
    required VoidCallback onPressed,
  }) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: ElevatedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, color: Colors.white, size: 20),
            label: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 2,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSecondaryButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: color, size: 20),
      label: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });

    // 播放动画
    if (_isFavorite) {
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
    }

    // 调用回调
    if (widget.onFavoriteChanged != null) {
      widget.onFavoriteChanged!();
    }

    // 显示提示
    Get.snackbar(
      _isFavorite ? 'Added to Favorites' : 'Removed from Favorites',
      _isFavorite
          ? '${widget.serviceTitle} has been added to your favorites'
          : '${widget.serviceTitle} has been removed from your favorites',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: _isFavorite ? Colors.green : Colors.grey[600],
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );

    AppLogger.info('Favorite toggled for service: ${widget.serviceId}');
  }

  void _shareService() {
    final shareText = '''
Check out this amazing service!

${widget.serviceTitle}

${widget.serviceDescription}

Download JinBean app to book this service now!
''';

    Share.share(
      shareText,
      subject: 'Amazing Service: ${widget.serviceTitle}',
    );

    AppLogger.info('Service shared: ${widget.serviceId}');
  }

  void _bookService() {
    if (widget.onBookService != null) {
      widget.onBookService!();
    } else {
      // 默认预约流程
      _showBookingDialog();
    }

    AppLogger.info('Book service requested: ${widget.serviceId}');
  }

  void _contactProvider() {
    if (widget.onContactProvider != null) {
      widget.onContactProvider!();
    } else {
      // 默认联系流程
      _showContactDialog();
    }

    AppLogger.info('Contact provider requested: ${widget.serviceId}');
  }

  void _showBookingDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Book Service'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Would you like to book "${widget.serviceTitle}"?'),
            const SizedBox(height: 16),
            const Text(
              'This will redirect you to the booking page where you can select your preferred time and date.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Booking',
                'Redirecting to booking page...',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showContactDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Contact Provider'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                'How would you like to contact the provider for "${widget.serviceTitle}"?'),
            const SizedBox(height: 16),
            const Text(
              'Choose your preferred contact method.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Contact',
                'Opening phone app...',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            icon: const Icon(Icons.phone),
            label: const Text('Call'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Contact',
                'Opening email app...',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            icon: const Icon(Icons.email),
            label: const Text('Email'),
          ),
        ],
      ),
    );
  }
}

/// 快速操作按钮 - 用于紧凑布局
class QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onPressed;
  final bool isActive;

  const QuickActionButton({
    super.key,
    required this.icon,
    required this.label,
    this.color,
    required this.onPressed,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: isActive
                ? (color ?? Theme.of(context).colorScheme.primary)
                    .withValues(alpha: 0.1)
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(
              icon,
              color: isActive
                  ? (color ?? Theme.of(context).colorScheme.primary)
                  : Colors.grey[600],
              size: 24,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive
                ? (color ?? Theme.of(context).colorScheme.primary)
                : Colors.grey[600],
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// 自定义浮动操作按钮 - 用于主要操作
class CustomFloatingActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onPressed;
  final bool isExtended;

  const CustomFloatingActionButton({
    super.key,
    required this.icon,
    required this.label,
    this.color,
    required this.onPressed,
    this.isExtended = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isExtended) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        backgroundColor: color ?? Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      );
    }

    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: color ?? Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
      child: Icon(icon),
    );
  }
}
