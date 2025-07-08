import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'provider_registration_controller.dart';
import 'address_service.dart';

class ProviderRegistrationService {
  final AddressService _addressService = AddressService();

  // 注册API，写入Supabase provider_profiles表
  Future<bool> submitRegistration(ProviderRegistrationController controller) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        print('[ProviderRegistrationService] No user logged in');
        return false;
      }

      // 1. 处理地址，获取 address_id
      String? addressId;
      if (controller.addressInput != null && controller.addressInput!.isNotEmpty) {
        addressId = await _addressService.getOrCreateAddress(controller.addressInput!);
        if (addressId == null) {
          print('[ProviderRegistrationService] Failed to process address');
          return false;
        }
      }

      // 2. 提交服务商资料
      final data = {
        'id': user.id, // 使用用户ID作为服务商资料的ID
        'user_id': user.id,
        'display_name': controller.displayName,
        'phone': controller.phone,
        'email': controller.email,
        'provider_type': controller.providerType.toString().split('.').last,
        'address_id': addressId,
        'business_address': controller.addressInput, // 匹配 schema 中的 business_address
        'service_categories': controller.serviceCategories,
        'service_areas': controller.serviceAreas,
        'base_price': controller.basePrice,
        'certification_files': controller.certificationFiles,
        'documents': null, // 匹配 schema 中的 documents
        'has_gst_hst': controller.hasGstHst,
        'bn_number': controller.bnNumber,
        'annual_income_estimate': controller.annualIncomeEstimate,
        'license_number': controller.licenseNumber,
        'certification_status': 'pending',
        'status': 'pending', // 匹配 schema 中的 status
      };
      print('[ProviderRegistrationService] Submitting data: $data');
      final res = await Supabase.instance.client
          .from('provider_profiles')
          .insert(data);

      if (res.error == null) {
        // 成功注册为服务商，更新 user_profiles 表中的用户角色
        final updateResp = await Supabase.instance.client
            .from('user_profiles')
            .update({'role': 'customer+provider'})
            .eq('id', user.id);

        if (updateResp.error != null) {
          print('[ProviderRegistrationService] Error updating user role: ${updateResp.error!.message}');
        } else {
          print('[ProviderRegistrationService] User role updated to customer+provider for ${user.id}');
        }
      }
      print('[ProviderRegistrationService] Supabase insert result: $res');
      return res.error == null;
    } catch (e, stack) {
      print('[ProviderRegistrationService] Exception: $e\n$stack');
      rethrow;
    }
  }
} 