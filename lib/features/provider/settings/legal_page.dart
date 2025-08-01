import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LegalPage extends StatefulWidget {
  const LegalPage({super.key});

  @override
  State<LegalPage> createState() => _LegalPageState();
}

class _LegalPageState extends State<LegalPage> {
  final RxString selectedTab = 'compliance'.obs;
  final RxBool isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    _loadComplianceData();
  }

  Future<void> _loadComplianceData() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1));
    isLoading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text('安全合规'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadComplianceData(),
          ),
          IconButton(
            icon: const Icon(Icons.help),
            onPressed: () => _showHelpDialog(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadComplianceData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // 合规概览
              _buildComplianceOverview(),
              
              // 标签页选择器
              _buildTabSelector(),
              
              // 标签页内容
              _buildTabContent(),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComplianceOverview() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '合规概览',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildOverviewCard('合规状态', '良好', Colors.green, Icons.check_circle),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildOverviewCard('待处理', '2', Colors.orange, Icons.pending),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildOverviewCard('认证状态', '已验证', Colors.blue, Icons.verified),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildOverviewCard('风险等级', '低', Colors.green, Icons.security),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.green[600], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '您的账户符合平台安全标准，可以正常提供服务',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Obx(() => Row(
            children: [
              'compliance',
              'security',
              'documents',
              'policies',
            ].map((tab) {
              final isSelected = selectedTab.value == tab;
              return Expanded(
                child: GestureDetector(
                  onTap: () => selectedTab.value = tab,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _getTabText(tab),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[700],
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }).toList(),
          )),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    return Obx(() {
      if (isLoading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(),
          ),
        );
      }

      switch (selectedTab.value) {
        case 'compliance':
          return _buildComplianceTab();
        case 'security':
          return _buildSecurityTab();
        case 'documents':
          return _buildDocumentsTab();
        case 'policies':
          return _buildPoliciesTab();
        default:
          return _buildComplianceTab();
      }
    });
  }

  Widget _buildComplianceTab() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '合规检查',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildComplianceItem(
            '身份验证',
            '已完成',
            '您的身份信息已验证',
            Colors.green,
            Icons.verified,
          ),
          _buildComplianceItem(
            '背景调查',
            '已完成',
            '背景调查已通过',
            Colors.green,
            Icons.security,
          ),
          _buildComplianceItem(
            '保险证明',
            '待更新',
            '保险证明即将到期，请及时更新',
            Colors.orange,
            Icons.security,
          ),
          _buildComplianceItem(
            '营业执照',
            '已完成',
            '营业执照已验证',
            Colors.green,
            Icons.business,
          ),
          _buildComplianceItem(
            '服务资质',
            '待审核',
            '新服务资质正在审核中',
            Colors.orange,
            Icons.work,
          ),
        ],
      ),
    );
  }

  Widget _buildComplianceItem(String title, String status, String description, Color color, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 10,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityTab() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '安全设置',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildSecurityItem(
            '双重认证',
            '已启用',
            '使用手机验证码保护账户安全',
            Colors.green,
            Icons.phone_android,
            onTap: () => _toggleTwoFactor(),
          ),
          _buildSecurityItem(
            '登录通知',
            '已启用',
            '新设备登录时会收到通知',
            Colors.green,
            Icons.notifications,
            onTap: () => _toggleLoginNotification(),
          ),
          _buildSecurityItem(
            '密码强度',
            '强',
            '建议定期更换密码',
            Colors.green,
            Icons.lock,
            onTap: () => _changePassword(),
          ),
          _buildSecurityItem(
            '设备管理',
            '3台设备',
            '管理已登录的设备',
            Colors.blue,
            Icons.devices,
            onTap: () => _manageDevices(),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '安全建议',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSecurityTip('定期更换密码', Icons.lock_clock),
                  _buildSecurityTip('不要在公共设备上登录', Icons.public),
                  _buildSecurityTip('及时更新应用版本', Icons.system_update),
                  _buildSecurityTip('谨慎处理可疑链接', Icons.link),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityItem(String title, String status, String description, Color color, IconData icon, {VoidCallback? onTap}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 10,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityTip(String tip, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.blue[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsTab() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '合规文档',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildDocumentItem(
            '身份证件',
            '已上传',
            '2024-01-15',
            Colors.green,
            Icons.credit_card,
          ),
          _buildDocumentItem(
            '营业执照',
            '已上传',
            '2024-01-10',
            Colors.green,
            Icons.business,
          ),
          _buildDocumentItem(
            '保险证明',
            '即将到期',
            '2024-02-28',
            Colors.orange,
            Icons.security,
          ),
          _buildDocumentItem(
            '服务资质证书',
            '审核中',
            '2024-01-20',
            Colors.blue,
            Icons.work,
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '文档要求',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDocumentRequirement('身份证件', '清晰可见，信息完整'),
                  _buildDocumentRequirement('营业执照', '在有效期内，经营范围包含服务内容'),
                  _buildDocumentRequirement('保险证明', '包含责任险，保额不低于要求'),
                  _buildDocumentRequirement('服务资质', '相关行业资质证书或培训证明'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentItem(String title, String status, String date, Color color, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '上传时间: $date',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 10,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentRequirement(String document, String requirement) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6),
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  requirement,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPoliciesTab() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '政策法规',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildPolicyItem(
            '服务协议',
            '最新版本',
            '了解平台服务条款和条件',
            Icons.description,
            onTap: () => _viewPolicy('service_agreement'),
          ),
          _buildPolicyItem(
            '隐私政策',
            '最新版本',
            '了解我们如何保护您的隐私',
            Icons.privacy_tip,
            onTap: () => _viewPolicy('privacy_policy'),
          ),
          _buildPolicyItem(
            '社区准则',
            '最新版本',
            '平台行为规范和准则',
            Icons.people,
            onTap: () => _viewPolicy('community_guidelines'),
          ),
          _buildPolicyItem(
            '安全政策',
            '最新版本',
            '平台安全措施和标准',
            Icons.security,
            onTap: () => _viewPolicy('security_policy'),
          ),
          _buildPolicyItem(
            '投诉处理',
            '最新版本',
            '投诉和纠纷处理流程',
            Icons.gavel,
            onTap: () => _viewPolicy('complaint_handling'),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '重要提醒',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildPolicyReminder('遵守当地法律法规', Icons.gavel),
                  _buildPolicyReminder('保护客户隐私信息', Icons.privacy_tip),
                  _buildPolicyReminder('提供真实服务信息', Icons.info),
                  _buildPolicyReminder('及时处理客户投诉', Icons.support_agent),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyItem(String title, String version, String description, IconData icon, {VoidCallback? onTap}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.blue, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
        child: Text(
                  version,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPolicyReminder(String reminder, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.orange[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              reminder,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  String _getTabText(String tab) {
    switch (tab) {
      case 'compliance':
        return '合规检查';
      case 'security':
        return '安全设置';
      case 'documents':
        return '合规文档';
      case 'policies':
        return '政策法规';
      default:
        return tab;
    }
  }

  void _showHelpDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('帮助中心'),
        content: const Text('如果您在合规方面遇到问题，请联系客服获取帮助。'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('关闭'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.snackbar('联系客服', '正在为您转接客服...');
            },
            child: const Text('联系客服'),
          ),
        ],
      ),
    );
  }

  void _toggleTwoFactor() {
    Get.snackbar('双重认证', '双重认证设置功能正在开发中...');
  }

  void _toggleLoginNotification() {
    Get.snackbar('登录通知', '登录通知设置功能正在开发中...');
  }

  void _changePassword() {
    Get.snackbar('修改密码', '密码修改功能正在开发中...');
  }

  void _manageDevices() {
    Get.snackbar('设备管理', '设备管理功能正在开发中...');
  }

  void _viewPolicy(String policy) {
    Get.snackbar('查看政策', '政策查看功能正在开发中...');
  }
} 