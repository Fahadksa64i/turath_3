import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test2/pages/product_details_page.dart';

class ProductsList extends StatefulWidget {
  final String searchQuery;

  const ProductsList({super.key, this.searchQuery = ''});

  @override
  State<ProductsList> createState() => _ProductsListState();
}

class _ProductsListState extends State<ProductsList> {
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _filteredProducts = [];
  bool _isLoading = true;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(ProductsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      _applySearchFilter();
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await _fetchProducts();
    setState(() => _isLoading = false);
  }

  Future<void> _fetchProducts() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('products')
          .select('*')
          .order('created_at', ascending: false);

      setState(() {
        _products = List<Map<String, dynamic>>.from(response);
        _filteredProducts = List.from(_products);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ في جلب البيانات: ${e.toString()}')),
        );
      }
    }
  }

  void _applySearchFilter() {
    setState(() {
      _filteredProducts = _products.where((product) {
        return widget.searchQuery.isEmpty ||
            (product['title']?.toString().toLowerCase().contains(widget.searchQuery.toLowerCase()) == true);
      }).toList();
    });
  }

  Future<void> _handleRefresh() async {
    await _fetchProducts();
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
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _handleRefresh,
      color: const Color(0xFF6C4422),
      backgroundColor: const Color(0xFFEEDDCF),
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoading && _products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_filteredProducts.isEmpty) {
      return ListView(
        children: [
          Center(
            child: Text(
              widget.searchQuery.isEmpty
                  ? 'لا توجد إعلانات متاحة حالياً'
                  : 'لا توجد نتائج مطابقة للبحث',
              style: GoogleFonts.tajawal(fontSize: 18),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
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
                      child: // داخل Column الخاص بعرض تفاصيل المنتج
                      Column(
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
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          if (product['price'] != null) ...[
                            const SizedBox(height: 8),
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
                          ] else
                            const SizedBox(height: 32),
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