import 'dart:html';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../providers/cart.dart';
import '../providers/product.dart';
import '../screens/product_detail_screen.dart';

class ProductItem extends StatelessWidget {
  const ProductItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    final auth = Provider.of<Auth>(context, listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () =>
              Navigator.of(context).pushNamed(PrductDetailScreen.routeName,arguments: product.id),
          child: Hero(
            tag: product.id,
            child: FadeInImage(
              placeholder: AssetImage(
                "assets/images/product-placeholder.png",
              ),
              image: NetworkImage(
                product.imageUrl,
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          leading: Consumer<Product>(
            builder: (ctx, product, _) => IconButton(
              onPressed: () {
                product.toggleFavoriteStatus(auth.token!, auth.userId);
              },
              color: Theme.of(context).accentColor,
              icon: Icon(
                  product.isFavorite ? Icons.favorite_border : Icons.favorite),
            ),
          ),
          title: Text(
            product.title,
            textAlign: TextAlign.center,
          ),
          trailing: IconButton(
            icon: Icon(
              (Icons.add_shopping_cart),
            ),
            color: Theme.of(context).accentColor,
            onPressed: () {
              cart.addItem(product.id, product.price, product.title);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                  "Added to cart",
                ),
                duration: Duration(
                  seconds: 2,
                ),
                action: SnackBarAction(
                  label: 'UNDO!',
                  onPressed: () {
                    cart.removeSingleItem(product.id);
                  },
                ),
              ));
            },
          ),
        ),
      ),
    );
  }
}
