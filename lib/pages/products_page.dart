import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  String selectedCategory = "All";
  final List<String> categories = ["All", "Fresh", "Frozen", "Drinks", "Snacks"];

  final List<Map<String, dynamic>> items = [
    {"name": "Beras Premium", "price": 50000, "icon": Icons.rice_bowl},
    {"name": "Minyak Goreng", "price": 32000, "icon": Icons.oil_barrel},
    {"name": "Telur Ayam", "price": 28000, "icon": Icons.egg},
    {"name": "Gula Pasir", "price": 14000, "icon": Icons.cookie},
    {"name": "Susu UHT", "price": 18000, "icon": Icons.local_drink},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Platform.isIOS
        ? CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("Products"),
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      child: SafeArea(
        child: _buildBody(theme),
      ),
    )
        : Scaffold(
      appBar: AppBar(
        title: Text("Products"),
        centerTitle: true,
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth;
        bool isTablet = width >= 600;
        int crossAxisCount = width >= 900 ? 4 : width >= 600 ? 3 : 2;
        double iconSize = isTablet ? 56 : 48;
        double padding = isTablet ? 20 : 16;
        double fontSize = isTablet ? 18 : 14;

        return CupertinoScrollbar(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildSearchBar(theme, padding, fontSize)),
              SliverToBoxAdapter(child: _buildCategorySelector(theme, padding, fontSize)),
              SliverPadding(
                padding: EdgeInsets.all(padding),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildProductCard(theme, items[index], iconSize, fontSize),
                    childCount: items.length,
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                ),
              ),
            ],
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
        placeholder: "Search Products",
        style: TextStyle(fontSize: fontSize),
      )
          : TextField(
        decoration: InputDecoration(
          hintText: "Search Products",
          hintStyle: TextStyle(fontSize: fontSize),
          prefixIcon: Icon(Icons.search),
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
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: ChoiceChip(
                label: Text(category, style: TextStyle(fontSize: fontSize)),
                selected: selectedCategory == category,
                onSelected: (selected) {
                  setState(() {
                    selectedCategory = category;
                  });
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
    return Container(
      padding: EdgeInsets.all(12),
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
          Container(
            padding: EdgeInsets.all(iconSize * 0.25),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              product["icon"],
              size: iconSize,
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(height: 12),
          Text(
            product["name"],
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            "Rp ${product["price"]}",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontSize: fontSize - 2,
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (Platform.isIOS)
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Icon(CupertinoIcons.heart, color: Colors.red),
                  onPressed: () {},
                )
              else
                IconButton(
                  icon: Icon(Icons.favorite_border, color: Colors.red),
                  onPressed: () {},
                ),
              if (Platform.isIOS)
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Icon(CupertinoIcons.add_circled, color: Colors.orange),
                  onPressed: () {},
                )
              else
                IconButton(
                  icon: Icon(Icons.add_circle, color: Colors.orange),
                  onPressed: () {},
                ),
            ],
          ),
        ],
      ),
    );
  }
}
