import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test2/pages/add_product_page.dart';
import 'package:test2/pages/favorites_page.dart';
import 'package:test2/pages/my_ads_page.dart';
import 'package:test2/pages/products_list_page.dart';
import 'package:test2/pages/profile_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _searchQuery = '';

  late final Stream<Map<String, dynamic>> _profileStream;
  String userName = '';
  String? userImageUrl;

  @override
  void initState() {
    super.initState();
    final user = Supabase.instance.client.auth.currentUser;
    _profileStream = Supabase.instance.client
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('id', user!.id)
        .map((data) => data.first);

    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user != null) {
      final response = await supabase
          .from('profiles')
          .select('username, avatar_url')
          .eq('id', user.id)
          .single();

      setState(() {
        userName = response['username'] ?? 'بدون اسم';
        userImageUrl = response['avatar_url'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFEEDDCF),
      endDrawer: _buildDrawer(),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          backgroundColor: const Color(0xFF6C4422),
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 45,
                child: Image.asset(
                  "assets/icons/Appbar.png",
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.search, color: Colors.white, size: 30),
            onPressed: () {
              setState(() {
                isSearching = !isSearching;
                if (!isSearching) {
                  _searchController.clear();
                  _searchQuery = '';
                }
              });
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white, size: 30),
              onPressed: () {
                _scaffoldKey.currentState!.openEndDrawer();
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (isSearching)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    icon: const Icon(Icons.search, color: Color(0xFF6C4422)),
                    hintText: 'ابحث هنا',
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF6C4422)),
                      onPressed: () {
                        setState(() {
                          isSearching = false;
                          _searchController.clear();
                          _searchQuery = '';
                        });
                      },
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  onSubmitted: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
            ),
          Expanded(
            child: ProductsList(searchQuery: _searchQuery),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF6C4422),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const FavoritesPage()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.email, size: 30, color: Colors.white),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_sharp, size: 30, color: Colors.white),
            label: 'Favorites',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF6C4422), width: 3),
        ),
        backgroundColor:  Colors.white,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => AddProductPage()),
          );
        },
        child: const Icon(Icons.add, size: 40, color: Color(0xFF6C4422)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildDrawer() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Drawer(
        backgroundColor: const Color(0xFFEEDDCF),
        child: Column(
          children: [
            StreamBuilder<Map<String, dynamic>>(
              stream: _profileStream,
              builder: (context, snapshot) {
                final data = snapshot.data;
                final currentImageUrl = data?['avatar_url'];
                final currentUserName = data?['username'] ?? userName;

                return Container(
                  padding: const EdgeInsets.only(top: 40, bottom: 10),
                  width: double.infinity,
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 57,
                        backgroundColor: Colors.transparent,
                        backgroundImage: currentImageUrl != null
                            ? NetworkImage(currentImageUrl)
                            : null,
                        child: currentImageUrl == null
                            ? const Icon(Icons.person, size: 40, color: Color(0xFF6C4422))
                            : null,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        currentUserName.isNotEmpty ? currentUserName : 'جارٍ التحميل...',
                        style: GoogleFonts.tajawal(
                          color: const Color(0xFF6C4422),
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 10), // مسافة قبل الخط
                      Divider(
                        height: 0,
                        thickness: 2,
                        color: const Color(0xFF6C4422).withOpacity(0.5),
                        indent: 40, // بداية الخط من الجهة اليمنى
                        endIndent: 40, // نهاية الخط من الجهة اليسرى
                      ),
                    ],
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Color(0xFF6C4422)),
              title: Text('الملف الشخصي',
                  style: GoogleFonts.tajawal(fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_box, color: Color(0xFF6C4422)),
              title: Text('إعلاناتي',
                  style: GoogleFonts.tajawal(fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyAdsPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Color(0xFF6C4422)),
              title: Text('الإعدادات',
                  style: GoogleFonts.tajawal(fontWeight: FontWeight.bold)),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}