import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/community/presentation/community_controller.dart';
import 'package:jinbeanpod_83904710/app/theme/app_colors.dart';
import 'package:jinbeanpod_83904710/core/utils/app_logger.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final CommunityController controller = Get.find<CommunityController>();

  @override
  void initState() {
    super.initState();
    AppLogger.info('CommunityPage initState', tag: 'CommunityPage');
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        AppLogger.info('CommunityPage tab changed to index: ${_tabController.index}', tag: 'CommunityPage');
        switch (_tabController.index) {
          case 0:
            controller.selectPostType(CommunityPostType.event);
            break;
          case 1:
            controller.selectPostType(CommunityPostType.subsidy);
            break;
          case 2:
            controller.selectPostType(CommunityPostType.announcement);
            break;
          default:
            controller.selectPostType(null);
            break;
        }
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppLogger.info('CommunityPage post frame callback, selectedPostType: ${controller.selectedPostType.value}', tag: 'CommunityPage');
      if (controller.selectedPostType.value == CommunityPostType.event) {
        _tabController.index = 0;
      } else if (controller.selectedPostType.value == CommunityPostType.subsidy) {
        _tabController.index = 1;
      } else if (controller.selectedPostType.value == CommunityPostType.announcement) {
        _tabController.index = 2;
      } else {
        _tabController.index = 0;
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppLogger.debug('CommunityPage build called', tag: 'CommunityPage');
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onPrimary),
          onPressed: () {
            Get.back();
          },
        ),
        title: Text(
          'Community Updates',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        children: [
          // Tab Bar for Events, Subsidies, Announcements
          TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(context).textTheme.bodySmall?.color,
            indicatorColor: Theme.of(context).colorScheme.primary,
            tabs: const [
              Tab(text: 'Events'),
              Tab(text: 'Subsidies'),
              Tab(text: 'Announcements'),
            ],
          ),
          const SizedBox(height: 10),
          // Community Posts List
          Expanded(
            child: Obx(() => ListView.builder(
              itemCount: controller.filteredPosts.length,
              itemBuilder: (context, index) {
                final post = controller.filteredPosts[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  clipBehavior: Clip.antiAlias,
                  color: Theme.of(context).colorScheme.surface,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(
                        post.imageUrl,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(post.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleMedium?.color)),
                            const SizedBox(height: 8),
                            Text(post.description, style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium?.color)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            )),
          ),
        ],
      ),
    );
  }
} 