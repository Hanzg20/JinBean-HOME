import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jinbeanpod_83904710/core/utils/app_logger.dart';

class ClientController extends GetxController {
  final _supabase = Supabase.instance.client;
  
  // Observable variables
  final RxList<Map<String, dynamic>> clients = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = 'all'.obs;
  final RxInt currentPage = 1.obs;
  final RxBool hasMoreData = true.obs;
  
  // Categories
  final List<String> categories = ['all', 'served', 'in_negotiation', 'potential'];
  
  // Pagination
  static const int pageSize = 20;
  
  @override
  void onInit() {
    super.onInit();
    AppLogger.info('[ClientController] Controller initialized', tag: 'Client');
    loadClients();
  }
  
  /// Load clients with pagination and filtering
  Future<void> loadClients({bool refresh = false}) async {
    try {
      isLoading.value = true;
      
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        AppLogger.warning('[ClientController] No user ID available', tag: 'Client');
        return;
      }
      
      if (refresh) {
        currentPage.value = 1;
        clients.clear();
      }
      
      // Build base query
      var query = _supabase
          .from('client_relationships')
          .select('''
            *,
            client:users!client_relationships_client_id_fkey(
              id,
              full_name,
              email,
              phone,
              avatar_url
            ),
            orders:orders(
              id,
              status,
              amount,
              created_at
            )
          ''')
          .eq('provider_id', userId)
          .order('last_contact_date', ascending: false)
          .range((currentPage.value - 1) * pageSize, currentPage.value * pageSize - 1);
      
      // Apply category filter
      if (selectedCategory.value != 'all') {
        query = _supabase
            .from('client_relationships')
            .select('''
              *,
              client:users!client_relationships_client_id_fkey(
                id,
                full_name,
                email,
                phone,
                avatar_url
              ),
              orders:orders(
                id,
                status,
                amount,
                created_at
              )
            ''')
            .eq('provider_id', userId)
            .eq('relationship_type', selectedCategory.value)
            .order('last_contact_date', ascending: false)
            .range((currentPage.value - 1) * pageSize, currentPage.value * pageSize - 1);
      }
      
      // Apply search filter
      if (searchQuery.value.isNotEmpty) {
        query = _supabase
            .from('client_relationships')
            .select('''
              *,
              client:users!client_relationships_client_id_fkey(
                id,
                full_name,
                email,
                phone,
                avatar_url
              ),
              orders:orders(
                id,
                status,
                amount,
                created_at
              )
            ''')
            .eq('provider_id', userId)
            .or('client.full_name.ilike.%${searchQuery.value}%,client.email.ilike.%${searchQuery.value}%')
            .order('last_contact_date', ascending: false)
            .range((currentPage.value - 1) * pageSize, currentPage.value * pageSize - 1);
      }
      
      final response = await query;
      
      if (refresh) {
        clients.value = List<Map<String, dynamic>>.from(response);
      } else {
        clients.addAll(List<Map<String, dynamic>>.from(response));
      }
      
      // Check if there's more data
      hasMoreData.value = response.length == pageSize;
      currentPage.value++;
      
      AppLogger.info('[ClientController] Loaded ${clients.length} clients', tag: 'Client');
      
    } catch (e) {
      AppLogger.error('[ClientController] Error loading clients: $e', tag: 'Client');
      Get.snackbar(
        'Error',
        'Failed to load clients. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Add new client relationship
  Future<void> addClient(String clientId, String relationshipType, String notes) async {
    try {
      isLoading.value = true;
      
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        AppLogger.warning('[ClientController] No user ID available', tag: 'Client');
        return;
      }
      
      await _supabase
          .from('client_relationships')
          .insert({
            'provider_id': userId,
            'client_id': clientId,
            'relationship_type': relationshipType,
            'notes': notes,
            'last_contact_date': DateTime.now().toIso8601String(),
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });
      
      // Refresh clients list
      await loadClients(refresh: true);
      
      Get.snackbar(
        'Success',
        'Client added successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      AppLogger.info('[ClientController] Client $clientId added', tag: 'Client');
      
    } catch (e) {
      AppLogger.error('[ClientController] Error adding client: $e', tag: 'Client');
      Get.snackbar(
        'Error',
        'Failed to add client. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Update client relationship
  Future<void> updateClient(String relationshipId, String relationshipType, String notes) async {
    try {
      isLoading.value = true;
      
      await _supabase
          .from('client_relationships')
          .update({
            'relationship_type': relationshipType,
            'notes': notes,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', relationshipId);
      
      // Refresh clients list
      await loadClients(refresh: true);
      
      Get.snackbar(
        'Success',
        'Client updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      AppLogger.info('[ClientController] Client relationship $relationshipId updated', tag: 'Client');
      
    } catch (e) {
      AppLogger.error('[ClientController] Error updating client: $e', tag: 'Client');
      Get.snackbar(
        'Error',
        'Failed to update client. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Add communication record
  Future<void> addCommunication(String clientId, String communicationType, String content) async {
    try {
      isLoading.value = true;
      
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        AppLogger.warning('[ClientController] No user ID available', tag: 'Client');
        return;
      }
      
      await _supabase
          .from('client_communications')
          .insert({
            'provider_id': userId,
            'client_id': clientId,
            'communication_type': communicationType,
            'content': content,
            'communication_date': DateTime.now().toIso8601String(),
            'created_at': DateTime.now().toIso8601String(),
          });
      
      // Update last contact date
      await _supabase
          .from('client_relationships')
          .update({
            'last_contact_date': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('provider_id', userId)
          .eq('client_id', clientId);
      
      Get.snackbar(
        'Success',
        'Communication record added successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      AppLogger.info('[ClientController] Communication added for client $clientId', tag: 'Client');
      
    } catch (e) {
      AppLogger.error('[ClientController] Error adding communication: $e', tag: 'Client');
      Get.snackbar(
        'Error',
        'Failed to add communication record. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Get client communications
  Future<List<Map<String, dynamic>>> getClientCommunications(String clientId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        AppLogger.warning('[ClientController] No user ID available', tag: 'Client');
        return [];
      }
      
      final response = await _supabase
          .from('client_communications')
          .select('*')
          .eq('provider_id', userId)
          .eq('client_id', clientId)
          .order('communication_date', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
      
    } catch (e) {
      AppLogger.error('[ClientController] Error getting communications: $e', tag: 'Client');
      return [];
    }
  }
  
  /// Get client statistics
  Future<Map<String, dynamic>> getClientStatistics() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        AppLogger.warning('[ClientController] No user ID available', tag: 'Client');
        return {};
      }
      
      final response = await _supabase
          .from('client_relationships')
          .select('relationship_type')
          .eq('provider_id', userId);
      
      final Map<String, int> stats = {
        'total': response.length,
        'served': 0,
        'in_negotiation': 0,
        'potential': 0,
      };
      
      for (final relationship in response) {
        final type = relationship['relationship_type'] as String;
        if (stats.containsKey(type)) {
          stats[type] = (stats[type] ?? 0) + 1;
        }
      }
      
      return stats;
      
    } catch (e) {
      AppLogger.error('[ClientController] Error getting statistics: $e', tag: 'Client');
      return {};
    }
  }
  
  /// Filter clients by category
  void filterByCategory(String category) {
    selectedCategory.value = category;
    loadClients(refresh: true);
  }
  
  /// Search clients
  void searchClients(String query) {
    searchQuery.value = query;
    loadClients(refresh: true);
  }
  
  /// Get category display text
  String getCategoryDisplayText(String category) {
    switch (category) {
      case 'served':
        return 'Served';
      case 'in_negotiation':
        return 'In Negotiation';
      case 'potential':
        return 'Potential';
      default:
        return 'All';
    }
  }
  
  /// Get category color
  int getCategoryColor(String category) {
    switch (category) {
      case 'served':
        return 0xFF4CAF50; // Green
      case 'in_negotiation':
        return 0xFFFFA500; // Orange
      case 'potential':
        return 0xFF2196F3; // Blue
      default:
        return 0xFF9E9E9E; // Grey
    }
  }
  
  /// Get client name
  String getClientName(Map<String, dynamic> client) {
    final clientData = client['client'] as Map<String, dynamic>?;
    return clientData?['full_name'] ?? 'Unknown Client';
  }
  
  /// Get client email
  String getClientEmail(Map<String, dynamic> client) {
    final clientData = client['client'] as Map<String, dynamic>?;
    return clientData?['email'] ?? 'No email';
  }
  
  /// Get client phone
  String getClientPhone(Map<String, dynamic> client) {
    final clientData = client['client'] as Map<String, dynamic>?;
    return clientData?['phone'] ?? 'No phone';
  }
  
  /// Get total orders for client
  int getTotalOrders(Map<String, dynamic> client) {
    final orders = client['orders'] as List<dynamic>?;
    return orders?.length ?? 0;
  }
  
  /// Get total amount for client
  double getTotalAmount(Map<String, dynamic> client) {
    final orders = client['orders'] as List<dynamic>?;
    if (orders == null) return 0.0;
    
    double total = 0.0;
    for (final order in orders) {
      if (order['amount'] != null) {
        total += (order['amount'] is int ? order['amount'].toDouble() : order['amount']);
      }
    }
    return total;
  }
  
  /// Format price
  String formatPrice(dynamic price) {
    if (price == null) return '\$0.00';
    final double amount = price is int ? price.toDouble() : price;
    return '\$${amount.toStringAsFixed(2)}';
  }
  
  /// Format date time
  String formatDateTime(String? dateTime) {
    if (dateTime == null) return 'N/A';
    try {
      final DateTime dt = DateTime.parse(dateTime);
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Invalid Date';
    }
  }
  
  /// Refresh clients
  Future<void> refreshClients() async {
    await loadClients(refresh: true);
  }
} 