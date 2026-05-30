import 'package:flutter/material.dart';
import '../../models/truck_listing.dart';
import '../../services/listing_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/listing_card.dart';
import 'listing_detail_screen.dart';

class ListingsScreen extends StatefulWidget {
  const ListingsScreen({super.key});

  @override
  State<ListingsScreen> createState() => _ListingsScreenState();
}

class _ListingsScreenState extends State<ListingsScreen> {
  final _listingService = ListingService();
  final _searchCtrl = TextEditingController();
  List<TruckListing> _listings = [];
  bool _loading = true;
  String? _selectedType;
  String? _selectedCity;
  String? _selectedCondition;

  @override
  void initState() {
    super.initState();
    _loadListings();
  }

  Future<void> _loadListings() async {
    setState(() => _loading = true);
    final listings = await _listingService.getAllListings(
      truckType: _selectedType,
      city: _selectedCity,
      condition: _selectedCondition,
      searchQuery: _searchCtrl.text.trim(),
    );
    if (mounted) setState(() { _listings = listings; _loading = false; });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('فلترة النتائج', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: 'نوع الشاحنة'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('الكل', style: TextStyle(fontFamily: 'Cairo'))),
                  ...truckTypes.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontFamily: 'Cairo')))),
                ],
                onChanged: (v) => setState(() => _selectedType = v),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedCity,
                decoration: const InputDecoration(labelText: 'المدينة'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('الكل', style: TextStyle(fontFamily: 'Cairo'))),
                  ...saudiCities.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontFamily: 'Cairo')))),
                ],
                onChanged: (v) => setState(() => _selectedCity = v),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedCondition,
                decoration: const InputDecoration(labelText: 'الحالة'),
                items: const [
                  DropdownMenuItem(value: null, child: Text('الكل', style: TextStyle(fontFamily: 'Cairo'))),
                  DropdownMenuItem(value: 'new', child: Text('جديد', style: TextStyle(fontFamily: 'Cairo'))),
                  DropdownMenuItem(value: 'used', child: Text('مستعمل', style: TextStyle(fontFamily: 'Cairo'))),
                  DropdownMenuItem(value: 'needs_repair', child: Text('يحتاج إصلاح', style: TextStyle(fontFamily: 'Cairo'))),
                ],
                onChanged: (v) => setState(() => _selectedCondition = v),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() { _selectedType = null; _selectedCity = null; _selectedCondition = null; });
                        Navigator.pop(ctx);
                        _loadListings();
                      },
                      child: const Text('مسح الفلتر', style: TextStyle(fontFamily: 'Cairo')),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () { Navigator.pop(ctx); _loadListings(); },
                      child: const Text('تطبيق', style: TextStyle(fontFamily: 'Cairo')),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: const Text('سوق الشاحنات 🚚'),
          actions: [
            IconButton(icon: const Icon(Icons.tune), onPressed: _showFilters),
          ],
        ),
        body: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: 'ابحث عن شاحنة...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchCtrl.clear(); _loadListings(); })
                      : null,
                ),
                onSubmitted: (_) => _loadListings(),
                onChanged: (v) => setState(() {}),
              ),
            ),
            // Filter chips
            if (_selectedType != null || _selectedCity != null || _selectedCondition != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Wrap(
                  spacing: 8,
                  children: [
                    if (_selectedType != null) _filterChip(_selectedType!, () => setState(() { _selectedType = null; _loadListings(); })),
                    if (_selectedCity != null) _filterChip(_selectedCity!, () => setState(() { _selectedCity = null; _loadListings(); })),
                    if (_selectedCondition != null) _filterChip(
                      _selectedCondition == 'new' ? 'جديد' : _selectedCondition == 'used' ? 'مستعمل' : 'يحتاج إصلاح',
                      () => setState(() { _selectedCondition = null; _loadListings(); }),
                    ),
                  ],
                ),
              ),
            // Listings
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _listings.isEmpty
                      ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.local_shipping_outlined, size: 80, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('لا توجد إعلانات', style: TextStyle(fontSize: 18, color: Colors.grey, fontFamily: 'Cairo')),
                        ]))
                      : RefreshIndicator(
                          onRefresh: _loadListings,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: _listings.length,
                            itemBuilder: (_, i) => ListingCard(
                              listing: _listings[i],
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => ListingDetailScreen(listing: _listings[i])),
                              ),
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, VoidCallback onRemove) {
    return Chip(
      label: Text(label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12)),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: onRemove,
      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
      deleteIconColor: AppTheme.primaryColor,
    );
  }
}
