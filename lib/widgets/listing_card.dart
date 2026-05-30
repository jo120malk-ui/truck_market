import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/truck_listing.dart';
import '../utils/app_theme.dart';
import 'package:timeago/timeago.dart' as timeago;

class ListingCard extends StatelessWidget {
  final TruckListing listing;
  final VoidCallback onTap;
  final bool showActions;
  final VoidCallback? onDelete;

  const ListingCard({
    super.key,
    required this.listing,
    required this.onTap,
    this.showActions = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: SizedBox(
                height: 180,
                width: double.infinity,
                child: listing.imageUrls.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: listing.imageUrls.first,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(color: Colors.grey.shade200, child: const Icon(Icons.local_shipping, size: 60, color: Colors.grey)),
                        errorWidget: (_, __, ___) => Container(color: Colors.grey.shade200, child: const Icon(Icons.local_shipping, size: 60, color: Colors.grey)),
                      )
                    : Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.local_shipping, size: 60, color: Colors.grey),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          listing.title,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        listing.formattedPrice,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.secondaryColor, fontFamily: 'Cairo'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Tags
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _tag(listing.truckType, Icons.local_shipping, AppTheme.primaryColor),
                      _tag(listing.conditionAr, Icons.star, listing.condition == 'new' ? AppTheme.successColor : Colors.orange),
                      _tag(listing.city, Icons.location_on, Colors.grey),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Meta
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(listing.sellerName, style: const TextStyle(color: Colors.grey, fontSize: 12, fontFamily: 'Cairo')),
                      const Spacer(),
                      const Icon(Icons.access_time, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(timeago.format(listing.createdAt, locale: 'ar'), style: const TextStyle(color: Colors.grey, fontSize: 12, fontFamily: 'Cairo')),
                    ],
                  ),
                  if (showActions && onDelete != null) ...[
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: onDelete,
                          icon: const Icon(Icons.delete_outline, color: AppTheme.errorColor, size: 18),
                          label: const Text('حذف', style: TextStyle(color: AppTheme.errorColor, fontFamily: 'Cairo')),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tag(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, color: color, fontFamily: 'Cairo', fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
