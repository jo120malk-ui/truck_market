-- ========================================
-- سوق الشاحنات - إعداد قاعدة البيانات Supabase
-- نفذ هذه الأوامر في Supabase SQL Editor
-- ========================================

-- 1. جدول بيانات المستخدمين
CREATE TABLE IF NOT EXISTS profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email TEXT NOT NULL,
  name TEXT NOT NULL,
  phone TEXT,
  user_type TEXT NOT NULL CHECK (user_type IN ('seller', 'buyer')),
  avatar_url TEXT,
  city TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. جدول الإعلانات
CREATE TABLE IF NOT EXISTS listings (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  seller_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  price DECIMAL(12,2) NOT NULL,
  truck_type TEXT NOT NULL,
  brand TEXT NOT NULL,
  model TEXT NOT NULL,
  year INTEGER NOT NULL,
  mileage DECIMAL(10,2),
  condition TEXT NOT NULL CHECK (condition IN ('new', 'used', 'needs_repair')),
  city TEXT NOT NULL,
  image_urls TEXT[] DEFAULT '{}',
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. تفعيل Row Level Security
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE listings ENABLE ROW LEVEL SECURITY;

-- 4. سياسات الأمان - profiles
CREATE POLICY "Public profiles are viewable by everyone"
  ON profiles FOR SELECT USING (true);

CREATE POLICY "Users can insert their own profile"
  ON profiles FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE USING (auth.uid() = id);

-- 5. سياسات الأمان - listings
CREATE POLICY "Listings are viewable by everyone"
  ON listings FOR SELECT USING (is_active = true);

CREATE POLICY "Sellers can insert their own listings"
  ON listings FOR INSERT WITH CHECK (
    auth.uid() = seller_id AND
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND user_type = 'seller')
  );

CREATE POLICY "Sellers can update their own listings"
  ON listings FOR UPDATE USING (auth.uid() = seller_id);

CREATE POLICY "Sellers can delete their own listings"
  ON listings FOR DELETE USING (auth.uid() = seller_id);

-- 6. إنشاء Storage Bucket للصور
INSERT INTO storage.buckets (id, name, public)
VALUES ('truck-images', 'truck-images', true)
ON CONFLICT DO NOTHING;

CREATE POLICY "Anyone can view truck images"
  ON storage.objects FOR SELECT USING (bucket_id = 'truck-images');

CREATE POLICY "Authenticated users can upload truck images"
  ON storage.objects FOR INSERT WITH CHECK (
    bucket_id = 'truck-images' AND auth.role() = 'authenticated'
  );

CREATE POLICY "Users can delete own truck images"
  ON storage.objects FOR DELETE USING (
    bucket_id = 'truck-images' AND auth.uid()::text = (storage.foldername(name))[1]
  );

-- 7. Function لتحديث updated_at تلقائياً
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_listings_updated_at
  BEFORE UPDATE ON listings
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 8. بيانات تجريبية اختيارية
-- (لا تنفذ هذا إلا إذا أردت بيانات اختبار)
/*
INSERT INTO listings (seller_id, title, description, price, truck_type, brand, model, year, mileage, condition, city, image_urls) 
VALUES (
  '00000000-0000-0000-0000-000000000000', -- ضع ID مستخدم حقيقي
  'شاحنة مرسيدس 2020 للبيع',
  'شاحنة نقل بحالة ممتازة، صيانة منتظمة، جاهزة للتشغيل',
  180000,
  'شاحنة نقل',
  'مرسيدس',
  'Actros',
  2020,
  120000,
  'used',
  'الرياض',
  ARRAY[]::TEXT[]
);
*/

-- تم الإعداد بنجاح! ✅
SELECT 'قاعدة البيانات جاهزة! 🚚' as message;
