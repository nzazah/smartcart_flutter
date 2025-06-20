import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double screenWidth = constraints.maxWidth;
        bool isTablet = screenWidth >= 600;
        double basePadding = isTablet ? 24.0 : 16.0;
        double titleFontSize = isTablet ? 26 : 22;
        double subtitleFontSize = isTablet ? 18 : 14;
        double iconSize = isTablet ? 60 : 48;
        double cardHeight = isTablet ? 180 : 140;

        return Platform.isIOS
            ? CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: Text('Menu', style: TextStyle(fontSize: titleFontSize)),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              child: Icon(CupertinoIcons.heart, size: iconSize * 0.5),
              onPressed: () {},
            ),
          ),
          child: SafeArea(
            child: _buildBody(
              context,
              basePadding,
              titleFontSize,
              subtitleFontSize,
              iconSize,
              cardHeight,
              isCupertino: true,
            ),
          ),
        )
            : Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(
              'Menu',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontWeight: FontWeight.bold,
                fontSize: titleFontSize,
              ),
            ),
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            elevation: 0,
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(
                  Icons.favorite_border,
                  color: Theme.of(context).iconTheme.color,
                  size: iconSize * 0.6,
                ),
                onPressed: () {},
              ),
            ],
          ),
          body: _buildBody(
            context,
            basePadding,
            titleFontSize,
            subtitleFontSize,
            iconSize,
            cardHeight,
          ),
        );
      },
    );
  }

  Widget _buildBody(
      BuildContext context,
      double basePadding,
      double titleFontSize,
      double subtitleFontSize,
      double iconSize,
      double cardHeight, {
        bool isCupertino = false,
      }) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(basePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: isCupertino
                ? CupertinoSearchTextField(
              placeholder: 'Search for items...',
              style: TextStyle(fontSize: subtitleFontSize),
            )
                : TextField(
              decoration: InputDecoration(
                hintText: "Search for items...",
                hintStyle: TextStyle(fontSize: subtitleFontSize),
                border: InputBorder.none,
                icon: Icon(
                  Icons.search,
                  color: Colors.deepPurple,
                  size: iconSize * 0.5,
                ),
              ),
            ),
          ),
          SizedBox(height: basePadding),

          // Kategori Promo Bahan Pokok
          Column(
            children: [
              _buildMenuCard(
                "Sembako Hemat",
                "Diskon hingga 30% untuk beras, minyak, dan lainnya",
                Colors.deepPurple.shade100,
                Icons.rice_bowl,
                iconSize,
                titleFontSize,
                subtitleFontSize,
                cardHeight,
              ),
              _buildMenuCard(
                "Diskon Sayur & Buah",
                "Segar langsung dari petani lokal",
                Colors.deepPurple.shade200,
                Icons.eco,
                iconSize,
                titleFontSize,
                subtitleFontSize,
                cardHeight,
              ),
              _buildMenuCard(
                "Promo Daging & Telur",
                "Potongan harga spesial minggu ini",
                Colors.deepPurple.shade300,
                Icons.set_meal,
                iconSize,
                titleFontSize,
                subtitleFontSize,
                cardHeight,
              ),
              _buildMenuCard(
                "Cashback Minuman Segar",
                "Dapatkan cashback hingga 20%",
                Colors.deepPurpleAccent.shade100,
                Icons.local_drink,
                iconSize,
                titleFontSize,
                subtitleFontSize,
                cardHeight,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
      String title,
      String subtitle,
      Color color,
      IconData iconData,
      double iconSize,
      double titleFontSize,
      double subtitleFontSize,
      double height,
      ) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 16.0),
      padding: EdgeInsets.all(16.0),
      constraints: BoxConstraints(minHeight: height),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(iconSize * 0.2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, size: iconSize, color: Colors.white),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: subtitleFontSize,
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
