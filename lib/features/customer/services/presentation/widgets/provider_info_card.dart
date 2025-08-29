import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import '../../../../core/utils/app_logger.dart';
import '../../../domain/entities/provider_profile.dart';
import 'service_detail_card.dart';

class ProviderInfoCard extends StatelessWidget {
  final ProviderProfile provider;
  final VoidCallback? onContact;
  final VoidCallback? onViewProfile;

  const ProviderInfoCard({
    super.key,
    required this.provider,
    this.onContact,
    this.onViewProfile,
  });

  @override
  Widget build(BuildContext context) {
    return ServiceDetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildStats(),
          const SizedBox(height: 16),
          _buildContactInfo(),
          const SizedBox(height: 16),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage:
              provider.avatar != null && provider.avatar!.isNotEmpty
                  ? NetworkImage(provider.avatar!)
                  : null,
          child: provider.avatar == null || provider.avatar!.isEmpty
              ? Text(
                  provider.name.isNotEmpty
                      ? provider.name[0].toUpperCase()
                      : 'P',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                )
              : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      provider.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (provider.isVerified)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Verified',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              if (provider.rating != null)
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.orange, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      provider.rating!.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${provider.reviewCount ?? 0} reviews)',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 4),
              if (provider.description != null &&
                  provider.description!.isNotEmpty)
                Text(
                  provider.description!,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            icon: Icons.check_circle,
            label: 'Completed',
            value: '${provider.completedOrders ?? 0}',
            color: Colors.green,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            icon: Icons.star,
            label: 'Rating',
            value: provider.rating?.toStringAsFixed(1) ?? 'N/A',
            color: Colors.orange,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            icon: Icons.verified_user,
            label: 'Status',
            value: provider.isVerified ? 'Verified' : 'Pending',
            color: provider.isVerified ? Colors.blue : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildContactInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contact Information',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        if (provider.phone != null && provider.phone!.isNotEmpty)
          _buildContactItem(
            icon: Icons.phone,
            label: 'Phone',
            value: provider.phone!,
            onTap: () => _makePhoneCall(provider.phone!),
          ),
        if (provider.email != null && provider.email!.isNotEmpty)
          _buildContactItem(
            icon: Icons.email,
            label: 'Email',
            value: provider.email!,
            onTap: () => _sendEmail(provider.email!),
          ),
        if (provider.address != null && provider.address!.isNotEmpty)
          _buildContactItem(
            icon: Icons.location_on,
            label: 'Address',
            value: provider.address!,
            onTap: () => _openMap(provider.address!),
          ),
      ],
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null)
            IconButton(
              icon: const Icon(Icons.open_in_new, size: 20),
              onPressed: onTap,
              tooltip: 'Open $label',
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onContact,
            icon: const Icon(Icons.message),
            label: const Text('Contact'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onViewProfile,
            icon: const Icon(Icons.person),
            label: const Text('View Profile'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  void _makePhoneCall(String phone) {
    // AppLogger.info('Making phone call to: $phone');
    Get.snackbar(
      'Phone Call',
      'Calling $phone...',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _sendEmail(String email) {
    // AppLogger.info('Sending email to: $email');
    Get.snackbar(
      'Email',
      'Opening email app for $email...',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _openMap(String address) {
    // AppLogger.info('Opening map for address: $address');
    Get.snackbar(
      'Map',
      'Opening map for $address...',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
