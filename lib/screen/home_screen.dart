// home_screen.dart - الإصدار المعدل
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  String userName = 'مستخدم';
  String? userImageUrl;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    // تم إزالة كود Supabase
    setState(() {
      userName = 'مستخدم';
    });
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
            Container(
              padding: const EdgeInsets.only(top: 40, bottom: 10),
              width: double.infinity,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 57,
                    backgroundColor: Colors.transparent,
                    backgroundImage: userImageUrl != null
                        ? NetworkImage(userImageUrl!)
                        : null,
                    child: userImageUrl == null
                        ? const Icon(Icons.person, size: 40, color: Color(0xFF6C4422))
                        : null,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    userName,
                    style: GoogleFonts.tajawal(
                      color: const Color(0xFF6C4422),
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Divider(
                    height: 0,
                    thickness: 2,
                    color: const Color(0xFF6C4422).withOpacity(0.5),
                    indent: 40,
                    endIndent: 40,
                  ),
                ],
              ),
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