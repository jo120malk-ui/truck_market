import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/truck_listing.dart';
import '../../utils/app_theme.dart';
import 'package:intl/intl.dart';

class ListingDetailScreen extends StatefulWidget {
  final TruckListing listing;
  const ListingDetailScreen({super.key, required this.listing});

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  int _currentImage = 0;

  void _callSeller() async {
    final phone = widget.listing.sellerPhone;
    if (phone == null) return;
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  void _whatsappSeller() async {
    final phone = widget.listing.sellerPhone?.replaceAll('+', '').replaceAll(' ', '');
    if (phone == null) return;
    final msg = Uri.encodeComponent('مرحبا، رأيت إعلانك على سوق الشاحنات عن ${widget.listing.title}');
    final uri = Uri.parse('https://wa.me/$phone?text=$msg');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.listing;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: CustomScrollView(
          slivers: [
            // Image gallery
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  children: [
                    PageView.builder(
                      itemCount: l.imageUrls.isEmpty ? 1 : l.imageUrls.length,
                      onPageChanged: (i) => setState(() => _currentImage = i),
                      itemBuilder: (_, i) => l.imageUrls.isEmpty
                          ? Container(color: Colors.grey.shade200, child: const Icon(Icons.local_shipping, size: 80, color: Colors.grey))
                          : CachedNetworkImage(imageUrl: l.imageUrls[i], fit: BoxFit.cover),
                    ),
                    if (l.imageUrls.length > 1)
                      Positioned(
                        bottom: 10,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(l.imageUrls.length, (i) => Container(
                            width: _currentImage == i ? 20 : 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              color: _currentImage == i ? AppTheme.secondaryColor : Colors.white60,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          )),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title & Price
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: Text(l.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Cairo'))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: AppTheme.primaryColor, borderRadius: BorderRadius.circular(20)),
                          child: Text(l.formattedPrice, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(l.city, style: const TextStyle(color: Colors.grey, fontFamily: 'Cairo')),
                      const SizedBox(width: 16),
                      const Icon(Icons.access_time, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(DateFormat('dd/MM/yyyy').format(l.createdAt), style: const TextStyle(color: Colors.grey, fontFamily: 'Cairo')),
                    ]),
                    const SizedBox(height: 16),
                    // Specs
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('تفاصيل الشاحنة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                            const Divider(),
                            _specRow(Icons.local_shipping, 'النوع', l.truckType),
                            _specRow(Icons.branding_watermark, 'الماركة', l.brand),
                            _specRow(Icons.directions_car, 'الموديل', l.model),
                            _specRow(Icons.calendar_today, 'سنة الصنع', '${l.year}'),
                            _specRow(Icons.speed, 'المسافة المقطوعة', l.mileage != null ? '${l.mileage!.toStringAsFixed(0)} كم' : 'غير محدد'),
                            _specRow(Icons.star, 'الحالة', l.conditionAr),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Description
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('وصف الإعلان', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                            const Divider(),
                            Text(l.description, style: const TextStyle(fontFamily: 'Cairo', height: 1.7)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Seller info
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('معلومات البائع', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                            const Divider(),
                            Row(children: [
                              const CircleAvatar(backgroundColor: AppTheme.primaryColor, child: Icon(Icons.person, color: Colors.white)),
                              const SizedBox(width: 12),
                              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(l.sellerName, style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                                if (l.sellerPhone != null) Text(l.sellerPhone!, style: const TextStyle(color: Colors.grey, fontFamily: 'Cairo')),
                              ]),
                            ]),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
        // Contact buttons
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, -4))],
          ),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _callSeller,
                  icon: const Icon(Icons.call, color: Colors.white),
                  label: const Text('اتصال', style: TextStyle(fontFamily: 'Cairo', color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successColor),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _whatsappSeller,
                  icon: const Icon(Icons.chat, color: Colors.white),
                  label: const Text('واتساب', style: TextStyle(fontFamily: 'Cairo', color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _specRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Icon(icon, size: 18, color: AppTheme.primaryColor),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(color: Colors.grey, fontFamily: 'Cairo')),
        Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Cairo'))),
      ]),
    );
  }
}
