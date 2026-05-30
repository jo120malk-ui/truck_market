import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/truck_listing.dart';

class ListingService {
  final _supabase = Supabase.instance.client;

  Future<List<TruckListing>> getAllListings({
    String? truckType,
    String? city,
    String? condition,
    double? minPrice,
    double? maxPrice,
    String? searchQuery,
  }) async {
    var query = _supabase
        .from('listings')
        .select('*, profiles(name, phone)')
        .eq('is_active', true)
        .order('created_at', ascending: false);

    final data = await query;
    final listings = (data as List).map((e) => TruckListing.fromMap(e)).toList();

    return listings.where((l) {
      bool match = true;
      if (truckType != null && truckType.isNotEmpty) match = match && l.truckType == truckType;
      if (city != null && city.isNotEmpty) match = match && l.city == city;
      if (condition != null && condition.isNotEmpty) match = match && l.condition == condition;
      if (minPrice != null) match = match && l.price >= minPrice;
      if (maxPrice != null) match = match && l.price <= maxPrice;
      if (searchQuery != null && searchQuery.isNotEmpty) {
        match = match && (
          l.title.contains(searchQuery) ||
          l.brand.contains(searchQuery) ||
          l.description.contains(searchQuery)
        );
      }
      return match;
    }).toList();
  }

  Future<List<TruckListing>> getMyListings(String sellerId) async {
    final data = await _supabase
        .from('listings')
        .select('*, profiles(name, phone)')
        .eq('seller_id', sellerId)
        .order('created_at', ascending: false);
    return (data as List).map((e) => TruckListing.fromMap(e)).toList();
  }

  Future<TruckListing?> getListingById(String id) async {
    try {
      final data = await _supabase
          .from('listings')
          .select('*, profiles(name, phone)')
          .eq('id', id)
          .single();
      return TruckListing.fromMap(data);
    } catch (e) {
      return null;
    }
  }

  Future<String?> createListing({
    required Map<String, dynamic> listingData,
    required List<File> images,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return 'يجب تسجيل الدخول أولاً';

      // Upload images
      List<String> imageUrls = [];
      for (int i = 0; i < images.length; i++) {
        final file = images[i];
        final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        await _supabase.storage.from('truck-images').upload(fileName, file);
        final url = _supabase.storage.from('truck-images').getPublicUrl(fileName);
        imageUrls.add(url);
      }

      listingData['seller_id'] = userId;
      listingData['image_urls'] = imageUrls;

      await _supabase.from('listings').insert(listingData);
      return null; // Success
    } catch (e) {
      return 'فشل نشر الإعلان: ${e.toString()}';
    }
  }

  Future<String?> deleteListing(String listingId) async {
    try {
      await _supabase.from('listings').delete().eq('id', listingId);
      return null;
    } catch (e) {
      return 'فشل حذف الإعلان';
    }
  }

  Future<String?> toggleListingStatus(String listingId, bool isActive) async {
    try {
      await _supabase
          .from('listings')
          .update({'is_active': isActive})
          .eq('id', listingId);
      return null;
    } catch (e) {
      return 'فشل تحديث الإعلان';
    }
  }
}
