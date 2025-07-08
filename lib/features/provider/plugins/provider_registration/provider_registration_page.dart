import 'package:flutter/material.dart';
import 'provider_registration_controller.dart';
import 'provider_registration_service.dart';
import 'address_service.dart';
import '../../../../shared/widgets/smart_address_input.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart'; // Added for Get.offAllNamed

class ProviderRegistrationPage extends StatefulWidget {
  const ProviderRegistrationPage({super.key});

  @override
  State<ProviderRegistrationPage> createState() =>
      _ProviderRegistrationPageState();
}

class _ProviderRegistrationPageState extends State<ProviderRegistrationPage> {
  final controller = ProviderRegistrationController();
  final service = ProviderRegistrationService();
  final addressService = AddressService();
  bool submitting = false;
  String? submitResult;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('服务商注册')),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTypeSelector(),
                const SizedBox(height: 16),
                ..._buildDynamicFormSections(),
                if (submitResult != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(submitResult!,
                        style: TextStyle(
                            color: submitResult == '注册成功！'
                                ? Colors.green
                                : Colors.red)),
                  ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isFormValid() && !submitting ? _onSubmit : null,
                    child: submitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('提交注册'),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: ProviderType.values
              .map((type) => Expanded(
                    child: RadioListTile<ProviderType>(
                      title: Text(type == ProviderType.individual
                          ? '个人'
                          : type == ProviderType.team
                              ? '团队'
                              : '企业'),
                      value: type,
                      groupValue: controller.providerType,
                      onChanged: (val) {
                        setState(() => controller.setProviderType(val!));
                      },
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  List<Widget> _buildDynamicFormSections() {
    final type = controller.providerType;
    if (type == null) return [];
    final List<Widget> sections = [];
    // 基本信息
    sections.add(_buildSection('基本信息', _buildBasicInfoFields(type)));
    // 地址
    sections.add(_buildSection('服务地址', _buildAddressFields()));
    // 服务信息
    sections.add(_buildSection('服务信息', _buildServiceInfoFields(type)));
    // 资质认证
    if (type != ProviderType.individual) {
      sections.add(_buildSection('资质/证照上传', _buildCertificationFields(type)));
    }
    // 合规信息
    if (type == ProviderType.corporate) {
      sections.add(_buildSection('合规信息', _buildComplianceFields()));
    }
    return sections;
  }

  Widget _buildSection(String title, Widget child) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoFields(ProviderType type) {
    return Column(
      children: [
        TextField(
          decoration: const InputDecoration(labelText: '服务商名称*'),
          onChanged: (v) => setState(() => controller.displayName = v),
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: const InputDecoration(labelText: '手机号*'),
          keyboardType: TextInputType.phone,
          onChanged: (v) => setState(() => controller.phone = v),
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: const InputDecoration(labelText: '邮箱*'),
          keyboardType: TextInputType.emailAddress,
          onChanged: (v) => setState(() => controller.email = v),
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: const InputDecoration(labelText: '设置密码*'),
          obscureText: true,
          onChanged: (v) => setState(() => controller.password = v),
        ),
        if (type == ProviderType.team)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextField(
              decoration: const InputDecoration(labelText: '团队成员（逗号分隔，可选）'),
              onChanged: (v) => setState(() => controller.teamMembers =
                  v.split(',').map((e) => {'name': e.trim()}).toList()),
            ),
          ),
        if (type == ProviderType.corporate)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextField(
              decoration: const InputDecoration(labelText: '企业法人姓名（可选）'),
              onChanged: (v) => setState(() => controller.bio = v),
            ),
          ),
      ],
    );
  }

  Widget _buildAddressFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SmartAddressInput(
          initialValue: controller.addressInput,
          onAddressChanged: (address) =>
              setState(() => controller.addressInput = address),
          onAddressParsed: (parsedData) {
            // 可以在这里处理解析后的地址数据
            print('[ProviderRegistrationPage] Address parsed: $parsedData');
            if (parsedData['position'] != null) {
              print(
                  '[ProviderRegistrationPage] Location: ${parsedData['position']}');
            }
          },
          labelText: '服务地址*',
          hintText: '点击定位图标自动获取地址，或手动输入',
          isRequired: true,
          enableLocationDetection: true,
        ),
      ],
    );
  }

  Widget _buildServiceInfoFields(ProviderType type) {
    return Column(
      children: [
        TextField(
          decoration: const InputDecoration(labelText: '主营服务类别（逗号分隔）*'),
          onChanged: (v) => setState(() => controller.serviceCategories =
              v.split(',').map((e) => e.trim()).toList()),
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: const InputDecoration(labelText: '服务区域（逗号分隔）*'),
          onChanged: (v) => setState(() => controller.serviceAreas =
              v.split(',').map((e) => e.trim()).toList()),
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: const InputDecoration(labelText: '起步价/上门费（元）*'),
          keyboardType: TextInputType.number,
          onChanged: (v) =>
              setState(() => controller.basePrice = double.tryParse(v)),
        ),
      ],
    );
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    final fileName =
        'certs/${DateTime.now().millisecondsSinceEpoch}_${picked.name}';
    final storage = Supabase.instance.client.storage.from('provider_certs');
    try {
      final res = await storage.uploadBinary(fileName, bytes);
      final url = storage.getPublicUrl(fileName);
      setState(() => controller.certificationFiles.add(url));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('上传失败: $e')),
      );
    }
  }

  Widget _buildCertificationFields(ProviderType type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton(
          onPressed: _pickAndUploadImage,
          child: const Text('上传资质/证照'),
        ),
        const SizedBox(height: 8),
        if (controller.certificationFiles.isNotEmpty)
          ...controller.certificationFiles.map((f) => Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  title: Text(f),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() => controller.certificationFiles.remove(f));
                    },
                  ),
                ),
              )),
        if (type == ProviderType.corporate)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextField(
              decoration: const InputDecoration(labelText: '营业执照编号（可选）'),
              onChanged: (v) => setState(() => controller.licenseNumber = v),
            ),
          ),
      ],
    );
  }

  Widget _buildComplianceFields() {
    return Column(
      children: [
        CheckboxListTile(
          title: const Text('是否有GST/HST税号？'),
          value: controller.hasGstHst ?? false, // Fix: Ensure boolean value
          onChanged: (bool? val) {
            setState(() => controller.hasGstHst = val!);
          },
        ),
        if (controller.hasGstHst ?? false) // Fix: Null-safe check
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextField(
              decoration: const InputDecoration(labelText: 'BN号码'),
              onChanged: (v) => setState(() => controller.bnNumber = v),
            ),
          ),
        const SizedBox(height: 8),
        TextField(
          decoration: const InputDecoration(labelText: '年收入估算'),
          keyboardType: TextInputType.number,
          onChanged: (v) => setState(
              () => controller.annualIncomeEstimate = double.tryParse(v)),
        ),
      ],
    );
  }

  bool _isFormValid() {
    return (controller.displayName?.isNotEmpty ?? false) &&
        (controller.phone?.isNotEmpty ?? false) &&
        (controller.email?.isNotEmpty ?? false) &&
        (controller.password?.isNotEmpty ?? false) &&
        (controller.addressInput?.isNotEmpty ?? false) &&
        (controller.serviceCategories.isNotEmpty ?? false) &&
        (controller.serviceAreas.isNotEmpty ?? false) &&
        (controller.basePrice != null && controller.basePrice! > 0);
  }

  Future<void> _onSubmit() async {
    if (!_isFormValid()) return;
    setState(() {
      submitting = true;
      submitResult = null; // Clear previous result
    });

    try {
      final success = await service.submitRegistration(controller);
      if (success) {
        setState(() {
          submitting = false;
          submitResult = '注册成功！';
        });
        // 注册成功后，强制刷新导航，让AuthController重新判断角色并导航
        Get.offAllNamed('/splash');
      } else {
        setState(() {
          submitting = false;
          submitResult = '注册失败，请检查填写信息。';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('注册失败，请检查填写信息。')),
        );
      }
    } catch (e) {
      setState(() {
        submitting = false;
        submitResult = '发生错误：$e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('发生错误：$e')),
      );
    }
  }
}
