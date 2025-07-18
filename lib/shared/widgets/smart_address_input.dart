import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/controllers/location_controller.dart';
import '../../features/provider/plugins/provider_registration/address_service.dart';

class SmartAddressInput extends StatefulWidget {
  final String? initialValue;
  final Function(String) onAddressChanged;
  final Function(Map<String, dynamic>)? onAddressParsed;
  final String? labelText;
  final String? hintText;
  final bool isRequired;
  final bool showSuggestions;
  final bool showMapButton;
  final bool showHelpButton;
  final bool enableLocationDetection;

  const SmartAddressInput({
    super.key,
    this.initialValue,
    required this.onAddressChanged,
    this.onAddressParsed,
    this.labelText = '地址',
    this.hintText = '输入地址或点击定位获取',
    this.isRequired = true,
    this.showSuggestions = true,
    this.showMapButton = true,
    this.showHelpButton = true,
    this.enableLocationDetection = true,
  });

  @override
  State<SmartAddressInput> createState() => _SmartAddressInputState();
}

class _SmartAddressInputState extends State<SmartAddressInput> {
  final TextEditingController _controller = TextEditingController();
  final AddressService _addressService = AddressService();
  final FocusNode _focusNode = FocusNode();
  late final LocationController _locationController;

  bool _isValid = false;
  bool _isParsing = false;
  Map<String, String>? _parsedComponents;
  List<String> _suggestions = [];
  bool _showSuggestions = false;

  // 加拿大主要城市和省份
  final List<String> _commonCities = [
    'Toronto, ON',
    'Vancouver, BC',
    'Montreal, QC',
    'Calgary, AB',
    'Edmonton, AB',
    'Ottawa, ON',
    'Winnipeg, MB',
    'Quebec City, QC',
    'Hamilton, ON',
    'Kitchener, ON',
    'London, ON',
    'Victoria, BC',
    'Halifax, NS',
    'Oshawa, ON',
    'Windsor, ON',
    'Saskatoon, SK',
    'Regina, SK',
    'St. John\'s, NL',
    'Kelowna, BC',
    'Kingston, ON',
  ];

  @override
  void initState() {
    super.initState();
    _locationController = Get.find<LocationController>();
    _controller.text = widget.initialValue ?? '';
    _focusNode.addListener(_onFocusChange);
    _controller.addListener(_onTextChanged);

    if (widget.initialValue == null || (widget.initialValue ?? '').isEmpty) {
      if (widget.enableLocationDetection) {
        _getCurrentLocation();
      }
    }

    if (_controller.text.isNotEmpty) {
      _parseAddress(_controller.text);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus &&
        _controller.text.isEmpty &&
        widget.showSuggestions) {
      setState(() {
        _showSuggestions = true;
        _suggestions = _commonCities;
      });
    } else if (!_focusNode.hasFocus) {
      setState(() {
        _showSuggestions = false;
      });
    }
  }

  void _onTextChanged() {
    final text = _controller.text;
    widget.onAddressChanged(text);

    if (text.length >= 3) {
      _parseAddress(text);
      if (widget.showSuggestions) {
        _updateSuggestions(text);
      }
    } else {
      setState(() {
        _isValid = false;
        _parsedComponents = null;
        _showSuggestions = false;
      });
    }
  }

  // 获取当前位置
  Future<void> _getCurrentLocation() async {
    if (!widget.enableLocationDetection) return;

    try {
      await _locationController.getCurrentLocation();

      // 监听位置更新
      ever(_locationController.currentLocation, (UserLocation? location) {
        if (location != null) {
          _updateAddressFromLocation(location);
        }
      });

      // 如果已经有位置，直接使用
      final currentLocation = _locationController.currentLocation.value;
      if (currentLocation != null) {
        _updateAddressFromLocation(currentLocation);
      }
    } catch (e) {
      print('[SmartAddressInput] Location error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('获取位置失败: ${_locationController.errorMessage.value}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _updateAddressFromLocation(UserLocation location) {
    // 更新输入框
    _controller.text = location.address;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: location.address.length),
    );

    // 解析地址
    _parseAddress(location.address);

    // 显示成功消息
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('已获取当前位置地址，请确认或修改'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _parseAddress(String address) async {
    if (address.isEmpty) return;

    setState(() {
      _isParsing = true;
    });

    try {
      final components = _addressService.getAddressComponents(address);
      final isValid = _addressService.isValidAddress(address);

      setState(() {
        _parsedComponents = components;
        _isValid = isValid;
        _isParsing = false;
      });

      if (widget.onAddressParsed != null) {
        final currentLocation = _locationController.currentLocation.value;
        widget.onAddressParsed!({
          'address': address,
          'components': components,
          'isValid': isValid,
          'position': currentLocation != null
              ? {
                  'latitude': currentLocation.latitude,
                  'longitude': currentLocation.longitude,
                  'accuracy': null, // LocationController 中没有精度信息
                }
              : null,
        });
      }
    } catch (e) {
      setState(() {
        _isParsing = false;
        _isValid = false;
      });
    }
  }

  void _updateSuggestions(String query) {
    if (query.isEmpty) {
      setState(() {
        _suggestions = _commonCities;
        _showSuggestions = true;
      });
      return;
    }

    final filtered = _commonCities.where((city) {
      return city.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      _suggestions = filtered;
      _showSuggestions = filtered.isNotEmpty;
    });
  }

  void _selectSuggestion(String suggestion) {
    _controller.text = suggestion;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: suggestion.length),
    );
    _focusNode.unfocus();
    setState(() {
      _showSuggestions = false;
    });
    _parseAddress(suggestion);
  }

  void _showLocationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择位置'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.my_location),
              title: const Text('使用当前位置'),
              subtitle: const Text('获取GPS定位'),
              onTap: () {
                Navigator.of(context).pop();
                _getCurrentLocation();
              },
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('搜索地址'),
              subtitle: const Text('手动输入地址'),
              onTap: () {
                Navigator.of(context).pop();
                _showAddressSearchDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_city),
              title: const Text('常用城市'),
              subtitle: const Text('选择常用城市'),
              onTap: () {
                Navigator.of(context).pop();
                _showCitySelectionDialog();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  void _showAddressSearchDialog() {
    final TextEditingController searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('搜索地址'),
        content: TextField(
          controller: searchController,
          decoration: const InputDecoration(
            hintText: '输入地址进行搜索',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (searchController.text.isNotEmpty) {
                Navigator.of(context).pop();
                final location = await _locationController
                    .searchLocationByAddress(searchController.text);
                if (location != null) {
                  _updateAddressFromLocation(location);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('未找到该地址'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              }
            },
            child: const Text('搜索'),
          ),
        ],
      ),
    );
  }

  void _showCitySelectionDialog() {
    // 常用加拿大城市数据
    final cityData = [
      {
        'name': 'Toronto',
        'code': 'ON',
        'latitude': 43.6532,
        'longitude': -79.3832
      },
      {
        'name': 'Vancouver',
        'code': 'BC',
        'latitude': 49.2827,
        'longitude': -123.1207
      },
      {
        'name': 'Montreal',
        'code': 'QC',
        'latitude': 45.5017,
        'longitude': -73.5673
      },
      {
        'name': 'Calgary',
        'code': 'AB',
        'latitude': 51.0447,
        'longitude': -114.0719
      },
      {
        'name': 'Edmonton',
        'code': 'AB',
        'latitude': 53.5461,
        'longitude': -113.4938
      },
      {
        'name': 'Ottawa',
        'code': 'ON',
        'latitude': 45.4215,
        'longitude': -75.6972
      },
      {
        'name': 'Winnipeg',
        'code': 'MB',
        'latitude': 49.8951,
        'longitude': -97.1384
      },
      {
        'name': 'Quebec City',
        'code': 'QC',
        'latitude': 46.8139,
        'longitude': -71.2080
      },
      {
        'name': 'Hamilton',
        'code': 'ON',
        'latitude': 43.2557,
        'longitude': -79.8711
      },
      {
        'name': 'Kitchener',
        'code': 'ON',
        'latitude': 43.4516,
        'longitude': -80.4925
      },
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择城市'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: cityData.length,
            itemBuilder: (context, index) {
              final city = cityData[index];
              return ListTile(
                title: Text('${city['name']}, ${city['code']}'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final location = UserLocation(
                    latitude: city['latitude'] as double,
                    longitude: city['longitude'] as double,
                    address: '${city['name']}, ${city['code']}',
                    city: city['name'] as String,
                    district: '',
                    source: LocationSource.manual,
                    lastUpdated: DateTime.now(),
                  );
                  await _locationController.selectLocation(location);
                  _updateAddressFromLocation(location);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  void _showAddressFormatHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('加拿大地址格式说明'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('标准格式：'),
            SizedBox(height: 8),
            Text('门牌号 + 街道名 + 街道类型, 城市, 省份 邮编'),
            SizedBox(height: 16),
            Text('示例：'),
            SizedBox(height: 8),
            Text('• 123 Bank St, Ottawa, ON K2P 1L4'),
            Text('• 456 Queen St W, Toronto, ON M5V 2A9'),
            Text('• 789 Robson St, Vancouver, BC V6Z 1C3'),
            SizedBox(height: 16),
            Text('提示：'),
            SizedBox(height: 8),
            Text('• 邮编格式：A1A 1A1（字母-数字-字母 空格 数字-字母-数字）'),
            Text('• 省份缩写：ON, BC, AB, QC, MB, SK, NS, NB, NL, PE, NT, NU, YT'),
            Text('• 街道类型：St, Ave, Rd, Blvd, Cres, Dr, Way, Pl, Ct 等'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 地址输入框
        TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            labelText: widget.labelText,
            hintText: widget.hintText,
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isParsing)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                Obx(() => _locationController.isLoading.value
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : const SizedBox.shrink()),
                if (_isValid)
                  const Icon(Icons.check_circle, color: Colors.green),
                if (widget.enableLocationDetection)
                  IconButton(
                    onPressed: _locationController.isLoading.value
                        ? null
                        : _showLocationDialog,
                    icon: Icon(
                      _locationController.isLoading.value
                          ? Icons.location_searching
                          : Icons.my_location,
                      color: _locationController.isLoading.value
                          ? Colors.grey
                          : Colors.blue,
                    ),
                    tooltip: '获取当前位置',
                  ),
                if (widget.showMapButton)
                  IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('地图选点功能开发中...')),
                      );
                    },
                    icon: const Icon(Icons.map),
                    tooltip: '地图选点',
                  ),
                if (widget.showHelpButton)
                  IconButton(
                    onPressed: _showAddressFormatHelp,
                    icon: const Icon(Icons.help_outline),
                    tooltip: '地址格式说明',
                  ),
              ],
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: _isValid ? Colors.green : Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
          ),
          validator: widget.isRequired
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入地址';
                  }
                  if (!_isValid) {
                    return '请输入有效的加拿大地址';
                  }
                  return null;
                }
              : null,
        ),

        const SizedBox(height: 8),

        // 地址解析结果
        if (_parsedComponents != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _isValid ? Colors.green.shade50 : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color:
                    _isValid ? Colors.green.shade200 : Colors.orange.shade200,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _isValid ? Icons.check_circle : Icons.info_outline,
                      color: _isValid ? Colors.green : Colors.orange,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isValid ? '地址解析成功' : '地址格式待完善',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _isValid ? Colors.green : Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    '门牌号',
                    '街道名',
                    '街道类型',
                    '城市',
                    '省份',
                    '邮编',
                  ].map((key) {
                    final value = _parsedComponents![key];
                    final isMissing = value == null || value.isEmpty;
                    return Chip(
                      label: Text(
                        isMissing ? '$key: 待补充' : '$key: $value',
                        style: TextStyle(
                          color: isMissing ? Colors.red : Colors.black,
                        ),
                      ),
                      backgroundColor: Colors.white,
                      side: BorderSide(
                          color: isMissing ? Colors.red : Colors.grey.shade300),
                      labelStyle: const TextStyle(fontSize: 12),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

        // 地址建议
        if (_showSuggestions && widget.showSuggestions)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _suggestions[index];
                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.location_city, size: 16),
                  title: Text(suggestion),
                  onTap: () => _selectSuggestion(suggestion),
                );
              },
            ),
          ),
      ],
    );
  }
}
