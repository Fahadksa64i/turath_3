import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyProductDetailsPage extends StatefulWidget {
  final Map<String, dynamic> product;
  final VoidCallback onDelete;
  final VoidCallback onUpdate;

  const MyProductDetailsPage({
    super.key,
    required this.product,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  State<MyProductDetailsPage> createState() => _MyProductDetailsPageState();
}

class _MyProductDetailsPageState extends State<MyProductDetailsPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isProcessing = false;
  bool _isFavorite = false;
  bool _isProcessingFavorite = false;
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      final response = await _supabase
          .from('favorites')
          .select()
          .eq('user_id', user.id)
          .eq('product_id', widget.product['id'])
          .maybeSingle();

      setState(() {
        _isFavorite = response != null;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isProcessingFavorite) return;

    setState(() => _isProcessingFavorite = true);
    try {
      final user = _supabase.auth.currentUser!;

      if (!_isFavorite) {
        await _supabase.from('favorites').insert({
          'user_id': user.id,
          'product_id': widget.product['id'],
          'created_at': DateTime.now().toIso8601String(),
        });
      } else {
        await _supabase
            .from('favorites')
            .delete()
            .eq('user_id', user.id)
            .eq('product_id', widget.product['id']);
      }

      setState(() => _isFavorite = !_isFavorite);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: ${e.toString()}')),
      );
    } finally {
      setState(() => _isProcessingFavorite = false);
    }
  }

  Future<void> _deleteProduct() async {
    setState(() => _isProcessing = true);
    try {
      await _supabase
          .from('products')
          .delete()
          .eq('id', widget.product['id']);

      widget.onDelete();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ في حذف الإعلان: ${e.toString()}')),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  List<String> _getAllImageUrls(String imageUrlsString) {
    try {
      return imageUrlsString.split('|');
    } catch (e) {
      return [];
    }
  }

  String _formatTimeAgo(String dateTimeString) {
    try {
      final now = DateTime.now();
      final createdAt = DateTime.parse(dateTimeString);
      final duration = now.difference(createdAt);

      if (duration.inDays > 30) {
        final months = (duration.inDays / 30).floor();
        return 'منذ $months ${months == 1 ? 'شهر' : 'شهر'}';
      } else if (duration.inDays > 0) {
        return 'منذ ${duration.inDays} ${duration.inDays == 1 ? 'يوم' : 'أيام'}';
      } else if (duration.inHours > 0) {
        return 'منذ ${duration.inHours} ${duration.inHours == 1 ? 'ساعة' : 'ساعات'}';
      } else if (duration.inMinutes > 0) {
        return 'منذ ${duration.inMinutes} ${duration.inMinutes == 1 ? 'دقيقة' : 'دقائق'}';
      } else {
        return 'الآن';
      }
    } catch (e) {
      return dateTimeString;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageUrls = _getAllImageUrls(widget.product['image_urls'] as String);

    return Scaffold(
      backgroundColor: const Color(0xFFEEDDCF),
      appBar: AppBar(
        title: Text(
          "تفاصيل الإعلان",
          style: GoogleFonts.tajawal(
            fontWeight: FontWeight.bold,
            color: Colors.white,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (imageUrls.isNotEmpty) ...[
              SizedBox(
                height: 600,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: imageUrls.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(15),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          imageUrls[index],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: const Color(0xFFEEDDCF),
                                child: const Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    size: 50,
                                    color: Color(0xFF6C4422),
                                  ),
                                ),
                              ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List<Widget>.generate(imageUrls.length, (index) {
                  return Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == index
                          ? const Color(0xFF6C4422)
                          : Colors.grey.withOpacity(0.5),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
            ],

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF6C4422),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: _isProcessingFavorite
                                  ? const SizedBox(
                                width: 28,
                                height: 28,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                                  : AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: Icon(
                                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                                  key: ValueKey<bool>(_isFavorite),
                                  color: _isFavorite ? Colors.red : const Color(0xFF6C4422),
                                  size: 28,
                                ),
                              ),
                              onPressed: _toggleFavorite,
                            ),
                            Expanded(
                              child: Text(
                                widget.product['title'] ?? 'بدون عنوان',
                                textAlign: TextAlign.end,
                                style: GoogleFonts.tajawal(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF6C4422),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          textDirection: TextDirection.rtl,
                          children: [
                            const Icon(Icons.location_on, size: 16, color: Color(0xFF6C4422)),
                            const SizedBox(width: 4),
                            Text(
                              widget.product['location'] ?? 'غير محدد',
                              style: GoogleFonts.tajawal(fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          textDirection: TextDirection.rtl,
                          children: [
                            const Icon(Icons.access_time_filled, size: 16, color: Color(0xFF6C4422)),
                            const SizedBox(width: 4),
                            Text(
                              _formatTimeAgo(widget.product['created_at']),
                              style: GoogleFonts.tajawal(
                                  fontSize: 14,
                                  color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (widget.product['description'] != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          ':الوصف',
                          style: GoogleFonts.tajawal(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF6C4422),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.product['description'],
                            textAlign: TextAlign.right,
                            style: GoogleFonts.tajawal(fontSize: 16),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),

                  if (widget.product['price'] != null)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C4422).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF6C4422),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset('assets/icons/riyal.png', width: 16, height: 16),
                          const SizedBox(width: 4),
                          Text(
                            'السعر: ${widget.product['price']}',
                            style: GoogleFonts.tajawal(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF6C4422),
                            ),
                          ),
                        ],
                      ),
                    ),
                  // أزرار التعديل والحذف
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: _isProcessing
                              ? null
                              : () async {
                            await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('تأكيد الحذف'),
                                content: const Text(
                                    'هل أنت متأكد من حذف هذا الإعلان؟'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context),
                                    child: const Text('إلغاء'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _deleteProduct();
                                    },
                                    child: const Text('حذف'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: _isProcessing
                              ? const CircularProgressIndicator(
                              color: Colors.white)
                              : Text(
                            'حذف الإعلان',
                            style: GoogleFonts.tajawal(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6C4422),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: widget.onUpdate,
                          child: Text(
                            'تعديل الإعلان',
                            style: GoogleFonts.tajawal(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}