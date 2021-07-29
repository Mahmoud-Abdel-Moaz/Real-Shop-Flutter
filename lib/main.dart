import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:real_shop/providers/auth.dart';
import 'package:real_shop/providers/cart.dart';
import 'package:real_shop/providers/orders.dart';
import 'package:real_shop/providers/product.dart';
import 'package:real_shop/providers/products.dart';
import 'package:real_shop/screens/auth_screen.dart';
import 'package:real_shop/screens/cart.screen.dart';
import 'package:real_shop/screens/edit_product_screen.dart';
import 'package:real_shop/screens/orders_screen.dart';
import 'package:real_shop/screens/product_detail_screen.dart';
import 'package:real_shop/screens/product_overview_screen.dart';
import 'package:real_shop/screens/splash_screen.dart';
import 'package:real_shop/screens/user_product_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: Auth()),
        ChangeNotifierProvider.value(value: Cart()),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (_) => Orders(),
          update: (ctx, authValue, previousOrders) => previousOrders
            ..getData(
              authValue.token,
              authValue.userId,
              previousOrders==null?[]:previousOrders.orders,
            ),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          create: (_) => Products(),
          update: (ctx, authValue, previousProducts) => previousProducts
            ..getData(
              authValue.token,
              authValue.userId,
              previousProducts==null?[]:previousProducts.items,
            ),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'Flutter Demo',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.purple,
            accentColor: Colors.deepOrange,
            fontFamily: 'Lato',
          ),
          home: auth.isAuth
              ? ProductOverviewScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) =>
                      snapshot.connectionState == ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen(),
                ),
          routes: {
            // '/': (ctx) => ProductOverviewScreen(),
            PrductDetailScreen.routeName: (ctx) => PrductDetailScreen(),
            AuthScreen.routeName: (ctx) => AuthScreen(),
            CartScreen.routeName: (ctx) => CartScreen(),
            EditProductScreen.routeName: (ctx) => EditProductScreen(),
            OrdersScreen.routeName: (ctx) => OrdersScreen(),
            SplashScreen.routeName: (ctx) => SplashScreen(),
            UserProductScreen.routeName: (ctx) => UserProductScreen(),
          },
        ),
      ),
    );
  }
}
