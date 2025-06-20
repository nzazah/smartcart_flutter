import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../provider/cart_provider.dart';
import 'add_item_page.dart';

class ProductDetailPage extends StatefulWidget {
  final int productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final supabase = Supabase.instance.client;
  Map<String, dynamic>? product;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProductDetail();
  }

  Future<void> fetchProductDetail() async {
    try {
      final response = await supabase
          .from('products')
          .select()
          .eq('id', widget.productId)
          .single();

      setState(() {
        product = response;
        isLoading = false;
      });
    } catch (e) {
      print("❌ Gagal memuat detail produk: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Produk"),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cartProvider, _) {
              int itemCount = cartProvider.getTotalItems();
              return Stack(
                alignment: Alignment.topRight,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AddItemPage()),
                      );
                    },
                  ),
                  if (itemCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$itemCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : product == null
          ? const Center(child: Text("Produk tidak ditemukan."))
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: (product!['image'] != null &&
                  product!['image'].toString().isNotEmpty)
                  ? Image.network(
                product!['image'],
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                const Icon(Icons.broken_image, size: 100),
              )
                  : const Icon(Icons.image, size: 100),
            ),
            const SizedBox(height: 16),
            Text(
              product!['name'] ?? '',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _formatPrice(product!['price']),
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            Text(product!['deskripsi'] ?? ''),
            const Spacer(),
            ElevatedButton.icon(
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text("Tambah ke Keranjang"),
              onPressed: () {
                final name = product!['name'] ?? '';
                final price = (product!['price'] as num?)?.toDouble() ?? 0.0;
                final image = product!['image'] ?? '';

                Provider.of<CartProvider>(context, listen: false).addItem(
                  name,
                  price,
                  image,
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("$name ditambahkan ke keranjang"),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(dynamic price) {
    if (price == null) return "Rp 0";
    String str = price.toString();
    return "Rp " +
        str.replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => "${m[1]}.");
  }
}
