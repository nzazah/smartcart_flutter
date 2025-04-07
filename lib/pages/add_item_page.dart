import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddItemPage extends StatefulWidget {
  @override
  _AddItemPageState createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  Map<String, int> cart = {
    "Beras Premium 5kg": 1,
    "Minyak Goreng 2L": 1,
  };

  Map<String, double> prices = {
    "Beras Premium 5kg": 65.00,
    "Minyak Goreng 2L": 35.00,
    "Delivery": 5.00,
  };

  double userBudget = 0.0;
  final TextEditingController budgetController = TextEditingController();

  void _increaseItem(String item) {
    setState(() {
      cart[item] = cart[item]! + 1;
    });
  }

  void _decreaseItem(String item) {
    setState(() {
      if (cart[item]! > 1) {
        cart[item] = cart[item]! - 1;
      } else {
        cart.remove(item);
      }
    });
  }

  double _calculateTotal() {
    double total = 0;
    cart.forEach((item, quantity) {
      total += prices[item]! * quantity;
    });
    total += prices["Delivery"]!;
    return total;
  }

  bool _isOverBudget() {
    return _calculateTotal() > userBudget;
  }

  void _showOverBudgetDialog() {
    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: Text("Budget Melebihi!"),
          content: Text("Total belanja Anda melebihi anggaran."),
          actions: [
            CupertinoDialogAction(
              child: Text("OK"),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Budget Melebihi!"),
          content: Text("Total belanja Anda melebihi anggaran."),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Keranjang Saya", style: theme.textTheme.titleLarge),
        centerTitle: true,
        leading: Platform.isIOS
            ? CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(CupertinoIcons.back, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        )
            : IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth >= 600;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildBudgetInput(theme),
                SizedBox(height: 12),
                Expanded(
                  child: ListView(
                    children: cart.keys.map((item) {
                      return _buildCartItem(theme, item, isTablet);
                    }).toList(),
                  ),
                ),
                _buildPriceSummary(theme),
                if (_isOverBudget())
                  Platform.isIOS
                      ? CupertinoButton.filled(
                    child: Text("Perhatian: Budget Melebihi"),
                    onPressed: _showOverBudgetDialog,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                  )
                      : Padding(
                    padding: EdgeInsets.all(8),
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.warning),
                      label: Text("Perhatian: Budget Melebihi"),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent),
                      onPressed: _showOverBudgetDialog,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBudgetInput(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Budget Anda:",
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        Row(
          children: [
            Expanded(
              child: Platform.isIOS
                  ? CupertinoTextField(
                controller: budgetController,
                placeholder: "Masukkan budget",
                keyboardType: TextInputType.number,
              )
                  : TextField(
                controller: budgetController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Masukkan budget",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(width: 8),
            Platform.isIOS
                ? CupertinoButton(
              child: Text("Set"),
              onPressed: () {
                setState(() {
                  userBudget = double.tryParse(budgetController.text) ?? 0.0;
                });
              },
            )
                : ElevatedButton(
              onPressed: () {
                setState(() {
                  userBudget = double.tryParse(budgetController.text) ?? 0.0;
                });
              },
              child: Text("Set"),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCartItem(ThemeData theme, String item, bool isTablet) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          children: [
            Icon(Icons.shopping_cart, size: isTablet ? 50 : 40, color: theme.colorScheme.primary),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item, style: theme.textTheme.bodyLarge),
                  Text("Rp ${prices[item]!.toStringAsFixed(3)}"),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.remove_circle_outline, color: Colors.red),
                  onPressed: () => _decreaseItem(item),
                ),
                Text("${cart[item]}"),
                IconButton(
                  icon: Icon(Icons.add_circle_outline, color: theme.colorScheme.primary),
                  onPressed: () => _increaseItem(item),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSummary(ThemeData theme) {
    final total = _calculateTotal();
    return Container(
      margin: EdgeInsets.only(top: 12),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Total", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          Text("Rp ${total.toStringAsFixed(3)}",
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
