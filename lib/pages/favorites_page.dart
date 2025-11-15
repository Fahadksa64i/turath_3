import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test2/pages/product_details_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Map<String, dynamic>> _favoriteProducts = [];
  bool _isLoading = true;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    await _fetchFavorites();
    setState(() => _isLoading = false);
  }

  Future<void> _fetchFavorites() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user != null) {
        final response = await supabase
            .from('favorites')
            .select('products(*)')
            .eq('user_id', user.id);

        setState(() {
          _favoriteProducts = List<Map<String, dynamic>>.from(
            response.map((item) => item['products'] as Map<String, dynamic>),
          );
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ في جلب المفضلة: ${e.toString()}')),
        );
      }
    }
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

  Future<void> _handleRefresh() async {
    await _fetchFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEDDCF),
      appBar: AppBar(
        title: Text(
          "المفضلة",
          style: GoogleFonts.tajawal(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(icon: Icon(Icons.arrow_back,color: Colors.white),
          onPressed: () {
          Navigator.of(context).pop();
          },),
        centerTitle: true,
        backgroundColor: const Color(0xFF6C4422),
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
    if (_isLoading && _favoriteProducts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_favoriteProducts.isEmpty) {
      return Center(
        child: Text(
          'لا توجد عناصر في المفضلة',
          style: GoogleFonts.tajawal(fontSize: 18),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: _favoriteProducts.length,
      itemBuilder: (context, index) {
        final product = _favoriteProducts[index];
        final firstImage = _getFirstImageUrl(product['image_urls'] as String);

        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ProductDetailsPage(product: product),
              ),
            );
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
                          // إضافة موقع الإعلان
                          Row(
                            textDirection: TextDirection.rtl,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.location_on,
                                  size: 16,
                                  color: Color(0xFF6C4422)),
                              const SizedBox(width: 4),
                              Text(
                                product['location'] ?? 'غير محدد',
                                style: GoogleFonts.tajawal(fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // إضافة وقت الإعلان
                          Row(
                            textDirection: TextDirection.rtl,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.access_time_filled,
                                  size: 16,
                                  color: Color(0xFF6C4422)),
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
                                const SizedBox(width: 4,),
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