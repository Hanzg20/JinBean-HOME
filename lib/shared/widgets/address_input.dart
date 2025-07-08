import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../features/provider/plugins/provider_registration/address_service.dart';

class AddressInput extends StatefulWidget {
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

  const AddressInput({
    super.key,
    this.initialValue,
    required this.onAddressChanged,
    this.onAddressParsed,
    this.labelText = '地址',
    this.hintText = '输入加拿大地址或点击定位获取',
    this.isRequired = true,
    this.showSuggestions = true,
    this.showMapButton = true,
    this.showHelpButton = true,
    this.enableLocationDetection = true,
  });

  @override
  State<AddressInput> createState() => _AddressInputState();
}

class _AddressInputState extends State<AddressInput> {
  final TextEditingController _controller = TextEditingController();
  final AddressService _addressService = AddressService();
  final FocusNode _focusNode = FocusNode();

  bool _isValid = false;
  bool _isParsing = false;
  bool _isGettingLocation = false;
  Map<String, String>? _parsedComponents;
  List<String> _suggestions = [];
  bool _showSuggestions = false;
  Position? _currentPosition;

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
    _controller.text = widget.initialValue ?? '';
    _focusNode.addListener(_onFocusChange);
    _controller.addListener(_onTextChanged);

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

    setState(() {
      _isGettingLocation = true;
    });

    try {
      // 检查位置权限
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showLocationPermissionDialog();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showLocationPermissionDialog();
        return;
      }

      // 获取当前位置
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      setState(() {
        _currentPosition = position;
      });

      // 根据坐标获取地址
      await _getAddressFromCoordinates(position.latitude, position.longitude);
    } catch (e) {
      print('[AddressInput] Location error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('获取位置失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isGettingLocation = false;
      });
    }
  }

  // 根据坐标获取地址
  Future<void> _getAddressFromCoordinates(
      double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;

        // 构建加拿大格式的地址
        String address = '';

        // 门牌号和街道
        if (placemark.subThoroughfare != null &&
            placemark.subThoroughfare!.isNotEmpty) {
          address += '${placemark.subThoroughfare} ';
        }
        if (placemark.thoroughfare != null &&
            placemark.thoroughfare!.isNotEmpty) {
          address += '${placemark.thoroughfare}';
        }

        // 城市和省份
        if (placemark.locality != null && placemark.locality!.isNotEmpty) {
          address += ', ${placemark.locality}';
        }
        if (placemark.administrativeArea != null &&
            placemark.administrativeArea!.isNotEmpty) {
          address += ', ${placemark.administrativeArea}';
        }

        // 邮编
        if (placemark.postalCode != null && placemark.postalCode!.isNotEmpty) {
          address += ' ${placemark.postalCode}';
        }

        // 国家
        if (placemark.country != null && placemark.country!.isNotEmpty) {
          address += ', ${placemark.country}';
        }

        // 更新输入框
        _controller.text = address;
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: address.length),
        );

        // 解析地址
        _parseAddress(address);

        // 显示成功消息
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('已获取当前位置地址，请确认或修改'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('[AddressInput] Geocoding error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('地址解析失败: $e'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _showLocationPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('位置权限'),
        content: const Text('需要位置权限来获取您的地址。请在设置中开启位置权限。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Geolocator.openAppSettings();
            },
            child: const Text('去设置'),
          ),
        ],
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
        widget.onAddressParsed!({
          'address': address,
          'components': components,
          'isValid': isValid,
          'position': _currentPosition,
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
                if (_isGettingLocation)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                if (_isValid)
                  const Icon(Icons.check_circle, color: Colors.green),
                if (!_isValid &&
                    _controller.text.isNotEmpty &&
                    !_isParsing &&
                    !_isGettingLocation)
                  const Icon(Icons.error, color: Colors.red),
                if (widget.enableLocationDetection)
                  IconButton(
                    onPressed: _isGettingLocation ? null : _getCurrentLocation,
                    icon: Icon(
                      _isGettingLocation
                          ? Icons.location_searching
                          : Icons.my_location,
                      color: _isGettingLocation ? Colors.grey : Colors.blue,
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
                  children: _parsedComponents!.entries.map((entry) {
                    return Chip(
                      label: Text('${entry.key}: ${entry.value}'),
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Colors.grey.shade300),
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
