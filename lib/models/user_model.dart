class UserModel {
  final String id;
  final String email;
  final String name;
  final String phone;
  final String userType; // 'seller' or 'buyer'
  final String? avatarUrl;
  final String? city;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    required this.userType,
    this.avatarUrl,
    this.city,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      userType: map['user_type'] ?? 'buyer',
      avatarUrl: map['avatar_url'],
      city: map['city'],
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'user_type': userType,
      'avatar_url': avatarUrl,
      'city': city,
    };
  }

  bool get isSeller => userType == 'seller';
  bool get isBuyer => userType == 'buyer';
}
