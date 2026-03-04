import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final _formKey = GlobalKey<FormState>();
  late PageController _pageController;
  Timer? _carouselTimer;
  bool _isForward = true;

  // Form values
  String _name = '';
  String _phone = '';
  String _selectedCity = 'Tripoli';
  String _selectedSize = 'S (36-39)';
  String _selectedColor = 'Black';
  int _quantity = 1;
  final double _pricePerUnit = 20.0;
  bool _isAdminIconVisible = false;
  bool _isLoading = false;

  final List<String> _cities = [
    'Tripoli',
    'Benghazi',
    'Misrata',
    'Tarhuna',
    'Al Khums',
    'Zawia',
    'Zuwara',
    'Ajdabiya',
    'Sabha',
    'Sirte',
    'Tobruk',
    'Al Marj',
    'Derna',
    'Zliten',
  ];

  final List<String> _sizes = ['S (36-39)', 'L (40-45)'];
  final List<String> _colors = ['Black', 'White'];

  final List<String> _productImages = [
    'assets/product pics/5823666691068595617.jpg',
    'assets/product pics/5823666691068595618.jpg',
    'assets/product pics/5823666691068595619.jpg',
    'assets/product pics/5823666691068595620.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startCarousel();
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startCarousel() {
    _carouselTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        int nextPage;
        if (_isForward) {
          nextPage = _pageController.page!.round() + 1;
          if (nextPage >= _productImages.length) {
            nextPage = _productImages.length - 2;
            _isForward = false;
          }
        } else {
          nextPage = _pageController.page!.round() - 1;
          if (nextPage < 0) {
            nextPage = 1;
            _isForward = true;
          }
        }

        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  double get _totalPrice => _quantity * _pricePerUnit;

  void _incrementQuantity() {
    setState(() => _quantity++);
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() => _quantity--);
    }
  }

  void _resetForm() {
    setState(() {
      _formKey.currentState?.reset();
      _name = '';
      _phone = '';
      _selectedCity = 'Tripoli';
      _selectedSize = 'S (36-39)';
      _selectedColor = 'Black';
      _quantity = 1;
    });
  }

  Future<void> _placeOrder() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() => _isLoading = true);

      try {
        final order = OrderModel(
          id: '', // Firestore will generate this
          name: _name,
          phone: _phone,
          city: _selectedCity,
          size: _selectedSize,
          color: _selectedColor,
          quantity: _quantity,
          totalPrice: _totalPrice,
          timestamp: DateTime.now(),
        );

        await FirebaseFirestore.instance
            .collection('orders')
            .add(order.toMap());

        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Order Placed Successfully!'),
              content: Text(
                'Thank you, $_name!\n'
                'Phone: $_phone\n'
                'Your order for $_quantity $_selectedColor sneaker(s) (Size: $_selectedSize) is on its way to $_selectedCity.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _resetForm();
                  },
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        }
      } on FirebaseException catch (e) {
        debugPrint("Firestore Error: ${e.code} - ${e.message}");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Purchase failed: Check your internet or database permissions (${e.code})',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        debugPrint("Unknown Error: $e");
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to place order: $e')));
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 800),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 40,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 1. Company Logo
                    Listener(
                      onPointerSignal: (pointerSignal) {
                        if (pointerSignal is PointerScrollEvent) {
                          // Detect any scroll on the logo to reveal admin icon
                          if (pointerSignal.scrollDelta.dy != 0 ||
                              pointerSignal.scrollDelta.dx != 0) {
                            setState(() {
                              _isAdminIconVisible = true;
                            });
                          }
                        }
                      },
                      child: GestureDetector(
                        onHorizontalDragEnd: (details) {
                          // Detect left swipe (negative velocity)
                          if (details.primaryVelocity! < -50) {
                            setState(() {
                              _isAdminIconVisible = true;
                            });
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(40),
                            child: Image.asset(
                              'assets/5823666691068595585.jpg',
                              width: double.infinity,
                              height: 150,
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // 2. Product Carousel
                    SizedBox(
                      height: 400,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _productImages.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.asset(
                                _productImages[index],
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 3. Product Description
                    Column(
                      children: const [
                        Text(
                          'Sneaker Crease Guards 👟',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 15),
                        Text(
                          'Protect your sneakers and keep them looking fresh for longer.\n\n'
                          'Made from high-quality, durable PE & TPR materials, our crease guards help prevent toe box creasing while staying comfortable inside your shoes. The breathable perforated design keeps your feet dry, and the flexible structure allows you to trim and adjust them to fit your exact shoe size.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                        SizedBox(height: 20),
                        Text(
                          '✔ Prevents creases\n'
                          '✔ Comfortable & breathable\n'
                          '✔ Adjustable to your size\n'
                          '✔ Durable & washable\n'
                          '✔ Extends the life of your sneakers',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // 4. Order Form
                    const Text(
                      'BUY NOW',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.lightBlue,
                      ),
                    ),
                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name
                            const Text(
                              'Full Name',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              decoration: InputDecoration(
                                hintText: 'Enter your name',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              onSaved: (value) => _name = value ?? '',
                              validator: (value) =>
                                  (value == null || value.isEmpty)
                                  ? 'Please enter your name'
                                  : null,
                            ),
                            const SizedBox(height: 20),

                            // Phone
                            const Text(
                              'Phone Number',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                hintText: 'e.g. 0912345678',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onSaved: (value) => _phone = value ?? '',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your phone';
                                }
                                if (!value.startsWith('09')) {
                                  return 'Must start with 09';
                                }
                                if (value.length != 10) {
                                  return 'Must be exactly 10 digits';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // City
                            const Text(
                              'City (Libya)',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedCity,
                              items: _cities.map((city) {
                                return DropdownMenuItem(
                                  value: city,
                                  child: Text(city),
                                );
                              }).toList(),
                              onChanged: (value) =>
                                  setState(() => _selectedCity = value!),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Size
                            const Text(
                              'Select Size',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedSize,
                              items: _sizes.map((size) {
                                return DropdownMenuItem(
                                  value: size,
                                  child: Text(size),
                                );
                              }).toList(),
                              onChanged: (value) =>
                                  setState(() => _selectedSize = value!),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Color
                            const Text(
                              'Select Color',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            RadioGroup<String>(
                              groupValue: _selectedColor,
                              onChanged: (value) =>
                                  setState(() => _selectedColor = value!),
                              child: Row(
                                children: _colors.map((color) {
                                  return Expanded(
                                    child: RadioListTile<String>(
                                      title: Text(color),
                                      value: color,
                                      contentPadding: EdgeInsets.zero,
                                      dense: true,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Quantity
                            const Text(
                              'Quantity',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: _decrementQuantity,
                                  icon: const Icon(Icons.remove_circle_outline),
                                ),
                                Text(
                                  '$_quantity',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  onPressed: _incrementQuantity,
                                  icon: const Icon(Icons.add_circle_outline),
                                ),
                              ],
                            ),
                            const SizedBox(height: 40),

                            // Total and Place Order
                            const Divider(),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'TOTAL PRICE:',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '$_totalPrice LYD',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.blueGrey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
                            SizedBox(
                              width: double.infinity,
                              height: 60,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _placeOrder,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black87,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : const Text(
                                        'PLACE ORDER',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
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
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            right: _isAdminIconVisible ? 20 : -60,
            top: 40,
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/login'),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.admin_panel_settings,
                  color: Colors.blueGrey,
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
