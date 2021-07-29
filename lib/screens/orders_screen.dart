import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/order_item.dart';
import '../providers/orders.dart' show Orders;
import 'package:real_shop/widgets/app_drawer.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = '/orders';

  const OrdersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Order"),
      ),
      body: FutureBuilder(
        future: Provider.of<Orders>(context,listen: false).fetchAndSetOrders(),
        builder: (ctx,AsyncSnapshot snapshot){
          if(snapshot.connectionState==ConnectionState.waiting){
            return CircularProgressIndicator();
          }else{
            if(snapshot.error!=null){
              return Center(child: Text('An error occurred!'),);
            }else{
             return Consumer<Orders>(builder: (ctx,orderData,child)=> ListView.builder(
                itemCount: orderData.orders.length,
                itemBuilder: (BuildContext context,int index)=>OrderItem(orderData.orders[index]),
              ),);
            }
          }
        },
      ),
      drawer: AppDrawer(),
    );
  }
}
