import 'dart:async';

import 'package:discover_herceg_novi/models/location_model.dart';
import 'package:discover_herceg_novi/services/auth_service.dart';
import 'package:discover_herceg_novi/services/location_service.dart';
import 'package:discover_herceg_novi/theme/app_theme.dart';
import 'package:discover_herceg_novi/widgets/travel_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();

  String selectedCategory = 'Sve';
  String searchQuery = '';

  bool get isGuest => FirebaseAuth.instance.currentUser == null;

  final List<Map<String, dynamic>> _categories = [
    {'label': 'Sve', 'icon': Icons.all_inclusive_rounded},
    {'label': 'Zabava', 'icon': Icons.terrain_rounded},
    {'label': 'Plaža', 'icon': Icons.beach_access_rounded},
    {'label': 'Kultura', 'icon': Icons.account_balance_rounded},
    {'label': 'Restorani', 'icon': Icons.restaurant_rounded},
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleProfileTap() async {
    if (!isGuest) {
      await _authService.signOut();
    }

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(context, '/splash', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeroHeader(),

              Transform.translate(
                offset: const Offset(0, -24),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSearchField(),

                      const SizedBox(height: 22),

                      const FunFactsCard(),

                      const SizedBox(height: 28),

                      _buildSectionTitle(
                        title: 'Kategorije',
                        subtitle: 'Izaberite šta želite da istražite',
                      ),

                      const SizedBox(height: 16),

                      _buildCategories(),

                      const SizedBox(height: 30),

                      _buildSectionTitle(
                        title: 'Istraži grad',
                        subtitle: 'Mjesta koja vrijedi posjetiti',
                      ),

                      const SizedBox(height: 16),

                      _buildLocations(),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroHeader() {
    final user = FirebaseAuth.instance.currentUser;

    final userName = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!
        : user?.email?.split('@').first;

    return Container(
      height: 270,
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(
            'https://i.pinimg.com/736x/28/05/0d/28050db31967372594ea771519ed87f7.jpg',
          ),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 42),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.43),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(32),
            bottomRight: Radius.circular(32),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset('assets/images/Slika1.png', height: 38),

                const Spacer(),

                GestureDetector(
                  onTap: _handleProfileTap,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.20),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.70)),
                    ),
                    child: Icon(
                      isGuest
                          ? Icons.person_outline_rounded
                          : Icons.logout_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const Spacer(),

            Text(
              isGuest ? 'Dobrodošli' : 'Zdravo, ${userName ?? 'putnik'} 👋',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Otkrijte\nHerceg Novi',
              style: TextStyle(
                color: Colors.white,
                fontSize: 38,
                height: 1.05,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Discover the city. Feel at home.',
              style: TextStyle(color: Colors.white70, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 16,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            searchQuery = value.trim().toLowerCase();
          });
        },
        decoration: InputDecoration(
          hintText: 'Pretražite mjesta i kategorije',
          border: InputBorder.none,
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.primary,
          ),
          suffixIcon: searchQuery.isEmpty
              ? const Icon(Icons.tune_rounded, color: Colors.grey)
              : IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();

                    setState(() {
                      searchQuery = '';
                    });
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle({required String title, required String subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
            color: Color(0xFF252525),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        padding: const EdgeInsets.only(left: 2, right: 2, top: 2, bottom: 14),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 15),
        itemBuilder: (context, index) {
          final category = _categories[index];

          return _buildCategoryItem(
            category['label'] as String,
            category['icon'] as IconData,
          );
        },
      ),
    );
  }

  Widget _buildCategoryItem(String label, IconData icon) {
    final isActive = selectedCategory == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = label;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        width: 74,
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 9,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : AppColors.primary,
              size: 27,
            ),

            const SizedBox(height: 8),

            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.black87,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocations() {
    return SizedBox(
      height: 250,
      child: StreamBuilder<List<LocationModel>>(
        stream: selectedCategory == 'Sve'
            ? LocationService().getLocations()
            : LocationService().getLocationsByCategory(selectedCategory),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Nije moguće učitati lokacije.'));
          }

          List<LocationModel> locations = snapshot.data ?? [];

          if (searchQuery.isNotEmpty) {
            locations = locations.where((location) {
              return location.title.toLowerCase().contains(searchQuery) ||
                  location.category.toLowerCase().contains(searchQuery);
            }).toList();
          }

          if (locations.isEmpty) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.travel_explore_rounded,
                    size: 55,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Nema pronađenih lokacija',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Pokušajte sa drugom kategorijom ili pretragom.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: locations.length,
            itemBuilder: (context, index) {
              return TravelCard(loc: locations[index]);
            },
          );
        },
      ),
    );
  }
}

class FunFactsCard extends StatefulWidget {
  const FunFactsCard({super.key});

  @override
  State<FunFactsCard> createState() => _FunFactsCardState();
}

class _FunFactsCardState extends State<FunFactsCard> {
  int _currentFactIndex = 0;
  Timer? _timer;

  final List<Map<String, dynamic>> _facts = [
    {
      'icon': Icons.history_edu_rounded,
      'title': 'Da li ste znali?',
      'text':
          'Herceg Novi je osnovan 1382. godine i kroz istoriju je nosio više različitih imena.',
    },
    {
      'icon': Icons.local_florist_rounded,
      'title': 'Grad zelenila',
      'text':
          'Herceg Novi je poznat po bujnoj mediteranskoj vegetaciji, palmama, mimozama i brojnim parkovima.',
    },
    {
      'icon': Icons.wb_sunny_rounded,
      'title': 'Grad sunca',
      'text':
          'Herceg Novi ima veliki broj sunčanih dana tokom godine i veoma blagu mediteransku klimu.',
    },
    {
      'icon': Icons.fort_rounded,
      'title': 'Grad tvrđava',
      'text':
          'Forte Mare, Kanli Kula i Španjola svjedoče o bogatoj i burnoj istoriji grada.',
    },
    {
      'icon': Icons.stairs_rounded,
      'title': 'Grad stepenica',
      'text':
          'Herceg Novi je prepoznatljiv po brojnim stepenicama koje povezuju obalu, stari grad i naselja.',
    },
    {
      'icon': Icons.celebration_rounded,
      'title': 'Praznik mimoze',
      'text':
          'Praznik mimoze je jedna od najpoznatijih manifestacija u Herceg Novom.',
    },
  ];

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 6), (_) => _showNextFact());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _showNextFact() {
    if (!mounted) return;

    setState(() {
      _currentFactIndex = (_currentFactIndex + 1) % _facts.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final fact = _facts[_currentFactIndex];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.78)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.24),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 650),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            layoutBuilder: (currentChild, previousChildren) {
              return Stack(
                alignment: Alignment.topLeft,
                children: [
                  ...previousChildren,
                  if (currentChild != null) currentChild,
                ],
              );
            },
            transitionBuilder: (child, animation) {
              final slideAnimation = Tween<Offset>(
                begin: const Offset(0.12, 0),
                end: Offset.zero,
              ).animate(animation);

              return FadeTransition(
                opacity: animation,
                child: SlideTransition(position: slideAnimation, child: child),
              );
            },
            child: SizedBox(
              key: ValueKey<int>(_currentFactIndex),
              width: double.infinity,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      fact['icon'] as IconData,
                      color: Colors.white,
                      size: 29,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fact['title'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          fact['text'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: Row(
                  children: List.generate(_facts.length, (index) {
                    final isActive = index == _currentFactIndex;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 6),
                      width: isActive ? 22 : 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.white
                            : Colors.white.withOpacity(0.45),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    );
                  }),
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: _showNextFact,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.16),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 21,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
