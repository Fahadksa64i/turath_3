// my_ads_page.dart - الإصدار المعدل
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyAdsPage extends StatefulWidget {
  const MyAdsPage({super.key});

  @override
  State<MyAdsPage> createState() => _MyAdsPageState();
}

class _MyAdsPageState extends State<MyAdsPage> {
  List<Map<String, dynamic>> _userProducts = [];
  bool _isLoading = true;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await _fetchUserProducts();
    setState(() => _isLoading = false);
  }

  Future<void> _fetchUserProducts() async {
    try {
      // تم إزالة كود Supabase
      setState(() {
        _userProducts = [];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ في جلب الإعلانات: ${e.toString()}')),
        );
      }
    }
  }

  // ... باقي الدوال بدون تغيير
  Future<void> _handleRefresh() async {
    await _fetchUserProducts();
  }

  String? _getFirstImageUrl(String imageUrlsString) {
    try {
      final urls = imageUrlsString.split('|');
      return urls.isNotEmpty ? urls[0] : null;
    } catch (e) {
      return null;
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEDDCF),
      appBar: AppBar(
        title: Text(
          'إعلاناتي',
          style: GoogleFonts.tajawal(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF6C4422),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _handleRefresh,
        color: const Color(0xFF6C4422),
        backgroundColor: const Color(0xFFEEDDCF),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading && _userProducts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_userProducts.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text(
              'لا توجد إعلانات متاحة حالياً',
              style: GoogleFonts.tajawal(fontSize: 18),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: _userProducts.length,
      itemBuilder: (context, index) {
        final product = _userProducts[index];
        final firstImage = _getFirstImageUrl(product['image_urls'] as String);

        return GestureDetector(
          onTap: () {
            // تم إزالة التنقل لصفحة التفاصيل
          },
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Color(0xFF6C4422)),
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.only(bottom: 16),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (firstImage != null)
                    ClipRRect(
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(12),
                      ),
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEDDCF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Image.network(
                          firstImage,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image),
                        ),
                      ),
                    ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            product['title'] ?? 'بدون عنوان',
                            style: GoogleFonts.tajawal(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            textDirection: TextDirection.rtl,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.location_on, size: 16, color: Color(0xFF6C4422)),
                              const SizedBox(width: 4),
                              Text(
                                product['location'] ?? 'غير محدد',
                                style: GoogleFonts.tajawal(fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            textDirection: TextDirection.rtl,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.access_time_filled, size: 16, color: Color(0xFF6C4422)),
                              const SizedBox(width: 4),
                              Text(
                                _formatTimeAgo(product['created_at']),
                                style: GoogleFonts.tajawal(
                                    fontSize: 12,
                                    color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (product['price'] != null)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset('assets/icons/riyal.png', width: 16, height: 16),
                                const SizedBox(width: 4),
                                Text(
                                  product['price'].toString(),
                                  style: GoogleFonts.tajawal(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF6C4422),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}