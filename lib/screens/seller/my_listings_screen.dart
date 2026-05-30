import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/truck_listing.dart';
import '../../services/listing_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/listing_card.dart';
import '../common/listing_detail_screen.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  final _listingService = ListingService();
  List<TruckListing> _listings = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadListings();
  }

  Future<void> _loadListings() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    setState(() => _loading = true);
    final listings = await _listingService.getMyListings(userId);
    if (mounted) setState(() { _listings = listings; _loading = false; });
  }

  Future<void> _deleteListing(TruckListing listing) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('حذف الإعلان', style: TextStyle(fontFamily: 'Cairo')),
          content: const Text('هل أنت متأكد من حذف هذا الإعلان؟', style: TextStyle(fontFamily: 'Cairo')),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo'))),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
              child: const Text('حذف', style: TextStyle(fontFamily: 'Cairo')),
            ),
          ],
        ),
      ),
    );
    if (confirm != true) return;
    final error = await _listingService.deleteListing(listing.id);
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: AppTheme.errorColor));
    } else {
      _loadListings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(title: const Text('إعلاناتي')),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _listings.isEmpty
                ? Center(
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.post_add, size: 80, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('لم تضف أي إعلان بعد', style: TextStyle(fontSize: 18, color: Colors.grey, fontFamily: 'Cairo')),
                      const SizedBox(height: 8),
                      const Text('اضغط + لإضافة إعلان جديد', style: TextStyle(color: Colors.grey, fontFamily: 'Cairo')),
                    ]),
                  )
                : RefreshIndicator(
                    onRefresh: _loadListings,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _listings.length,
                      itemBuilder: (_, i) {
                        final l = _listings[i];
                        return Dismissible(
                          key: Key(l.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: AppTheme.errorColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.delete, color: Colors.white, size: 32),
                          ),
                          onDismissed: (_) => _deleteListing(l),
                          child: ListingCard(
                            listing: l,
                            showActions: true,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ListingDetailScreen(listing: l))),
                            onDelete: () => _deleteListing(l),
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}
