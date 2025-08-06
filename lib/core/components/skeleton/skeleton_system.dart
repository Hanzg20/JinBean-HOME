import 'package:flutter/material.dart';

/// 平台级骨架屏系统
abstract class PlatformSkeleton {
  /// 骨架屏配置
  static const SkeletonConfig defaultConfig = SkeletonConfig(
    animationDuration: Duration(milliseconds: 1500),
    shimmerColor: Color(0xFFE0E0E0),
    baseColor: Color(0xFFF5F5F5),
    borderRadius: 8.0,
  );

  /// 创建骨架屏组件
  static Widget create({
    required SkeletonType type,
    SkeletonConfig? config,
    Map<String, dynamic>? customData,
  }) {
    final skeletonConfig = config ?? defaultConfig;
    
    switch (type) {
      case SkeletonType.list:
        return SkeletonListWidget(config: skeletonConfig);
      case SkeletonType.card:
        return SkeletonCardWidget(config: skeletonConfig);
      case SkeletonType.detail:
        return SkeletonDetailWidget(config: skeletonConfig);
      case SkeletonType.custom:
        return SkeletonCustomWidget(
          config: skeletonConfig,
          customData: customData,
        );
    }
  }
}

/// 骨架屏类型枚举
enum SkeletonType {
  list,    // 列表骨架屏
  card,    // 卡片骨架屏
  detail,  // 详情页骨架屏
  custom,  // 自定义骨架屏
}

/// 骨架屏配置
class SkeletonConfig {
  final Duration animationDuration;
  final Color shimmerColor;
  final Color baseColor;
  final double borderRadius;
  
  const SkeletonConfig({
    required this.animationDuration,
    required this.shimmerColor,
    required this.baseColor,
    required this.borderRadius,
  });
}

/// 基础骨架屏组件
class ShimmerSkeleton extends StatefulWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;

  const ShimmerSkeleton({
    Key? key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1000),
  }) : super(key: key);

  @override
  State<ShimmerSkeleton> createState() => _ShimmerSkeletonState();
}

class _ShimmerSkeletonState extends State<ShimmerSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = widget.baseColor ?? theme.colorScheme.surfaceVariant;
    final highlightColor = widget.highlightColor ?? theme.colorScheme.surface;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value, 0),
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// 列表骨架屏组件
class SkeletonListWidget extends StatefulWidget {
  final SkeletonConfig config;
  
  const SkeletonListWidget({
    Key? key,
    required this.config,
  }) : super(key: key);

  @override
  State<SkeletonListWidget> createState() => _SkeletonListWidgetState();
}

class _SkeletonListWidgetState extends State<SkeletonListWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.config.animationDuration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.config.baseColor,
                borderRadius: BorderRadius.circular(widget.config.borderRadius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题骨架
                  Container(
                    height: 20,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: _getShimmerColor(),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 内容骨架
                  Container(
                    height: 16,
                    width: MediaQuery.of(context).size.width * 0.7,
                    decoration: BoxDecoration(
                      color: _getShimmerColor(),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Color _getShimmerColor() {
    return Color.lerp(
      widget.config.baseColor,
      widget.config.shimmerColor,
      _animation.value,
    )!;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

/// 卡片骨架屏组件
class SkeletonCardWidget extends StatelessWidget {
  final SkeletonConfig config;
  
  const SkeletonCardWidget({
    Key? key,
    required this.config,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: config.baseColor,
        borderRadius: BorderRadius.circular(config.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerSkeleton(
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ShimmerSkeleton(
            child: Container(
              height: 20,
              width: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 8),
          ShimmerSkeleton(
            child: Container(
              height: 16,
              width: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 详情页骨架屏组件
class SkeletonDetailWidget extends StatelessWidget {
  final SkeletonConfig config;
  
  const SkeletonDetailWidget({
    Key? key,
    required this.config,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero区域骨架屏
          _buildHeroSkeleton(),
          const SizedBox(height: 16),
          
          // 操作按钮骨架屏
          _buildActionButtonsSkeleton(),
          const SizedBox(height: 24),
          
          // Tab栏骨架屏
          _buildTabBarSkeleton(),
          const SizedBox(height: 16),
          
          // 内容区域骨架屏
          _buildContentSkeleton(),
        ],
      ),
    );
  }

  Widget _buildHeroSkeleton() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: config.baseColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // 图片骨架屏
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: config.baseColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
          ),
          // 信息骨架屏
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerSkeleton(
                    child: Container(
                      height: 24,
                      width: 200,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ShimmerSkeleton(
                    child: Container(
                      height: 16,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtonsSkeleton() {
    return Row(
      children: [
        Expanded(
          child: ShimmerSkeleton(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: config.baseColor,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ShimmerSkeleton(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: config.baseColor,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabBarSkeleton() {
    return Row(
      children: List.generate(3, (index) => Expanded(
        child: ShimmerSkeleton(
          child: Container(
            height: 40,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: config.baseColor,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      )),
    );
  }

  Widget _buildContentSkeleton() {
    return Column(
      children: List.generate(5, (index) => Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            ShimmerSkeleton(
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: config.baseColor,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerSkeleton(
                    child: Container(
                      height: 16,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: config.baseColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ShimmerSkeleton(
                    child: Container(
                      height: 12,
                      width: MediaQuery.of(context).size.width * 0.6,
                      decoration: BoxDecoration(
                        color: config.baseColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }
}

/// 自定义骨架屏组件
class SkeletonCustomWidget extends StatelessWidget {
  final SkeletonConfig config;
  final Map<String, dynamic>? customData;
  
  const SkeletonCustomWidget({
    Key? key,
    required this.config,
    this.customData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 根据customData构建自定义骨架屏
    final itemCount = customData?['items'] ?? 5;
    
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: config.baseColor,
            borderRadius: BorderRadius.circular(config.borderRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerSkeleton(
                child: Container(
                  height: 20,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ShimmerSkeleton(
                child: Container(
                  height: 16,
                  width: MediaQuery.of(context).size.width * 0.7,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
} 