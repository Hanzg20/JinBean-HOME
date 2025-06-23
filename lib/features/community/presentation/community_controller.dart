import 'package:get/get.dart';

enum CommunityPostType {
  event,
  subsidy,
  announcement,
}

class CommunityPost {
  final String title;
  final String description;
  final String imageUrl;
  final CommunityPostType type;

  CommunityPost({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.type,
  });
}

class CommunityController extends GetxController {
  // Add your reactive states and methods here
  RxString welcomeMessage = 'Welcome to the Community Page!'.obs;

  final RxList<CommunityPost> allPosts = <CommunityPost>[
    CommunityPost(
      title: 'Community Picnic',
      description: 'Join us for a fun-filled picnic at Central Park.',
      imageUrl: 'https://picsum.photos/200/300?random=4',
      type: CommunityPostType.event,
    ),
    CommunityPost(
      title: 'Housing Subsidy Program',
      description: 'Apply for the new housing subsidy program to help with your rent or mortgage.',
      imageUrl: 'https://picsum.photos/200/300?random=5',
      type: CommunityPostType.subsidy,
    ),
    CommunityPost(
      title: 'Road Closure Notice',
      description: 'Main Street will be closed for construction from July 1st to July 15th.',
      imageUrl: 'https://picsum.photos/200/300?random=6',
      type: CommunityPostType.announcement,
    ),
  ].obs;

  Rx<CommunityPostType?> selectedPostType = Rx<CommunityPostType?>(null); // Null means 'All'

  // Filtered list of posts based on selectedPostType
  RxList<CommunityPost> get filteredPosts => (
    selectedPostType.value == null
        ? allPosts
        : allPosts.where((post) => post.type == selectedPostType.value).toList()
  ).obs; // Using .obs to make it reactive

  void selectPostType(CommunityPostType? type) {
    selectedPostType.value = type;
  }

  @override
  void onInit() {
    super.onInit();
    print('CommunityController initialized');
  }

  @override
  void onClose() {
    print('CommunityController disposed');
    super.onClose();
  }
} 