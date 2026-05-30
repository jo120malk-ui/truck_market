class TruckListing {
  final String id;
  final String sellerId;
  final String sellerName;
  final String? sellerPhone;
  final String title;
  final String description;
  final double price;
  final String truckType;
  final String brand;
  final String model;
  final int year;
  final double? mileage;
  final String condition; // new, used, needs_repair
  final String city;
  final List<String> imageUrls;
  final bool isActive;
  final DateTime createdAt;

  TruckListing({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    this.sellerPhone,
    required this.title,
    required this.description,
    required this.price,
    required this.truckType,
    required this.brand,
    required this.model,
    required this.year,
    this.mileage,
    required this.condition,
    required this.city,
    required this.imageUrls,
    required this.isActive,
    required this.createdAt,
  });

  factory TruckListing.fromMap(Map<String, dynamic> map) {
    return TruckListing(
      id: map['id'],
      sellerId: map['seller_id'],
      sellerName: map['profiles']?['name'] ?? 'غير معروف',
      sellerPhone: map['profiles']?['phone'],
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      truckType: map['truck_type'] ?? '',
      brand: map['brand'] ?? '',
      model: map['model'] ?? '',
      year: map['year'] ?? 2000,
      mileage: map['mileage']?.toDouble(),
      condition: map['condition'] ?? 'used',
      city: map['city'] ?? '',
      imageUrls: List<String>.from(map['image_urls'] ?? []),
      isActive: map['is_active'] ?? true,
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'seller_id': sellerId,
      'title': title,
      'description': description,
      'price': price,
      'truck_type': truckType,
      'brand': brand,
      'model': model,
      'year': year,
      'mileage': mileage,
      'condition': condition,
      'city': city,
      'image_urls': imageUrls,
      'is_active': isActive,
    };
  }

  String get conditionAr {
    switch (condition) {
      case 'new': return 'جديد';
      case 'used': return 'مستعمل';
      case 'needs_repair': return 'يحتاج إصلاح';
      default: return condition;
    }
  }

  String get formattedPrice {
    return '${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} ريال';
  }
}

const List<String> truckTypes = [
  'شاحنة نقل',
  'شاحنة قلاب',
  'شاحنة مقطورة',
  'شاحنة تبريد',
  'شاحنة صهريج',
  'شاحنة رافعة',
  'ميني باص',
  'شاحنة خفيفة',
  'شاحنة ثقيلة',
  'أخرى',
];

const List<String> truckBrands = [
  'مرسيدس',
  'فولفو',
  'مان',
  'سكانيا',
  'إيفيكو',
  'DAF',
  'رينو',
  'فورد',
  'تويوتا',
  'ميتسوبيشي',
  'هيونداي',
  'كيا',
  'إيسوزو',
  'أخرى',
];

const List<String> saudiCities = [
  'الرياض',
  'جدة',
  'مكة المكرمة',
  'المدينة المنورة',
  'الدمام',
  'الخبر',
  'تبوك',
  'أبها',
  'بريدة',
  'نجران',
  'حائل',
  'الطائف',
  'الجبيل',
  'ينبع',
  'الأحساء',
  'القطيف',
  'أخرى',
];
