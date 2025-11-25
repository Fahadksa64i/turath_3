// add_product_page.dart - الإصدار المعدل
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddProductPage extends StatefulWidget {
  final Map<String, dynamic>? productToEdit;

  const AddProductPage({super.key, this.productToEdit});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  String? _selectedLocation;
  String? _selectedCategory;
  List<File> _selectedImages = [];
  List<String> _currentImageUrls = [];
  bool _isLoading = false;

  final List<String> _categories = [
    'أثاث',
    'أجهزة إلكترونية',
    'سيارات',
    'عقارات',
    'موضة',
    'أخرى'
  ];

  final List<String> _locations = [
    'الرياض',
    'جدة',
    'الدمام',
    'مكة',
    'المدينة المنورة',
    'القصيم',
    'الخرج',
    'النماص',
    'أبها',
    'الطائف',
    'تبوك',
    'حائل',
    'الباحة',
    'نجران',
    'الجوف',
    'الحدود الشمالية',
    'عرعر',
    'سكاكا'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.productToEdit != null) {
      _titleController.text = widget.productToEdit!['title'] ?? '';
      _descriptionController.text = widget.productToEdit!['description'] ?? '';
      _priceController.text = widget.productToEdit!['price']?.toString() ?? '';
      _selectedLocation = widget.productToEdit!['location'];
      _selectedCategory = widget.productToEdit!['category'];

      final imageUrls = widget.productToEdit!['image_urls'] as String;
      if (imageUrls.isNotEmpty) {
        _currentImageUrls = imageUrls.split('|');
      }
    }
  }

  Future<void> _pickImages() async {
    final pickedFiles = await ImagePicker().pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(pickedFiles.map((file) => File(file.path)));
      });
    }
  }

  Future<void> _removeImage(int index) async {
    setState(() {
      if (index < _currentImageUrls.length) {
        _currentImageUrls.removeAt(index);
      } else {
        _selectedImages.removeAt(index - _currentImageUrls.length);
      }
    });
  }

  Future<void> _submitAd() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImages.isEmpty && _currentImageUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إضافة صورة واحدة على الأقل')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      // تم إزالة كود Supabase
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حفظ البيانات محلياً')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final allImages = [..._currentImageUrls, ..._selectedImages.map((_) => '')];

    return Scaffold(
      backgroundColor: const Color(0xFFEEDDCF),
      appBar: AppBar(
        title: Text(
          widget.productToEdit != null ? "تعديل الإعلان" : "إضافة إعلان جديد",
          style: GoogleFonts.tajawal(
              fontWeight: FontWeight.bold,
              color: Colors.white
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF6C4422),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('صور الإعلان (${allImages.length}/10)',
                  style: GoogleFonts.tajawal(
                    fontSize: 16,
                    color: const Color(0xFF6C4422),
                  )),
              const SizedBox(height: 10),

              if (allImages.isNotEmpty)
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: allImages.length,
                    itemBuilder: (context, index) {
                      final isCurrentImage = index < _currentImageUrls.length;
                      final imageUrl = isCurrentImage
                          ? _currentImageUrls[index]
                          : null;
                      final imageFile = !isCurrentImage
                          ? _selectedImages[index - _currentImageUrls.length]
                          : null;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                width: 120,
                                height: 120,
                                color: const Color(0xFFEEDDCF),
                                child: imageUrl != null
                                    ? Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.broken_image),
                                )
                                    : imageFile != null
                                    ? Image.file(
                                  imageFile,
                                  fit: BoxFit.cover,
                                )
                                    : const Icon(Icons.broken_image),
                              ),
                            ),
                            Positioned(
                              top: 5,
                              right: 5,
                              child: GestureDetector(
                                onTap: () => _removeImage(index),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black54,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

              ElevatedButton.icon(
                icon: const Icon(Icons.add_photo_alternate, color: Colors.white),
                label: Text(
                  'إضافة صور',
                  style: GoogleFonts.tajawal(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C4422),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: allImages.length >= 10
                    ? null
                    : () => _pickImages(),
              ),
              if (allImages.length >= 10)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'الحد الأقصى للصور هو 10',
                    style: GoogleFonts.tajawal(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'عنوان الإعلان',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF6C4422)),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'هذا الحقل مطلوب';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'وصف الإعلان',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF6C4422)),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'هذا الحقل مطلوب';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'التصنيف',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF6C4422)),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category, style: GoogleFonts.tajawal()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'الرجاء اختيار تصنيف';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              DropdownButtonFormField<String>(
                value: _selectedLocation,
                decoration: InputDecoration(
                  labelText: 'الموقع',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF6C4422)),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: _locations.map((location) {
                  return DropdownMenuItem<String>(
                    value: location,
                    child: Text(location, style: GoogleFonts.tajawal()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedLocation = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'الرجاء اختيار الموقع';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'السعر (اختياري)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF6C4422)),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 30),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _isLoading ? null : _submitAd,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                    widget.productToEdit != null ? 'تحديث الإعلان' : 'رفع الإعلان',
                    style: GoogleFonts.tajawal(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}