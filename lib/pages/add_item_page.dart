import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../provider/cart_provider.dart';

class AddItemPage extends StatefulWidget {
  @override
  _AddItemPageState createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  double userBudget = 0.0;
  final TextEditingController budgetController = TextEditingController();
  final supabase = Supabase.instance.client;

  void _showOverBudgetDialog() {
    final dialog = Platform.isIOS
        ? CupertinoAlertDialog(
      title: Text("Budget Melebihi!"),
      content: Text("Total belanja Anda melebihi anggaran."),
      actions: [
        CupertinoDialogAction(
          child: Text("OK"),
          onPressed: () => Navigator.pop(context),
        )
      ],
    )
        : AlertDialog(
      title: Text("Budget Melebihi!"),
      content: Text("Total belanja Anda melebihi anggaran."),
      actions: [
        TextButton(
          child: Text("OK"),
          onPressed: () => Navigator.pop(context),
        )
      ],
    );

    showDialog(context: context, builder: (_) => dialog);
  }

  Future<void> _saveCartToDatabase() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final cart = cartProvider.cart;

    if (cart.isEmpty) return;

    try {
      final cartInsert = await supabase.from('carts').insert({
        'user_id': user.id,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      }).select().single();

      final cartId = cartInsert['id'];

      final List<Map<String, dynamic>> cartItemsData = [];

      for (var entry in cart.entries) {
        final name = entry.key;
        final qty = entry.value;
        final productResult = await supabase
            .from('products')
            .select('id')
            .eq('name', name)
            .maybeSingle();

        final productId = productResult?['id'];
        if (productId != null) {
          cartItemsData.add({
            'cart_id': cartId,
            'product_id': productId,
            'quantity': qty,
            'created_at': DateTime.now().toUtc().toIso8601String(),
          });
        }
      }

      if (cartItemsData.isNotEmpty) {
        await supabase.from('cart_items').insert(cartItemsData);
      }

      cartProvider.clearCart();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Rencana belanja disimpan ke database."),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print("❌ Gagal menyimpan: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal menyimpan rencana belanja."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cartProvider = Provider.of<CartProvider>(context);
    final cart = cartProvider.cart;
    final total = cartProvider.getTotal();
    final isOverBudget = total > userBudget;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Keranjang"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildBudgetInput(theme),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: cart.entries.map((entry) {
                  final item = entry.key;
                  final qty = entry.value;
                  final price = cartProvider.prices[item] ?? 0;
                  final imageUrl = cartProvider.images[item] ?? "";
                  return _buildCartItem(theme, item, qty, price, imageUrl);
                }).toList(),
              ),
            ),
            _buildPriceSummary(theme, total),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: Icon(Icons.save),
              label: Text("Simpan Rencana Belanja"),
              onPressed: _saveCartToDatabase,
            ),
            if (userBudget > 0 && isOverBudget)
              ElevatedButton.icon(
                icon: const Icon(Icons.warning),
                label: const Text("Perhatian: Budget Melebihi"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: _showOverBudgetDialog,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetInput(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Budget Anda:",
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: budgetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: "Masukkan budget",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  userBudget = double.tryParse(budgetController.text) ?? 0.0;
                });
              },
              child: const Text("Set"),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCartItem(
      ThemeData theme, String item, int qty, double price, String imageUrl) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Icon(Icons.broken_image, size: 60),
              )
                  : Icon(Icons.image, size: 60),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item, style: theme.textTheme.bodyLarge),
                  Text("Rp ${price.toStringAsFixed(3)}"),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                  onPressed: () => cartProvider.removeItem(item),
                ),
                Text("$qty"),
                IconButton(
                  icon: Icon(Icons.add_circle_outline,
                      color: theme.colorScheme.primary),
                  onPressed: () =>
                      cartProvider.addItem(item, price, imageUrl),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSummary(ThemeData theme, double total) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Total",
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          Text("Rp ${total.toStringAsFixed(3)}",
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
