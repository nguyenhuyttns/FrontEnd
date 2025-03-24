import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/cart_item.dart';
import '../view_models/cart_view_model.dart';

class CartItemWidget extends StatelessWidget {
  final CartItem item;

  const CartItemWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartViewModel>(context, listen: false);

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          builder:
              (ctx) => AlertDialog(
                title: const Text('Remove Item'),
                content: Text(
                  'Do you want to remove ${item.name} from your cart?',
                ),
                actions: [
                  TextButton(
                    child: const Text('No'),
                    onPressed: () {
                      Navigator.of(ctx).pop(false);
                    },
                  ),
                  TextButton(
                    child: const Text('Yes'),
                    onPressed: () {
                      Navigator.of(ctx).pop(true);
                    },
                  ),
                ],
              ),
        );
      },
      onDismissed: (direction) {
        cart.removeItem(item.productId);
      },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        child: const Icon(Icons.delete, color: Colors.white, size: 30),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: item.imageUrl,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                placeholder:
                    (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                errorWidget:
                    (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported, size: 40),
                    ),
              ),
            ),
            title: Text(
              item.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('\$${item.price.toStringAsFixed(2)}'),
                const SizedBox(height: 4),
                Text(
                  'Total: \$${(item.price * item.quantity).toStringAsFixed(2)}',
                ),
              ],
            ),
            trailing: SizedBox(
              width: 120,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      cart.updateQuantity(item.productId, item.quantity - 1);
                    },
                    color: Theme.of(context).primaryColor,
                  ),
                  Text(
                    '${item.quantity}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      cart.updateQuantity(item.productId, item.quantity + 1);
                    },
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
