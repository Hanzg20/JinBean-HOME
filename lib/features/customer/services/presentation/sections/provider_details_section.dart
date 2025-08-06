import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../domain/entities/provider_profile.dart';
import '../service_detail_controller.dart';
import '../utils/professional_remarks_templates.dart';

/// 服务提供商详情组件
class ProviderDetailsSection extends StatelessWidget {
  final ServiceDetailController controller;

  const ProviderDetailsSection({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.business, color: Colors.blue[600]),
                const SizedBox(width: 8),
                const Text(
                  '服务提供商',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _showProviderProfile(),
                  child: const Text('查看详情'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 提供商基本信息
            Obx(() {
              final provider = controller.providerProfile.value;
              if (provider == null) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(Icons.business_outlined, size: 48, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          '暂无提供商信息',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: [
                  Row(
                    children: [
                      // 提供商头像
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: provider.avatar != null 
                          ? NetworkImage(provider.avatar!) 
                          : null,
                        child: provider.avatar == null 
                          ? Text(provider.name.substring(0, 1).toUpperCase())
                          : null,
                      ),
                      const SizedBox(width: 16),
                      
                      // 提供商信息
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  provider.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (provider.isVerified)
                                  Icon(Icons.verified, color: Colors.blue, size: 20),
                              ],
                            ),
                            const SizedBox(height: 4),
                            if (provider.description != null)
                              Text(
                                provider.description!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                ...List.generate(5, (index) => Icon(
                                  index < (provider.rating ?? 0) ? Icons.star : Icons.star_border,
                                  color: Colors.amber,
                                  size: 16,
                                )),
                                const SizedBox(width: 4),
                                Text(
                                  '${provider.rating?.toStringAsFixed(1) ?? 'N/A'} (${provider.reviewCount ?? 0})',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  
                  // 提供商统计信息
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          '完成订单',
                          '${provider.completedOrders ?? 0}',
                          Icons.check_circle_outline,
                          Colors.green,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          '服务评分',
                          '${provider.rating?.toStringAsFixed(1) ?? 'N/A'}',
                          Icons.star_outline,
                          Colors.amber,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          '认证状态',
                          provider.isVerified ? '已认证' : '未认证',
                          provider.isVerified ? Icons.verified : Icons.warning,
                          provider.isVerified ? Colors.blue : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 联系信息
                  if (provider.phone != null || provider.email != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '联系方式',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (provider.phone != null)
                          ListTile(
                            leading: const Icon(Icons.phone, color: Colors.green),
                            title: Text(provider.phone!),
                            trailing: IconButton(
                              icon: const Icon(Icons.call),
                              onPressed: () => _makePhoneCall(provider.phone!),
                            ),
                            contentPadding: EdgeInsets.zero,
                          ),
                        if (provider.email != null)
                          ListTile(
                            leading: const Icon(Icons.email, color: Colors.blue),
                            title: Text(provider.email!),
                            trailing: IconButton(
                              icon: const Icon(Icons.email_outlined),
                              onPressed: () => _sendEmail(provider.email!),
                            ),
                            contentPadding: EdgeInsets.zero,
                          ),
                      ],
                    ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  void _showProviderProfile() {
    Get.dialog(
      AlertDialog(
        title: const Text('提供商详情'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Obx(() {
            final provider = controller.providerProfile.value;
            if (provider == null) {
              return const Center(
                child: Text('暂无提供商信息'),
              );
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: provider.avatar != null 
                        ? NetworkImage(provider.avatar!) 
                        : null,
                      child: provider.avatar == null 
                        ? Text(
                            provider.name.substring(0, 1).toUpperCase(),
                            style: const TextStyle(fontSize: 32),
                          )
                        : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      provider.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (provider.isVerified)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified, color: Colors.blue, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              '已认证提供商',
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  if (provider.description != null) ...[
                    const Text(
                      '简介',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(provider.description!),
                    const SizedBox(height: 16),
                  ],
                  
                  // 专业资质说明
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.verified_user, color: Colors.blue[600], size: 20),
                            const SizedBox(width: 8),
                            Text(
                              '专业资质',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getProfessionalQualification(),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue[700],
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // 服务经验说明
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.work_history, color: Colors.green[600], size: 20),
                            const SizedBox(width: 8),
                            Text(
                              '服务经验',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getServiceExperience(),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.green[700],
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // 服务特色说明
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.orange[600], size: 20),
                            const SizedBox(width: 8),
                            Text(
                              '服务特色',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.orange[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getServiceHighlights(),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.orange[700],
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  if (provider.address != null) ...[
                    const Text(
                      '地址',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(provider.address!),
                    const SizedBox(height: 16),
                  ],
                  const Text(
                    '统计信息',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          '完成订单',
                          '${provider.completedOrders ?? 0}',
                          Icons.check_circle_outline,
                          Colors.green,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          '服务评分',
                          '${provider.rating?.toStringAsFixed(1) ?? 'N/A'}',
                          Icons.star_outline,
                          Colors.amber,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          '评价数量',
                          '${provider.reviewCount ?? 0}',
                          Icons.rate_review_outlined,
                          Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _makePhoneCall(String phone) {
    Get.snackbar(
      '拨打电话',
      '正在拨打 $phone',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _sendEmail(String email) {
    Get.snackbar(
      '发送邮件',
      '正在打开邮件应用发送到 $email',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  String _getProfessionalQualification() {
    final serviceType = _getServiceType();
    final providerData = _getProviderData();
    return ProfessionalRemarksTemplates.getProfessionalQualification(serviceType, providerData);
  }

  String _getServiceExperience() {
    final serviceType = _getServiceType();
    final providerData = _getProviderData();
    return ProfessionalRemarksTemplates.getServiceExperience(serviceType, providerData);
  }

  String _getServiceHighlights() {
    final serviceType = _getServiceType();
    final providerData = _getProviderData();
    return ProfessionalRemarksTemplates.getServiceHighlights(serviceType, providerData);
  }

  String _getServiceType() {
    // 根据服务分类或标签判断服务类型
    // 暂时返回清洁服务作为默认值
    return ProfessionalRemarksTemplates.CLEANING_SERVICE;
  }

  Map<String, dynamic>? _getProviderData() {
    final provider = controller.providerProfile.value;
    if (provider == null) return null;
    
    return {
      'completedOrders': provider.completedOrders,
      'rating': provider.rating,
      'reviewCount': provider.reviewCount,
      'isVerified': provider.isVerified,
      'businessLicense': provider.businessLicense,
    };
  }
} 