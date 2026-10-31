import 'dart:math' as math;
import 'package:flutter/material.dart';

void main() {
  runApp(const GroceyApp());
}

class GroceyApp extends StatelessWidget {
  const GroceyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grocey',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const RoleSelectionScreen(),
    );
  }
}

// ---------------------------------------------------------
// 1. ROLE SELECTION (CUSTOMER / SHOPKEEPER / OWNER ADMIN)
// ---------------------------------------------------------
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.shopping_bag, size: 80, color: Colors.green),
              const SizedBox(height: 12),
              const Text(
                'Grocey',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.green),
              ),
              const Text(
                'लोकल किराना, सीधे घर तक (3 KM)',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: const Icon(Icons.person, color: Colors.white),
                label: const Text('Customer App (खरीददार)', style: TextStyle(color: Colors.white, fontSize: 16)),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerHomeScreen())),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade800,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: const Icon(Icons.store, color: Colors.white),
                label: const Text('Shopkeeper App (दुकानदार)', style: TextStyle(color: Colors.white, fontSize: 16)),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopkeeperDashboard())),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.black87),
                ),
                icon: const Icon(Icons.admin_panel_settings, color: Colors.black87),
                label: const Text('Owner Admin Panel (मालिक)', style: TextStyle(color: Colors.black87, fontSize: 16)),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OwnerAdminPanel())),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// 2. CUSTOMER MODULE (3 KM RADIUS & ₹30/KM DELIVERY RULES)
// ---------------------------------------------------------
class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  // 3 KM के अंदर की सैंपल दुकानें
  final List<Map<String, dynamic>> shops = [
    {"name": "शर्मा जी किराना स्टोर", "distance": 1.2, "isOpen": true, "rating": 4.8},
    {"name": "गुप्ता प्रोविजन स्टोर", "distance": 2.1, "isOpen": true, "rating": 4.5},
    {"name": "जय माता दी जनरल स्टोर", "distance": 3.4, "isOpen": false, "rating": 4.2}, // Out of radius (> 3 KM)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('नजदीकी किराना दुकानें'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: shops.length,
        itemBuilder: (context, index) {
          final shop = shops[index];
          final bool isWithin3Km = shop['distance'] <= 3.0;

          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: shop['isOpen'] && isWithin3Km ? Colors.green : Colors.grey,
                child: const Icon(Icons.storefront, color: Colors.white),
              ),
              title: Text(shop['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                'दूरी: ${shop['distance']} KM | डिलीवरी चार्ज: ₹${(shop['distance'] * 30).toStringAsFixed(0)}',
              ),
              trailing: isWithin3Km
                  ? (shop['isOpen']
                      ? ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          child: const Text('सामान देखें', style: TextStyle(color: Colors.white)),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ShopDetailScreen(shop: shop)),
                          ),
                        )
                      : const Text('बंद है', style: TextStyle(color: Colors.red)))
                  : const Text('3 KM से बाहर', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ),
          );
        },
      ),
    );
  }
}

// कस्टमर के लिए दुकान का सामान और बिलिंग
class ShopDetailScreen extends StatefulWidget {
  final Map<String, dynamic> shop;
  const ShopDetailScreen({super.key, required this.shop});

  @override
  State<ShopDetailScreen> createState() => _ShopDetailScreenState();
}

class _ShopDetailScreenState extends State<ShopDetailScreen> {
  final List<Map<String, dynamic>> products = [
    {"name": "आशीर्वाद आटा (10 kg)", "price": 420, "qty": 0},
    {"name": "फॉर्च्यून रिफाइंड तेल (1 L)", "price": 140, "qty": 0},
    {"name": "टाटा नमक (1 kg)", "price": 28, "qty": 0},
  ];

  @override
  Widget build(BuildContext context) {
    double itemTotal = products.fold(0, (sum, p) => sum + (p['price'] * p['qty']));
    double deliveryCharge = widget.shop['distance'] * 30.0;
    double platformCommission = itemTotal * 0.05; // 5% Commission
    double totalBill = itemTotal > 0 ? (itemTotal + deliveryCharge) : 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.shop['name']),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final p = products[index];
                return ListTile(
                  title: Text(p['name']),
                  subtitle: Text('₹${p['price']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => setState(() {
                          if (p['qty'] > 0) p['qty']--;
                        }),
                      ),
                      Text('${p['qty']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => setState(() => p['qty']++),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (itemTotal > 0)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -2))],
              ),
              child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('सामान का कुल मूल्य:'),
                    Text('₹${itemTotal.toStringAsFixed(0)}')
                  ]),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('डिलीवरी चार्ज (${widget.shop['distance']} KM x ₹30):'),
                    Text('₹${deliveryCharge.toStringAsFixed(0)}')
                  ]),
                  const Divider(),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('कुल बिल:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Text('₹${totalBill.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green)),
                  ]),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.all(14)),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('ऑर्डर प्लेस हो गया! (5% कमिशन प्लेटफॉर्म: ₹${platformCommission.toStringAsFixed(1)})')),
                        );
                      },
                      child: const Text('ऑर्डर कन्फर्म करें (Cash on Delivery)', style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// 3. SHOPKEEPER DASHBOARD (दुकानदार ऐप)
// ---------------------------------------------------------
class ShopkeeperDashboard extends StatefulWidget {
  const ShopkeeperDashboard({super.key});

  @override
  State<ShopkeeperDashboard> createState() => _ShopkeeperDashboardState();
}

class _ShopkeeperDashboardState extends State<ShopkeeperDashboard> {
  bool isStoreOpen = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('दुकानदार डैशबोर्ड'),
        backgroundColor: Colors.orange.shade800,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: SwitchListTile(
                title: const Text('दुकान चालू/बंद रखें', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(isStoreOpen ? 'दुकान अभी ग्राहकों को दिख रही है' : 'दुकान अभी बंद है'),
                value: isStoreOpen,
                activeColor: Colors.green,
                onChanged: (val) => setState(() => isStoreOpen = val),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: const [
                    Text('आज की कुल बिक्री', style: TextStyle(color: Colors.grey)),
                    SizedBox(height: 8),
                    Text('₹1,850', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green)),
                    Text('3 सफल ऑर्डर डिलीवर हुए', style: TextStyle(fontSize: 12, color: Colors.black54)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('नया सामान (Product) लिस्ट करें'),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('प्रोडक्ट जोड़ने का फॉर्म खुला')));
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// 4. OWNER ADMIN PANEL (मालिक का कंट्रोल पैनल)
// ---------------------------------------------------------
class OwnerAdminPanel extends StatelessWidget {
  const OwnerAdminPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grocey - Owner Admin'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Card(
                    color: Colors.blue.shade50,
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text('कुल दुकानें', style: TextStyle(fontSize: 14)),
                          Text('14', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    color: Colors.green.shade50,
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text('5% कुल कमिशन', style: TextStyle(fontSize: 14)),
                          Text('₹1,420', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('दुकान अप्रूवल रिक्वेस्ट (₹100 रजिस्ट्रेशन शुल्क)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  Card(
                    child: ListTile(
                      title: const Text('सैनी प्रोविजन स्टोर'),
                      subtitle: const Text('फीस: ₹100 प्राप्त हुई | 2.4 KM'),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        child: const Text('Approve', style: TextStyle(color: Colors.white)),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('दुकान अप्रूव कर दी गई!')));
                        },
                      ),
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
