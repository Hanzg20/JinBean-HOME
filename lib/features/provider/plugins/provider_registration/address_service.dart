import 'package:supabase_flutter/supabase_flutter.dart';

class AddressService {
  // 检查地址是否已存在，返回 address_id
  Future<String?> getOrCreateAddress(String addressInput) async {
    if (addressInput.isEmpty) return null;
    
    try {
      final postalCode = _extractPostalCode(addressInput);
      final streetName = _extractStreetName(addressInput);
      
      if (postalCode.isEmpty || streetName.isEmpty) {
        print('[AddressService] Invalid address format: $addressInput');
        return null;
      }
      
      // 检查地址是否已存在
      final existingAddress = await Supabase.instance.client
          .from('addresses')
          .select('id')
          .eq('postal_code', postalCode)
          .eq('street_name', streetName)
          .maybeSingle();
      
      if (existingAddress != null) {
        print('[AddressService] Found existing address: ${existingAddress['id']}');
        return existingAddress['id'];
      }
      
      // 创建新地址
      final addressData = _parseAddress(addressInput);
      final addressRes = await Supabase.instance.client
          .from('addresses')
          .insert(addressData)
          .select('id')
          .single();
      
      final newAddressId = addressRes['id'];
      print('[AddressService] Created new address: $newAddressId');
      return newAddressId;
      
    } catch (e, stack) {
      print('[AddressService] Error processing address: $e\n$stack');
      return null;
    }
  }

  // 解析地址字符串为结构化数据
  Map<String, dynamic> _parseAddress(String address) {
    final postalCode = _extractPostalCode(address);
    final streetName = _extractStreetName(address);
    final streetNumber = _extractStreetNumber(address);
    final streetType = _extractStreetType(address);
    final city = _extractCity(address);
    final province = _extractProvince(address);
    
    return {
      'country': 'Canada',
      'province': province,
      'city': city,
      'street_number': streetNumber,
      'street_name': streetName,
      'street_type': streetType,
      'postal_code': postalCode,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  // 提取门牌号
  String _extractStreetNumber(String address) {
    final match = RegExp(r'^(\d+)').firstMatch(address);
    return match?.group(1) ?? '';
  }

  // 提取邮编
  String _extractPostalCode(String address) {
    final regex = RegExp(r'[A-Z]\d[A-Z]\s?\d[A-Z]\d');
    final match = regex.firstMatch(address.toUpperCase());
    return match?.group(0)?.replaceAll(' ', '') ?? '';
  }

  // 提取街道名
  String _extractStreetName(String address) {
    // 移除邮编
    String cleanAddress = address.replaceAll(RegExp(r'[A-Z]\d[A-Z]\s?\d[A-Z]\d'), '').trim();
    
    // 移除城市和省份
    cleanAddress = cleanAddress.replaceAll(RegExp(r',\s*[^,]+,\s*[A-Z]{2}'), '').trim();
    
    // 提取街道部分（门牌号后的部分）
    final streetMatch = RegExp(r'^\d+\s+(.+?)(?:\s+(?:St|Ave|Rd|Blvd|Cres|Dr|Way|Pl|Ct|Ln|Ter|Hwy|Pkwy|Circle|Square|Court|Garden|Place|Road|Street|Avenue|Boulevard|Crescent|Drive|Way|Place|Court|Lane|Terrace|Highway|Parkway))?$', caseSensitive: false).firstMatch(cleanAddress);
    
    if (streetMatch != null) {
      String streetName = streetMatch.group(1)?.trim() ?? '';
      // 移除街道类型后缀
      streetName = streetName.replaceAll(RegExp(r'\s+(?:St|Ave|Rd|Blvd|Cres|Dr|Way|Pl|Ct|Ln|Ter|Hwy|Pkwy|Circle|Square|Court|Garden|Place|Road|Street|Avenue|Boulevard|Crescent|Drive|Way|Place|Court|Lane|Terrace|Highway|Parkway)$', caseSensitive: false), '').trim();
      return streetName;
    }
    
    return cleanAddress;
  }

  // 提取街道类型
  String _extractStreetType(String address) {
    final typeMatch = RegExp(r'\s+(St|Ave|Rd|Blvd|Cres|Dr|Way|Pl|Ct|Ln|Ter|Hwy|Pkwy|Circle|Square|Court|Garden|Place|Road|Street|Avenue|Boulevard|Crescent|Drive|Way|Place|Court|Lane|Terrace|Highway|Parkway)(?:\s|,|$)', caseSensitive: false).firstMatch(address);
    return typeMatch?.group(1)?.toUpperCase() ?? '';
  }

  // 提取城市
  String _extractCity(String address) {
    final parts = address.split(',');
    if (parts.length > 1) {
      final cityPart = parts[1].trim();
      // 移除省份缩写
      return cityPart.replaceAll(RegExp(r'\s+[A-Z]{2}\s*$'), '').trim();
    }
    return '';
  }

  // 提取省份
  String _extractProvince(String address) {
    final provinceRegex = RegExp(r'\b(ON|QC|BC|AB|MB|NB|NL|NS|NT|NU|PE|SK|YT)\b');
    final match = provinceRegex.firstMatch(address.toUpperCase());
    return match?.group(1) ?? '';
  }

  // 验证地址格式
  bool isValidAddress(String address) {
    final hasPostalCode = RegExp(r'[A-Z]\d[A-Z]\s?\d[A-Z]\d').hasMatch(address.toUpperCase());
    final hasStreetNumber = RegExp(r'^\d+').hasMatch(address);
    final hasCity = address.contains(',');
    final hasProvince = RegExp(r'\b(ON|QC|BC|AB|MB|NB|NL|NS|NT|NU|PE|SK|YT)\b').hasMatch(address.toUpperCase());
    
    return hasPostalCode && hasStreetNumber && hasCity && hasProvince;
  }

  // 获取地址解析结果（用于UI显示）
  Map<String, String> getAddressComponents(String address) {
    return {
      '门牌号': _extractStreetNumber(address),
      '街道名': _extractStreetName(address),
      '街道类型': _extractStreetType(address),
      '城市': _extractCity(address),
      '省份': _extractProvince(address),
      '邮编': _extractPostalCode(address),
    };
  }

  // 格式化地址显示
  String formatAddress(String address) {
    final components = getAddressComponents(address);
    final streetNumber = components['门牌号'] ?? '';
    final streetName = components['街道名'] ?? '';
    final streetType = components['街道类型'] ?? '';
    final city = components['城市'] ?? '';
    final province = components['省份'] ?? '';
    final postalCode = components['邮编'] ?? '';

    if (streetNumber.isNotEmpty && streetName.isNotEmpty && city.isNotEmpty && province.isNotEmpty && postalCode.isNotEmpty) {
      return '$streetNumber $streetName $streetType, $city, $province $postalCode';
    }
    
    return address;
  }
} 