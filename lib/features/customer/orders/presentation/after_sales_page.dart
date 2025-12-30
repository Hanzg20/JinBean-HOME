import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AfterSalesPage extends StatefulWidget {
  final String orderId;
  const AfterSalesPage({required this.orderId, super.key});

  @override
  State<AfterSalesPage> createState() => _AfterSalesPageState();
}

class _AfterSalesPageState extends State<AfterSalesPage> {
  String _type = 'refund';
  final _reasonController = TextEditingController();

  void _submit() async {
    if (_reasonController.text.isEmpty) {
      Get.snackbar('错误', '请填写原因');
      return;
    }

    Get.dialog(Center(child: CircularProgressIndicator()));

    try {
      // TODO: 调用售后API
      await Future.delayed(Duration(seconds: 1));

      Get.back(); // 关闭loading
      Get.back(); // 返回订单页
      Get.snackbar('成功', '售后申请已提交');
    } catch (e) {
      Get.back();
      Get.snackbar('失败', e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('申请售后')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // 售后类型
            Card(
              child: Column(
                children: [
                  RadioListTile(
                    title: Text('退款'),
                    subtitle: Text('仅退款，不退货'),
                    value: 'refund',
                    groupValue: _type,
                    onChanged: (v) => setState(() => _type = v!),
                  ),
                  RadioListTile(
                    title: Text('退货退款'),
                    subtitle: Text('退货并退款'),
                    value: 'return',
                    groupValue: _type,
                    onChanged: (v) => setState(() => _type = v!),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            // 原因输入
            TextField(
              controller: _reasonController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: '售后原因',
                hintText: '请描述您遇到的问题...',
                border: OutlineInputBorder(),
              ),
            ),
            Spacer(),
            // 提交按钮
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                child: Text('提交申请'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }
}