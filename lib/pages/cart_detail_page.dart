import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CartDetailPage extends StatefulWidget {
  final int cartId;

  const CartDetailPage({Key? key, required this.cartId}) : super(key: key);

  @override
  State<CartDetailPage> createState() => _CartDetailPageState();
}

class _CartDetailPageState extends State<CartDetailPage> {
  final supabase = Supabase.instance.client;
  List<dynamic> cartItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  Future<void> fetchCartItems() async {
    try {
      final response = await supabase
          .from('cart_items')
          .select('quantity, created_at, products(name, price, image)')
          .eq('cart_id', widget.cartId);

      setState(() {
        cartItems = response;
        isLoading = false;
      });
    } catch (e) {
      print("❌ Error fetching cart items: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Detail Rencana #${widget.cartId}")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: cartItems.length,
        itemBuilder: (context, index) {
          final item = cartItems[index];
          final product = item['products'];
          return ListTile(
            leading: product['image'] != null
                ? Image.network(product['image'], width: 50, height: 50)
                : const Icon(Icons.image),
            title: Text(product['name']),
            subtitle: Text("Jumlah: ${item['quantity']}"),
            trailing: Text("Rp ${product['price']}"),
          );
        },
      ),
    );
  }
}
