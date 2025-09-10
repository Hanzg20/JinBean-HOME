import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../services/stripe_config_service.dart';
import '../models/payment_models.dart';
import '../models/base_models.dart';

/// 增强的支付表单组件
/// 
/// 提供完整的支付方式输入界面，包括：
/// - 信用卡信息输入
/// - 实时验证
/// - Apple Pay / Google Pay 支持
/// - 美观的UI设计
class EnhancedPaymentForm extends StatefulWidget {
  final Function(PaymentMethodType type, Map<String, dynamic> data)? onPaymentMethodCreated;
  final VoidCallback? onCancel;
  final bool showApplePay;
  final bool showGooglePay;
  final String? title;

  const EnhancedPaymentForm({
    super.key,
    this.onPaymentMethodCreated,
    this.onCancel,
    this.showApplePay = true,
    this.showGooglePay = true,
    this.title,
  });

  @override
  State<EnhancedPaymentForm> createState() => _EnhancedPaymentFormState();
}

class _EnhancedPaymentFormState extends State<EnhancedPaymentForm> {
  final _formKey = GlobalKey<FormState>();
  final _stripeService = Get.find<StripeConfigService>();
  
  // 表单控制器
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvcController = TextEditingController();
  final _nameController = TextEditingController();
  
  // 焦点节点
  final _cardNumberFocus = FocusNode();
  final _expiryFocus = FocusNode();
  final _cvcFocus = FocusNode();
  final _nameFocus = FocusNode();
  
  // 状态
  final RxBool _isLoading = false.obs;
  final RxString _cardBrand = 'unknown'.obs;
  final RxBool _isCardValid = false.obs;
  final RxBool _isExpiryValid = false.obs;
  final RxBool _isCvcValid = false.obs;
  final RxBool _isNameValid = false.obs;
  
  // 支付方式可用性
  final RxBool _applePaySupported = false.obs;
  final RxBool _googlePaySupported = false.obs;

  @override
  void initState() {
    super.initState();
    _setupListeners();
    _checkPaymentMethodSupport();
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    _nameController.dispose();
    _cardNumberFocus.dispose();
    _expiryFocus.dispose();
    _cvcFocus.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  void _setupListeners() {
    _cardNumberController.addListener(_onCardNumberChanged);
    _expiryController.addListener(_onExpiryChanged);
    _cvcController.addListener(_onCvcChanged);
    _nameController.addListener(_onNameChanged);
  }

  void _onCardNumberChanged() {
    final cardNumber = _cardNumberController.text;
    _cardBrand.value = _stripeService.getCardBrand(cardNumber);
    _isCardValid.value = _stripeService.validateCardNumber(cardNumber);
  }

  void _onExpiryChanged() {
    final expiry = _expiryController.text;
    if (expiry.length == 5) {
      final parts = expiry.split('/');
      if (parts.length == 2) {
        final month = int.tryParse(parts[0]);
        final year = int.tryParse('20${parts[1]}');
        if (month != null && year != null) {
          _isExpiryValid.value = _stripeService.validateExpiryDate(month, year);
        }
      }
    } else {
      _isExpiryValid.value = false;
    }
  }

  void _onCvcChanged() {
    _isCvcValid.value = _stripeService.validateCVC(_cvcController.text);
  }

  void _onNameChanged() {
    _isNameValid.value = _nameController.text.trim().isNotEmpty;
  }

  Future<void> _checkPaymentMethodSupport() async {
    if (widget.showApplePay) {
      _applePaySupported.value = await _stripeService.isApplePaySupported();
    }
    if (widget.showGooglePay) {
      _googlePaySupported.value = await _stripeService.isGooglePaySupported();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -4),
            blurRadius: 16,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 标题栏
          _buildHeader(),
          
          const SizedBox(height: 24),
          
          // 快捷支付方式
          _buildQuickPaymentMethods(),
          
          const SizedBox(height: 24),
          
          // 分割线
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '或使用银行卡',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // 信用卡表单
          _buildCardForm(),
          
          const SizedBox(height: 24),
          
          // 操作按钮
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          widget.title ?? '添加支付方式',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          onPressed: widget.onCancel,
          icon: const Icon(Icons.close),
          style: IconButton.styleFrom(
            backgroundColor: Colors.grey[100],
            foregroundColor: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickPaymentMethods() {
    return Obx(() {
      final methods = <Widget>[];
      
      if (_applePaySupported.value) {
        methods.add(_buildApplePayButton());
      }
      
      if (_googlePaySupported.value) {
        methods.add(_buildGooglePayButton());
      }
      
      if (methods.isEmpty) {
        return const SizedBox.shrink();
      }
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '快捷支付',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          ...methods.map((method) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: method,
          )),
        ],
      );
    });
  }

  Widget _buildApplePayButton() {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: _handleApplePay,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.apple, size: 24),
            const SizedBox(width: 8),
            const Text('Apple Pay', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildGooglePayButton() {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: _handleGooglePay,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          side: const BorderSide(color: Colors.grey),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google Pay图标
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('G', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 8),
            const Text('Google Pay', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildCardForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // 卡号输入
          _buildCardNumberField(),
          
          const SizedBox(height: 16),
          
          // 过期日期和CVC
          Row(
            children: [
              Expanded(child: _buildExpiryField()),
              const SizedBox(width: 16),
              Expanded(child: _buildCvcField()),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 持卡人姓名
          _buildNameField(),
        ],
      ),
    );
  }

  Widget _buildCardNumberField() {
    return Obx(() => TextFormField(
      controller: _cardNumberController,
      focusNode: _cardNumberFocus,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        _CardNumberInputFormatter(),
      ],
      decoration: InputDecoration(
        labelText: '卡号',
        hintText: '1234 5678 9012 3456',
        prefixIcon: _buildCardBrandIcon(),
        suffixIcon: _isCardValid.value 
            ? const Icon(Icons.check_circle, color: Colors.green)
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '请输入卡号';
        }
        if (!_stripeService.validateCardNumber(value)) {
          return '卡号格式不正确';
        }
        return null;
      },
      onFieldSubmitted: (_) => _expiryFocus.requestFocus(),
    ));
  }

  Widget _buildExpiryField() {
    return Obx(() => TextFormField(
      controller: _expiryController,
      focusNode: _expiryFocus,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        _ExpiryDateInputFormatter(),
      ],
      decoration: InputDecoration(
        labelText: '过期日期',
        hintText: 'MM/YY',
        suffixIcon: _isExpiryValid.value 
            ? const Icon(Icons.check_circle, color: Colors.green)
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '请输入过期日期';
        }
        if (!_isExpiryValid.value) {
          return '日期格式不正确';
        }
        return null;
      },
      onFieldSubmitted: (_) => _cvcFocus.requestFocus(),
    ));
  }

  Widget _buildCvcField() {
    return Obx(() => TextFormField(
      controller: _cvcController,
      focusNode: _cvcFocus,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(4),
      ],
      decoration: InputDecoration(
        labelText: 'CVC',
        hintText: '123',
        suffixIcon: _isCvcValid.value 
            ? const Icon(Icons.check_circle, color: Colors.green)
            : const Icon(Icons.help_outline, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '请输入CVC';
        }
        if (!_stripeService.validateCVC(value)) {
          return 'CVC格式不正确';
        }
        return null;
      },
      onFieldSubmitted: (_) => _nameFocus.requestFocus(),
    ));
  }

  Widget _buildNameField() {
    return Obx(() => TextFormField(
      controller: _nameController,
      focusNode: _nameFocus,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        labelText: '持卡人姓名',
        hintText: '请输入持卡人姓名',
        suffixIcon: _isNameValid.value 
            ? const Icon(Icons.check_circle, color: Colors.green)
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '请输入持卡人姓名';
        }
        return null;
      },
    ));
  }

  Widget _buildCardBrandIcon() {
    return Obx(() {
      IconData icon;
      Color color;
      
      switch (_cardBrand.value) {
        case 'visa':
          icon = Icons.credit_card;
          color = Colors.blue;
          break;
        case 'mastercard':
          icon = Icons.credit_card;
          color = Colors.red;
          break;
        case 'amex':
          icon = Icons.credit_card;
          color = Colors.green;
          break;
        default:
          icon = Icons.credit_card;
          color = Colors.grey;
      }
      
      return Icon(icon, color: color);
    });
  }

  Widget _buildActionButtons() {
    return Obx(() => Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading.value ? null : _handleAddCard,
            style: ElevatedButton.styleFrom(
              backgroundColor: Get.theme.colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: _isLoading.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    '添加银行卡',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        TextButton(
          onPressed: widget.onCancel,
          child: const Text('取消'),
        ),
      ],
    ));
  }

  Future<void> _handleApplePay() async {
    try {
      _isLoading.value = true;
      
      // 这里应该调用Apple Pay流程
      // 现在只是模拟
      await Future.delayed(const Duration(seconds: 1));
      
      widget.onPaymentMethodCreated?.call(
        PaymentMethodType.applePay,
        {'type': 'apple_pay'},
      );
      
    } catch (e) {
      Get.snackbar('错误', 'Apple Pay支付失败: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _handleGooglePay() async {
    try {
      _isLoading.value = true;
      
      // 这里应该调用Google Pay流程
      // 现在只是模拟
      await Future.delayed(const Duration(seconds: 1));
      
      widget.onPaymentMethodCreated?.call(
        PaymentMethodType.googlePay,
        {'type': 'google_pay'},
      );
      
    } catch (e) {
      Get.snackbar('错误', 'Google Pay支付失败: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _handleAddCard() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      _isLoading.value = true;
      
      final expiry = _expiryController.text.split('/');
      final month = int.parse(expiry[0]);
      final year = int.parse('20${expiry[1]}');
      
      final paymentMethodData = {
        'card_number': _cardNumberController.text.replaceAll(' ', ''),
        'exp_month': month,
        'exp_year': year,
        'cvc': _cvcController.text,
        'cardholder_name': _nameController.text.trim(),
        'card_brand': _cardBrand.value,
      };
      
      widget.onPaymentMethodCreated?.call(
        PaymentMethodType.creditCard,
        paymentMethodData,
      );
      
    } catch (e) {
      Get.snackbar('错误', '添加银行卡失败: $e');
    } finally {
      _isLoading.value = false;
    }
  }
}

/// 卡号输入格式化器
class _CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < text.length && i < 16; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(text[i]);
    }
    
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// 过期日期输入格式化器
class _ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('/', '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < text.length && i < 4; i++) {
      if (i == 2) {
        buffer.write('/');
      }
      buffer.write(text[i]);
    }
    
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
