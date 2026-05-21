import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

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

  void _openDashboard(BuildContext context) {
    if (Navigator.canPop(context)) Navigator.pop(context);
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
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
          children: [
            const _SearchBar(),
            const SizedBox(height: 14),
            const _SellerAccessCard(),
            const SizedBox(height: 22),
            const Text(
              'New Post',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            const _ProductGrid(products: _newPostProducts),
            const SizedBox(height: 24),
            const Text(
              'Popular Products',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            const _ProductGrid(products: _popularProducts),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryBlue,
        unselectedItemColor: Colors.black87,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        showUnselectedLabels: true,
        onTap: (index) {
          if (index == 0) _openDashboard(context);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
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

class _SellerAccessCard extends StatelessWidget {
  const _SellerAccessCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ProductsScreen.borderBlue),
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
              color: ProductsScreen.primaryBlue,
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
              backgroundColor: ProductsScreen.primaryBlue,
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
        Uri.parse('${ProductsScreen.apiBaseUrl}/api/seller/access-request/'),
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
                    backgroundColor: ProductsScreen.primaryBlue,
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
          prefixIcon: Icon(icon, color: ProductsScreen.primaryNavy),
          filled: true,
          fillColor: const Color(0xFFF8FAFD),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFD4DAE3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: ProductsScreen.primaryBlue),
          ),
        ),
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
        return _ProductCard(product: products[index]);
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
        hintText: 'Search for products...',
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
          borderSide: const BorderSide(color: ProductsScreen.primaryBlue),
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final _ProductItem product;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ProductsScreen.borderBlue),
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
                color: ProductsScreen.primaryNavy,
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
                color: ProductsScreen.primaryBlue,
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

class _ProductItem {
  const _ProductItem(this.name, this.price, this.icon, this.color);

  final String name;
  final String price;
  final IconData icon;
  final Color color;
}
