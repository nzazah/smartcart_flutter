import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'cart_detail_page.dart';

class CartHistoryPage extends StatefulWidget {
  const CartHistoryPage({Key? key}) : super(key: key);

  @override
  State<CartHistoryPage> createState() => _CartHistoryPageState();
}

class _CartHistoryPageState extends State<CartHistoryPage> {
  final supabase = Supabase.instance.client;
  List<dynamic> cartList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCartHistory();
  }

  Future<void> fetchCartHistory() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final response = await supabase
          .from('carts')
          .select('*')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      setState(() {
        cartList = response;
        isLoading = false;
      });
    } catch (e) {
      print("❌ Error fetching cart history: $e");
    }
  }

  Future<void> deleteCart(int cartId) async {
    try {
      await supabase.from('carts').delete().eq('id', cartId);
      setState(() {
        cartList.removeWhere((cart) => cart['id'] == cartId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Riwayat belanja berhasil dihapus')),
      );
    } catch (e) {
      print("❌ Gagal menghapus cart: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menghapus riwayat')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Belanja')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartList.isEmpty
          ? const Center(child: Text("Belum ada riwayat belanja"))
          : ListView.builder(
        itemCount: cartList.length,
        itemBuilder: (context, index) {
          final cart = cartList[index];
          return ListTile(
            title: Text("Rencana Belanja #${cart['id']}"),
            subtitle: Text(cart['created_at']),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Konfirmasi"),
                        content: const Text("Yakin ingin menghapus riwayat ini?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Batal"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              deleteCart(cart['id']);
                            },
                            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CartDetailPage(cartId: cart['id']),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
