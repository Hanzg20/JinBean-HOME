import 'package:flutter/material.dart';
import '../../shared/widgets/smart_address_input.dart';

class AddressInputDemoPage extends StatefulWidget {
  const AddressInputDemoPage({super.key});

  @override
  State<AddressInputDemoPage> createState() => _AddressInputDemoPageState();
}

class _AddressInputDemoPageState extends State<AddressInputDemoPage> {
  String? currentAddress;
  Map<String, dynamic>? parsedData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('智能地址输入演示'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 功能介绍
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '智能地址输入功能',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• 点击定位图标自动获取当前位置地址\n'
                      '• 实时地址解析和验证\n'
                      '• 智能地址建议\n'
                      '• 加拿大地址格式支持\n'
                      '• 地图选点功能（开发中）\n'
                      '• 统一使用LocationController管理位置',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 地址输入组件
            const Text(
              '地址输入',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            SmartAddressInput(
              initialValue: currentAddress,
              onAddressChanged: (address) {
                setState(() {
                  currentAddress = address;
                });
              },
              onAddressParsed: (data) {
                setState(() {
                  parsedData = data;
                });
                print('[Demo] Address parsed: $data');
              },
              labelText: '服务地址',
              hintText: '点击定位图标自动获取地址，或手动输入',
              isRequired: true,
              showSuggestions: true,
              showMapButton: true,
              showHelpButton: true,
              enableLocationDetection: true,
            ),

            const SizedBox(height: 24),

            // 解析结果显示
            if (parsedData != null) ...[
              const Text(
                '解析结果',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            parsedData!['isValid']
                                ? Icons.check_circle
                                : Icons.info_outline,
                            color: parsedData!['isValid']
                                ? Colors.green
                                : Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            parsedData!['isValid'] ? '地址有效' : '地址格式待完善',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: parsedData!['isValid']
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (parsedData!['components'] != null) ...[
                        const Text('地址组件：',
                            style: TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        ...(parsedData!['components'] as Map<String, String>)
                            .entries
                            .map((entry) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                Text('${entry.key}: ',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500)),
                                Text(entry.value),
                              ],
                            ),
                          );
                        }),
                      ],
                      if (parsedData!['position'] != null) ...[
                        const SizedBox(height: 16),
                        const Text('位置信息：',
                            style: TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        Text('纬度: ${parsedData!['position']['latitude']}'),
                        Text('经度: ${parsedData!['position']['longitude']}'),
                      ],
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // 使用说明
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '使用说明',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '1. 点击定位图标（📍）打开位置选择对话框\n'
                      '2. 选择"使用当前位置"获取GPS定位\n'
                      '3. 选择"搜索地址"手动输入地址搜索\n'
                      '4. 选择"常用城市"快速选择加拿大主要城市\n'
                      '5. 手动输入地址时，系统会实时解析和验证\n'
                      '6. 输入时会显示常用城市建议\n'
                      '7. 点击帮助图标（❓）查看地址格式说明\n'
                      '8. 地图选点功能正在开发中\n\n'
                      '支持的地址格式：\n'
                      '• 123 Bank St, Ottawa, ON K2P 1L4\n'
                      '• 456 Queen St W, Toronto, ON M5V 2A9\n'
                      '• 789 Robson St, Vancouver, BC V6Z 1C3',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
