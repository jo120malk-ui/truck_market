import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/truck_listing.dart';
import '../../services/listing_service.dart';
import '../../utils/app_theme.dart';

class AddListingScreen extends StatefulWidget {
  const AddListingScreen({super.key});

  @override
  State<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends State<AddListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _mileageCtrl = TextEditingController();
  final _listingService = ListingService();
  final _picker = ImagePicker();

  String? _selectedType;
  String? _selectedCity;
  String _condition = 'used';
  List<File> _images = [];
  bool _loading = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _brandCtrl.dispose();
    _modelCtrl.dispose();
    _yearCtrl.dispose();
    _mileageCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 70);
    if (picked.isNotEmpty) {
      setState(() {
        _images = [..._images, ...picked.map((x) => File(x.path))].take(6).toList();
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختر نوع الشاحنة'), backgroundColor: AppTheme.errorColor),
      );
      return;
    }
    if (_selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختر المدينة'), backgroundColor: AppTheme.errorColor),
      );
      return;
    }
    setState(() => _loading = true);
    final data = {
      'title': _titleCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'price': double.parse(_priceCtrl.text),
      'truck_type': _selectedType,
      'brand': _brandCtrl.text.trim(),
      'model': _modelCtrl.text.trim(),
      'year': int.parse(_yearCtrl.text),
      'mileage': _mileageCtrl.text.isNotEmpty ? double.parse(_mileageCtrl.text) : null,
      'condition': _condition,
      'city': _selectedCity,
      'is_active': true,
    };
    final error = await _listingService.createListing(listingData: data, images: _images);
    if (!mounted) return;
    setState(() => _loading = false);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: AppTheme.errorColor));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم نشر الإعلان بنجاح! ✅'), backgroundColor: AppTheme.successColor),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(title: const Text('إضافة إعلان جديد')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Images
                const Text('صور الشاحنة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                const SizedBox(height: 8),
                SizedBox(
                  height: 110,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      GestureDetector(
                        onTap: _pickImages,
                        child: Container(
                          width: 100,
                          height: 100,
                          margin: const EdgeInsets.only(left: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                          ),
                          child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Icon(Icons.add_photo_alternate_outlined, size: 32, color: AppTheme.primaryColor),
                            SizedBox(height: 4),
                            Text('إضافة صور', style: TextStyle(fontSize: 11, fontFamily: 'Cairo', color: AppTheme.primaryColor)),
                          ]),
                        ),
                      ),
                      ..._images.asMap().entries.map((e) => Stack(
                        children: [
                          Container(
                            width: 100, height: 100,
                            margin: const EdgeInsets.only(left: 8),
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), image: DecorationImage(image: FileImage(e.value), fit: BoxFit.cover)),
                          ),
                          Positioned(
                            top: 2, right: 2,
                            child: GestureDetector(
                              onTap: () => setState(() => _images.removeAt(e.key)),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                child: const Icon(Icons.close, size: 14, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      )),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Form fields
                Card(child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(children: [
                    TextFormField(
                      controller: _titleCtrl,
                      decoration: const InputDecoration(labelText: 'عنوان الإعلان *', prefixIcon: Icon(Icons.title)),
                      validator: (v) => v?.isEmpty == true ? 'ادخل عنوان الإعلان' : null,
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: const InputDecoration(labelText: 'نوع الشاحنة *', prefixIcon: Icon(Icons.local_shipping_outlined)),
                      items: truckTypes.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontFamily: 'Cairo')))).toList(),
                      onChanged: (v) => setState(() => _selectedType = v),
                    ),
                    const SizedBox(height: 14),
                    Row(children: [
                      Expanded(child: TextFormField(
                        controller: _brandCtrl,
                        decoration: const InputDecoration(labelText: 'الماركة *'),
                        validator: (v) => v?.isEmpty == true ? 'مطلوب' : null,
                      )),
                      const SizedBox(width: 10),
                      Expanded(child: TextFormField(
                        controller: _modelCtrl,
                        decoration: const InputDecoration(labelText: 'الموديل *'),
                        validator: (v) => v?.isEmpty == true ? 'مطلوب' : null,
                      )),
                    ]),
                    const SizedBox(height: 14),
                    Row(children: [
                      Expanded(child: TextFormField(
                        controller: _yearCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'سنة الصنع *'),
                        validator: (v) {
                          if (v?.isEmpty == true) return 'مطلوب';
                          final y = int.tryParse(v!);
                          if (y == null || y < 1980 || y > 2026) return 'سنة غير صالحة';
                          return null;
                        },
                      )),
                      const SizedBox(width: 10),
                      Expanded(child: TextFormField(
                        controller: _mileageCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'الكيلومترات'),
                      )),
                    ]),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _priceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'السعر (ريال) *', prefixIcon: Icon(Icons.monetization_on_outlined)),
                      validator: (v) {
                        if (v?.isEmpty == true) return 'ادخل السعر';
                        if (double.tryParse(v!) == null) return 'سعر غير صالح';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: _selectedCity,
                      decoration: const InputDecoration(labelText: 'المدينة *', prefixIcon: Icon(Icons.location_on_outlined)),
                      items: saudiCities.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontFamily: 'Cairo')))).toList(),
                      onChanged: (v) => setState(() => _selectedCity = v),
                    ),
                    const SizedBox(height: 14),
                    // Condition
                    const Align(alignment: Alignment.centerRight, child: Text('حالة الشاحنة', style: TextStyle(fontFamily: 'Cairo', color: Colors.grey, fontSize: 12))),
                    const SizedBox(height: 6),
                    Row(children: [
                      _conditionBtn('new', 'جديد'),
                      const SizedBox(width: 8),
                      _conditionBtn('used', 'مستعمل'),
                      const SizedBox(width: 8),
                      _conditionBtn('needs_repair', 'يحتاج إصلاح'),
                    ]),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _descCtrl,
                      maxLines: 4,
                      decoration: const InputDecoration(labelText: 'وصف الإعلان *', alignLabelWithHint: true),
                      validator: (v) => v?.isEmpty == true ? 'ادخل وصف الإعلان' : null,
                    ),
                  ]),
                )),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : _submit,
                    icon: _loading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.publish, color: Colors.white),
                    label: const Text('نشر الإعلان', style: TextStyle(fontFamily: 'Cairo', fontSize: 18, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _conditionBtn(String value, String label) {
    final selected = _condition == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _condition = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primaryColor : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: selected ? AppTheme.primaryColor : Colors.grey.shade300),
          ),
          alignment: Alignment.center,
          child: Text(label, style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: selected ? Colors.white : Colors.grey, fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
        ),
      ),
    );
  }
}
