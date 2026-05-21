import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  static const Color primaryNavy = Color(0xFF142B47);
  static const Color primaryBlue = Color(0xFF1A56DB);
  static const Color webBrandBlue = Color(0xFF0175C2);
  static const Color campusGold = Color(0xFFFCB316);
  static const Color pageBackground = Color(0xFFF8FAFD);
  static const Color borderBlue = Color(0xFFBFD7FF);
  static const String apiBaseUrl = 'http://10.0.2.2:8000';

  static const List<_ProductItem> _newPostProducts = [
    _ProductItem('Maja', 'P 150.00', Icons.rice_bowl_outlined, Color(0xFFFFF4C7)),
    _ProductItem('Milkshake', 'P 100.00', Icons.local_cafe_outlined, Color(0xFFF3DCE6)),
    _ProductItem('BananaCue', 'P 10.00', Icons.lunch_dining_outlined, Color(0xFFFFD8A8)),
    _ProductItem('KamoteCue', 'P 10.00', Icons.fastfood_outlined, Color(0xFFFFC078)),
  ];

  static const List<_ProductItem> _popularProducts = [
    _ProductItem('Burger', 'P 45.00', Icons.lunch_dining, Color(0xFFFFE0B2)),
    _ProductItem('Coffee', 'P 60.00', Icons.coffee_outlined, Color(0xFFD7CCC8)),
    _ProductItem('Fries', 'P 35.00', Icons.fastfood_outlined, Color(0xFFFFF0B3)),
    _ProductItem('Juice', 'P 25.00', Icons.local_drink_outlined, Color(0xFFFFCDD2)),
  ];

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const Color primaryNavy = DashboardScreen.primaryNavy;
  static const Color primaryBlue = DashboardScreen.primaryBlue;
  static const Color webBrandBlue = DashboardScreen.webBrandBlue;
  static const Color campusGold = DashboardScreen.campusGold;
  static const Color pageBackground = DashboardScreen.pageBackground;

  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToTab(int index) {
    if (index == _currentIndex) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 56,
        titleSpacing: 16,
        title: Row(
          children: [
            Image.asset(
              'assets/img/logo.png',
              width: 34,
              height: 34,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFEAF1FF),
                  ),
                  child: const Icon(
                    Icons.school_outlined,
                    color: primaryBlue,
                  ),
                );
              },
            ),
            const SizedBox(width: 10),
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                children: [
                  TextSpan(
                    text: 'Campus',
                    style: TextStyle(color: campusGold),
                  ),
                  TextSpan(text: 'Hub', style: TextStyle(color: webBrandBlue)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none, color: primaryNavy),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFFEAF1FF),
              child: Icon(Icons.person, color: primaryNavy.withValues(alpha: 0.8)),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            FocusManager.instance.primaryFocus?.unfocus();
            setState(() => _currentIndex = index);
          },
          children: [
            _HomePage(
              onProductsTap: () => _goToTab(1),
              onFacilitiesTap: () => _goToTab(3),
            ),
            const _MarketplacePage(),
            const _SimplePage(
              icon: Icons.miscellaneous_services_outlined,
              title: 'Services',
              subtitle: 'Campus services will appear here.',
            ),
            const _FacilitiesPage(),
            const _SimplePage(
              icon: Icons.person_outline,
              title: 'Profile',
              subtitle: 'Your account details will appear here.',
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryBlue,
        unselectedItemColor: Colors.black87,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        showUnselectedLabels: true,
        onTap: _goToTab,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'Marketplace',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.miscellaneous_services_outlined),
            label: 'Services',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            label: 'Facilities',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage({
    required this.onProductsTap,
    required this.onFacilitiesTap,
  });

  final VoidCallback onProductsTap;
  final VoidCallback onFacilitiesTap;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
      children: [
        const _SearchBar(),
        const SizedBox(height: 22),
        _SectionHeader(title: 'New Post', onViewAll: onProductsTap),
        const SizedBox(height: 12),
        const _HorizontalProducts(products: DashboardScreen._newPostProducts),
        const SizedBox(height: 22),
        _SectionHeader(title: 'Popular Products', onViewAll: onProductsTap),
        const SizedBox(height: 12),
        const _HorizontalProducts(products: DashboardScreen._popularProducts),
        const SizedBox(height: 22),
        _SectionHeader(title: 'Facilities', onViewAll: onFacilitiesTap),
        const SizedBox(height: 12),
        const _FacilityCard(),
      ],
    );
  }
}

class _MarketplacePage extends StatelessWidget {
  const _MarketplacePage();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
      children: const [
        _SearchBar(),
        SizedBox(height: 14),
        _SellerAccessCard(),
        SizedBox(height: 22),
        _PageTitle('New Post'),
        SizedBox(height: 14),
        _ProductGrid(products: DashboardScreen._newPostProducts),
        SizedBox(height: 24),
        _PageTitle('Popular Products'),
        SizedBox(height: 14),
        _ProductGrid(products: DashboardScreen._popularProducts),
      ],
    );
  }
}

class _SellerAccessCard extends StatelessWidget {
  const _SellerAccessCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: DashboardScreen.borderBlue),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF1FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.storefront_outlined,
              color: DashboardScreen.primaryBlue,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Want to sell on campus?',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Request seller access for marketplace approval.',
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () => _showSellerRequestForm(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: DashboardScreen.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              minimumSize: const Size(0, 38),
            ),
            child: const Text(
              'Become a Seller',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

void _showSellerRequestForm(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => const _SellerRequestForm(),
  );
}

class _SellerRequestForm extends StatefulWidget {
  const _SellerRequestForm();

  @override
  State<_SellerRequestForm> createState() => _SellerRequestFormState();
}

class _SellerRequestFormState extends State<_SellerRequestForm> {
  final _formKey = GlobalKey<FormState>();
  final _studentIdController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _courseSectionController = TextEditingController();
  final _contactController = TextEditingController();
  final _productTypeController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _studentIdController.dispose();
    _fullNameController.dispose();
    _courseSectionController.dispose();
    _contactController.dispose();
    _productTypeController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final response = await http.post(
        Uri.parse('${DashboardScreen.apiBaseUrl}/api/seller/access-request/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'student_id': _studentIdController.text.trim(),
          'full_name': _fullNameController.text.trim(),
          'course_section': _courseSectionController.text.trim(),
          'contact_number': _contactController.text.trim(),
          'product_type': _productTypeController.text.trim(),
          'message': _messageController.text.trim(),
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 201) {
        Navigator.pop(context);
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Text('Request Sent'),
            content: const Text(
              'Your seller request has been sent. Please wait for marketplace admin approval.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'OK',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Check the web dashboard notification bell for the request.',
            ),
          ),
        );
      } else {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(body['error']?.toString() ?? 'Request failed')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot connect to CampusHub server right now.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 18,
        right: 18,
        top: 18,
        bottom: MediaQuery.of(context).viewInsets.bottom + 18,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Seller Access Request',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Marketplace admin will review your request before you can post products.',
                style: TextStyle(color: Colors.black54, fontSize: 13),
              ),
              const SizedBox(height: 18),
              _SellerField(
                controller: _studentIdController,
                label: 'Student ID',
                icon: Icons.badge_outlined,
              ),
              _SellerField(
                controller: _fullNameController,
                label: 'Full name',
                icon: Icons.person_outline,
              ),
              _SellerField(
                controller: _courseSectionController,
                label: 'Course / Section',
                icon: Icons.school_outlined,
                required: false,
              ),
              _SellerField(
                controller: _contactController,
                label: 'Contact number',
                icon: Icons.phone_outlined,
                required: false,
              ),
              _SellerField(
                controller: _productTypeController,
                label: 'Product type',
                icon: Icons.shopping_bag_outlined,
              ),
              _SellerField(
                controller: _messageController,
                label: 'Message',
                icon: Icons.chat_bubble_outline,
                required: false,
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DashboardScreen.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    _isSubmitting ? 'Sending...' : 'Submit Request',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SellerField extends StatelessWidget {
  const _SellerField({
    required this.controller,
    required this.label,
    required this.icon,
    this.required = true,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool required;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: (value) {
          if (!required) return null;
          return value == null || value.trim().isEmpty
              ? '$label is required'
              : null;
        },
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: DashboardScreen.primaryNavy),
          filled: true,
          fillColor: const Color(0xFFF8FAFD),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFD4DAE3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: DashboardScreen.primaryBlue),
          ),
        ),
      ),
    );
  }
}

class _FacilitiesPage extends StatelessWidget {
  const _FacilitiesPage();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
      children: const [
        _SearchBar(),
        SizedBox(height: 22),
        _PageTitle('Facilities'),
        SizedBox(height: 14),
        _FacilityCard(),
      ],
    );
  }
}

class _SimplePage extends StatelessWidget {
  const _SimplePage({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 52, color: DashboardScreen.primaryBlue),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageTitle extends StatelessWidget {
  const _PageTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _HorizontalProducts extends StatelessWidget {
  const _HorizontalProducts({required this.products});

  final List<_ProductItem> products;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 136,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          return _ProductCard(product: products[index]);
        },
      ),
    );
  }
}

class _ProductGrid extends StatelessWidget {
  const _ProductGrid({required this.products});

  final List<_ProductItem> products;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.86,
      ),
      itemBuilder: (context, index) {
        return _LargeProductCard(product: products[index]);
      },
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search for products, services...',
        hintStyle: const TextStyle(fontSize: 13, color: Colors.black38),
        prefixIcon: const Icon(Icons.search, color: Colors.black87),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD4DAE3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: DashboardScreen.primaryBlue),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onViewAll});

  final String title;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        TextButton(
          onPressed: onViewAll,
          style: TextButton.styleFrom(
            foregroundColor: DashboardScreen.primaryBlue,
            padding: EdgeInsets.zero,
            minimumSize: const Size(70, 32),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'View All',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              SizedBox(width: 4),
              Icon(Icons.chevron_right, size: 20),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final _ProductItem product;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 78,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: DashboardScreen.borderBlue),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 62,
            width: double.infinity,
            decoration: BoxDecoration(
              color: product.color,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Icon(
              product.icon,
              color: DashboardScreen.primaryNavy,
              size: 32,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(7, 8, 7, 0),
            child: Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(7, 8, 7, 0),
            child: Text(
              product.price,
              style: const TextStyle(
                color: DashboardScreen.primaryBlue,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LargeProductCard extends StatelessWidget {
  const _LargeProductCard({required this.product});

  final _ProductItem product;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: DashboardScreen.borderBlue),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: product.color,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
              ),
              child: Icon(
                product.icon,
                color: DashboardScreen.primaryNavy,
                size: 44,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
            child: Text(
              product.price,
              style: const TextStyle(
                color: DashboardScreen.primaryBlue,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FacilityCard extends StatelessWidget {
  const _FacilityCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: DashboardScreen.borderBlue),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 112,
            height: 134,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: const LinearGradient(
                colors: [Color(0xFFF6F3EE), Color(0xFFC6A88F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(
              Icons.hotel_outlined,
              color: DashboardScreen.primaryNavy,
              size: 52,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 134,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AFPROTECHS HOTEL',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: DashboardScreen.primaryNavy,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: const [
                      Icon(Icons.star, color: Color(0xFFFFB300), size: 16),
                      Icon(Icons.star, color: Color(0xFFFFB300), size: 16),
                      Icon(Icons.star, color: Color(0xFFFFB300), size: 16),
                      Icon(Icons.star, color: Color(0xFFFFB300), size: 16),
                      Icon(Icons.star, color: Color(0xFFFFB300), size: 16),
                      SizedBox(width: 6),
                      Text(
                        '4.6',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'A modern, well-equipped venue ideal for meetings and events.',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 12,
                      height: 1.15,
                    ),
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: SizedBox(
                      height: 32,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5C8EF2),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Book Now',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.chevron_right,
                              color: Colors.white,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductItem {
  const _ProductItem(this.name, this.price, this.icon, this.color);

  final String name;
  final String price;
  final IconData icon;
  final Color color;
}
