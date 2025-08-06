import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/ui/components/customer_theme_components.dart';
import '../../../../core/utils/app_logger.dart';
import 'utils/professional_remarks_templates.dart';
import 'widgets/service_detail_loading.dart';

/// 测试专业说明文字模板系统的页面
class TestProfessionalRemarksPage extends StatefulWidget {
  const TestProfessionalRemarksPage({Key? key}) : super(key: key);

  @override
  State<TestProfessionalRemarksPage> createState() => _TestProfessionalRemarksPageState();
}

class _TestProfessionalRemarksPageState extends State<TestProfessionalRemarksPage> {
  String _selectedServiceType = ProfessionalRemarksTemplates.CLEANING_SERVICE;
  Map<String, dynamic> _providerData = {
    'completedOrders': 156,
    'rating': 4.8,
    'reviewCount': 89,
    'isVerified': true,
    'businessLicense': 'LIC123456',
  };

  final List<String> _serviceTypes = [
    ProfessionalRemarksTemplates.CLEANING_SERVICE,
    ProfessionalRemarksTemplates.MAINTENANCE_SERVICE,
    ProfessionalRemarksTemplates.BEAUTY_SERVICE,
    ProfessionalRemarksTemplates.EDUCATION_SERVICE,
    ProfessionalRemarksTemplates.TRANSPORTATION_SERVICE,
    ProfessionalRemarksTemplates.FOOD_SERVICE,
    ProfessionalRemarksTemplates.HEALTH_SERVICE,
    ProfessionalRemarksTemplates.TECHNOLOGY_SERVICE,
    ProfessionalRemarksTemplates.GENERAL_SERVICE,
  ];

  final Map<String, String> _serviceTypeNames = {
    ProfessionalRemarksTemplates.CLEANING_SERVICE: '清洁服务',
    ProfessionalRemarksTemplates.MAINTENANCE_SERVICE: '维修服务',
    ProfessionalRemarksTemplates.BEAUTY_SERVICE: '美容服务',
    ProfessionalRemarksTemplates.EDUCATION_SERVICE: '教育服务',
    ProfessionalRemarksTemplates.TRANSPORTATION_SERVICE: '运输服务',
    ProfessionalRemarksTemplates.FOOD_SERVICE: '餐饮服务',
    ProfessionalRemarksTemplates.HEALTH_SERVICE: '健康服务',
    ProfessionalRemarksTemplates.TECHNOLOGY_SERVICE: '技术服务',
    ProfessionalRemarksTemplates.GENERAL_SERVICE: '通用服务',
  };

  @override
  void initState() {
    super.initState();
    AppLogger.info('TestProfessionalRemarksPage initialized', tag: 'TestProfessionalRemarksPage');
    _loadServiceData();
  }

  @override
  void dispose() {
    AppLogger.debug('TestProfessionalRemarksPage disposed', tag: 'TestProfessionalRemarksPage');
    _loadingManager.dispose();
    super.dispose();
  }

  /// 模拟加载服务数据
  Future<void> _loadServiceData() async {
    AppLogger.info('Loading test service data', tag: 'TestProfessionalRemarksPage');
    await _loadingManager.retry(() async {
      // 减少模拟网络请求延迟
      await Future.delayed(const Duration(milliseconds: 800));
      
      // 模拟随机错误
      if (DateTime.now().millisecond % 3 == 0) {
        AppLogger.warning('Simulated network timeout error', tag: 'TestProfessionalRemarksPage');
        throw Exception('网络连接超时');
      }
      
      // 模拟成功加载
      AppLogger.info('Test service data loaded successfully', tag: 'TestProfessionalRemarksPage');
      return;
    });
  }

  /// 模拟网络状态切换
  void _toggleNetworkStatus() {
    setState(() {
      _isOnline = !_isOnline;
      if (_isOnline) {
        _loadingManager.setOnline();
        AppLogger.info('Network status changed to online', tag: 'TestProfessionalRemarksPage');
      } else {
        _loadingManager.setOffline();
        AppLogger.warning('Network status changed to offline', tag: 'TestProfessionalRemarksPage');
      }
    });
  }

  /// 手动切换加载状态
  void _switchLoadingState(LoadingState state) {
    AppLogger.debug('Manually switching loading state to: $state', tag: 'TestProfessionalRemarksPage');
    switch (state) {
      case LoadingState.initial:
        _loadingManager.setLoading();
        break;
      case LoadingState.loading:
        _loadingManager.setSuccess();
        break;
      case LoadingState.success:
        _loadingManager.setError('手动触发的错误');
        break;
      case LoadingState.error:
        _loadingManager.setLoading();
        break;
      case LoadingState.offline:
        _loadingManager.setOnline();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('专业说明文字模板测试'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
            tooltip: '刷新',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 服务类型选择
            _buildServiceTypeSelector(),
            const SizedBox(height: 24),
            
            // 服务特色展示
            _buildServiceFeaturesSection(),
            const SizedBox(height: 16),
            
            // 质量保证展示
            _buildQualityAssuranceSection(),
            const SizedBox(height: 16),
            
            // 专业资质展示
            _buildProfessionalQualificationSection(),
            const SizedBox(height: 16),
            
            // 服务经验展示
            _buildServiceExperienceSection(),
            const SizedBox(height: 16),
            
            // 提供商数据调整
            _buildProviderDataAdjuster(),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceTypeSelector() {
    return CustomerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomerIconContainer(
                icon: Icons.category,
                iconColor: Colors.blue[600],
                backgroundColor: Colors.blue[50],
                useGradient: false,
              ),
              const SizedBox(width: 12),
              const Text(
                '选择服务类型',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _serviceTypes.map((type) {
              final isSelected = type == _selectedServiceType;
              return ChoiceChip(
                label: Text(_serviceTypeNames[type] ?? type),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedServiceType = type;
                    });
                  }
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceFeaturesSection() {
    final features = ProfessionalRemarksTemplates.getServiceFeatures(_selectedServiceType, _providerData);
    
    return CustomerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomerIconContainer(
                icon: Icons.star,
                iconColor: Colors.orange[600],
                backgroundColor: Colors.orange[50],
                useGradient: false,
              ),
              const SizedBox(width: 12),
              Text(
                '${_serviceTypeNames[_selectedServiceType]}特色',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...features.map((feature) => _buildFeatureItem(feature)),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(FeatureItem feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CustomerIconContainer(
            icon: feature.icon,
            iconColor: feature.color,
            backgroundColor: feature.color.withOpacity(0.1),
            useGradient: false,
            size: 40,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  feature.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQualityAssuranceSection() {
    final qualityAssurance = ProfessionalRemarksTemplates.getQualityAssurance(_selectedServiceType, _providerData);
    
    return CustomerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomerIconContainer(
                icon: Icons.verified,
                iconColor: Colors.green[600],
                backgroundColor: Colors.green[50],
                useGradient: false,
              ),
              const SizedBox(width: 12),
              const Text(
                '质量保证',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Text(
              qualityAssurance,
              style: TextStyle(
                fontSize: 14,
                color: Colors.green[700],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalQualificationSection() {
    final qualification = ProfessionalRemarksTemplates.getProfessionalQualification(_selectedServiceType, _providerData);
    
    return CustomerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomerIconContainer(
                icon: Icons.school,
                iconColor: Colors.blue[600],
                backgroundColor: Colors.blue[50],
                useGradient: false,
              ),
              const SizedBox(width: 12),
              const Text(
                '专业资质',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Text(
              qualification,
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue[700],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceExperienceSection() {
    final experience = ProfessionalRemarksTemplates.getServiceExperience(_selectedServiceType, _providerData);
    
    return CustomerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomerIconContainer(
                icon: Icons.work_history,
                iconColor: Colors.purple[600],
                backgroundColor: Colors.purple[50],
                useGradient: false,
              ),
              const SizedBox(width: 12),
              const Text(
                '服务经验',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.purple[200]!),
            ),
            child: Text(
              experience,
              style: TextStyle(
                fontSize: 14,
                color: Colors.purple[700],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderDataAdjuster() {
    return CustomerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomerIconContainer(
                icon: Icons.settings,
                iconColor: Colors.grey[600],
                backgroundColor: Colors.grey[50],
                useGradient: false,
              ),
              const SizedBox(width: 12),
              const Text(
                '调整提供商数据',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 完成订单数
          _buildDataAdjusterItem(
            label: '完成订单数',
            value: _providerData['completedOrders'].toString(),
            min: 0,
            max: 1000,
            divisions: 20,
            onChanged: (value) {
              setState(() {
                _providerData['completedOrders'] = value.toInt();
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          // 评分
          _buildDataAdjusterItem(
            label: '评分',
            value: _providerData['rating'].toStringAsFixed(1),
            min: 1.0,
            max: 5.0,
            divisions: 40,
            onChanged: (value) {
              setState(() {
                _providerData['rating'] = value;
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          // 评价数量
          _buildDataAdjusterItem(
            label: '评价数量',
            value: _providerData['reviewCount'].toString(),
            min: 0,
            max: 500,
            divisions: 25,
            onChanged: (value) {
              setState(() {
                _providerData['reviewCount'] = value.toInt();
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          // 是否已验证
          Row(
            children: [
              const Text('已验证: '),
              Switch(
                value: _providerData['isVerified'],
                onChanged: (value) {
                  setState(() {
                    _providerData['isVerified'] = value;
                  });
                },
              ),
              Text(_providerData['isVerified'] ? '是' : '否'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataAdjusterItem({
    required String label,
    required String value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('$label: '),
            Expanded(
              child: Slider(
                value: _providerData[label == '完成订单数' ? 'completedOrders' : 
                           label == '评分' ? 'rating' : 'reviewCount'].toDouble(),
                min: min,
                max: max,
                divisions: divisions,
                label: value,
                onChanged: onChanged,
              ),
            ),
            Text(value),
          ],
        ),
      ],
    );
  }
}

/// 服务特色项目模型
class FeatureItem {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
} 