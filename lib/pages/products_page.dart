import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'add_item_page.dart';
import 'product_detail_page.dart';
import '../provider/cart_provider.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  String selectedCategory = "All";
  final List<String> categories = ["All", "Fresh", "Frozen", "Drinks", "Snacks"];
  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> allItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final response = await Supabase.instance.client
          .from('products')
          .select('*')
          .order('created_at', ascending: false);

      allItems = List<Map<String, dynamic>>.from(response);
      applyFilter();
    } catch (e) {
      print("❌ Gagal fetch produk: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void applyFilter() {
    String query = searchController.text.toLowerCase();

    setState(() {
      items = allItems.where((product) {
        final matchCategory = selectedCategory == "All" || product["category"] == selectedCategory;
        final matchSearch = product["name"].toLowerCase().contains(query);
        return matchCategory && matchSearch;
      }).toList();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Platform.isIOS
        ? CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text("Products"),
        backgroundColor: theme.scaffoldBackgroundColor,
        trailing: _buildCartIcon(),
      ),
      child: SafeArea(child: _buildBody(theme)),
    )
        : Scaffold(
      appBar: AppBar(
        title: const Text("Products"),
        centerTitle: true,
        actions: [_buildCartIcon()],
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildCartIcon() {
    return Consumer<CartProvider>(
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
                  MaterialPageRoute(builder: (context) => AddItemPage()),
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
    );
  }

  Widget _buildBody(ThemeData theme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth;
        int crossAxisCount = width >= 900 ? 4 : width >= 600 ? 3 : 2;
        double iconSize = width >= 600 ? 56 : 48;
        double padding = width >= 600 ? 20 : 16;
        double fontSize = width >= 600 ? 18 : 14;

        return CupertinoScrollbar(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildSearchBar(theme, padding, fontSize),
                _buildCategorySelector(theme, padding, fontSize),
                Padding(
                  padding: EdgeInsets.all(padding),
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : items.isEmpty
                      ? const Center(child: Text("Tidak ada produk."))
                      : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemBuilder: (context, index) => _buildProductCard(
                      theme,
                      items[index],
                      iconSize,
                      fontSize,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(ThemeData theme, double padding, double fontSize) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Platform.isIOS
          ? CupertinoSearchTextField(
        controller: searchController,
        onChanged: (value) => applyFilter(),
        placeholder: "Search Products",
        style: TextStyle(fontSize: fontSize),
      )
          : TextField(
        controller: searchController,
        onChanged: (value) => applyFilter(),
        decoration: InputDecoration(
          hintText: "Search Products",
          hintStyle: TextStyle(fontSize: fontSize),
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: theme.cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
        style: TextStyle(fontSize: fontSize),
      ),
    );
  }

  Widget _buildCategorySelector(ThemeData theme, double padding, double fontSize) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: categories.map((category) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: ChoiceChip(
                label: Text(category, style: TextStyle(fontSize: fontSize)),
                selected: selectedCategory == category,
                onSelected: (selected) {
                  setState(() {
                    selectedCategory = category;
                  });
                  applyFilter();
                },
                selectedColor: theme.colorScheme.secondary.withOpacity(0.5),
                backgroundColor: theme.cardColor,
                labelStyle: TextStyle(
                  color: selectedCategory == category
                      ? theme.colorScheme.onSecondary
                      : theme.textTheme.bodyMedium?.color,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildProductCard(ThemeData theme, Map<String, dynamic> product, double iconSize, double fontSize) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailPage(productId: product['id']),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.05),
              blurRadius: 4,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            product["image"] != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                product["image"],
                height: iconSize + 10,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.broken_image, size: iconSize, color: Colors.grey),
              ),
            )
                : Icon(Icons.image, size: iconSize, color: theme.primaryColor),
            const SizedBox(height: 12),
            Text(
              product["name"] ?? "Produk",
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: fontSize,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              _formatPrice(product["price"] ?? 0),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontSize: fontSize - 2,
              ),
            ),
            if (product["deskripsi"] != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  product["deskripsi"],
                  style: TextStyle(fontSize: fontSize - 3, color: theme.hintColor),
                  textAlign: TextAlign.center,
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.favorite_border, color: Colors.red),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.orange),
                  onPressed: () {
                    Provider.of<CartProvider>(context, listen: false).addItem(
                      product['name'],
                      (product['price'] as num).toDouble(),
                      product['image'] ?? '',
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Produk ditambahkan ke keranjang"),
                        duration: Duration(seconds: 2),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(dynamic price) {
    if (price == null) return "Rp 0";
    String str = price.toString();
    return "Rp " + str.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => "${m[1]}.");
  }
}
