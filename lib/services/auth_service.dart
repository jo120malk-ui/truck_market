import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthService {
  final _supabase = Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;
  bool get isLoggedIn => currentUser != null;

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  Future<UserModel?> getCurrentUserProfile() async {
    final user = currentUser;
    if (user == null) return null;
    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();
      return UserModel.fromMap(data);
    } catch (e) {
      return null;
    }
  }

  Future<String?> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String userType,
    String? city,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      if (response.user != null) {
        await _supabase.from('profiles').upsert({
          'id': response.user!.id,
          'email': email,
          'name': name,
          'phone': phone,
          'user_type': userType,
          'city': city,
        });
        return null; // Success
      }
      return 'فشل إنشاء الحساب';
    } on AuthException catch (e) {
      return _translateAuthError(e.message);
    } catch (e) {
      return 'حدث خطأ غير متوقع';
    }
  }

  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return null; // Success
    } on AuthException catch (e) {
      return _translateAuthError(e.message);
    } catch (e) {
      return 'حدث خطأ غير متوقع';
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  String _translateAuthError(String error) {
    if (error.contains('Invalid login credentials')) return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
    if (error.contains('Email already registered')) return 'البريد الإلكتروني مسجل مسبقاً';
    if (error.contains('Password should be at least')) return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    if (error.contains('Unable to validate email')) return 'البريد الإلكتروني غير صالح';
    return error;
  }
}
