import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 只渲染一个简单的 Scaffold，内容是一个固定高度的 GridView
    return Scaffold(
      appBar: AppBar(title: const Text('极简测试首页')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // 用 SizedBox 限定高度，防止无限展开
            SizedBox(
              height: 300,
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                shrinkWrap: true,
                primary: false,
                physics: const NeverScrollableScrollPhysics(),
                children: List.generate(6, (index) {
                  return Container(
                    color: Colors.primaries[index % Colors.primaries.length],
                    child: Center(child: Text('Item $index')),
                  );
                }),
              ),
            ),
            const SizedBox(height: 20),
            // 其它内容
            const Text('极简测试内容'),
          ],
        ),
      ),
    );
  }
}