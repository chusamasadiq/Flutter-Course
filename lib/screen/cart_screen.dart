import 'dart:async';
import 'package:badges/badges.dart';
import 'package:flutter/material.dart' hide Badge;
import 'package:provider/provider.dart';
import '../components/button.dart';
import '../models/cart.dart';
import '../provider/cart_provider.dart';
import '../resources/auth_methods.dart';
import '../resources/db_helper.dart';
import '../utils/utils.dart';
import 'homefeed_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  DBHelper? dbHelper = DBHelper();
  List<dynamic> foodLists = [];
  List<dynamic> selectedDates = [];

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const HomeFeedScreen()));
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text('Cart'),
        centerTitle: true,
        actions: [
          InkWell(
            onTap: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const CartScreen()));
            },
            child: Center(
              child: Badge(
                badgeStyle:
                    const BadgeStyle(badgeColor: Colors.deepOrangeAccent),
                badgeContent: Consumer<CartProvider>(
                  builder: (context, value, child) {
                    return Text(
                      value.getCounter().toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
                badgeAnimation: const BadgeAnimation.fade(
                  animationDuration: Duration(milliseconds: 300),
                ),
                child: const Icon(
                  Icons.shopping_cart_outlined,
                  size: 30,
                ),
              ),
            ),
          ),
          SizedBox(width: screenWidth / 20),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FutureBuilder(
              future: cart.getData(),
              builder: (context, AsyncSnapshot<List<Cart>> snapshot) {
                if (snapshot.hasData) {
                  foodLists = snapshot.data!;
                  if (snapshot.data!.isEmpty) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(
                          child: Image(
                            height: screenWidth * 0.7,
                            image: const AssetImage(
                              'assets/images/empty_cart.png',
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Expanded(
                      child: ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: ((context, index) {
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Image(
                                        height: 100,
                                        width: 100,
                                        image: NetworkImage(
                                          snapshot.data![index].foodImage
                                              .toString(),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 15,
                                      ),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  snapshot.data![index].foodName
                                                      .toString(),
                                                  style: const TextStyle(
                                                      fontSize: 23,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    dbHelper!.delete(snapshot
                                                        .data![index].foodID!);
                                                    cart.removeCounter();
                                                    cart.removeTotalPrice(
                                                      double.parse(
                                                        snapshot.data![index]
                                                            .foodTotalPrice
                                                            .toString(),
                                                      ),
                                                    );
                                                  },
                                                  child: const Icon(
                                                    Icons.delete,
                                                    color: Colors.red,
                                                  ),
                                                )
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              snapshot
                                                  .data![index].foodTotalPrice
                                                  .toString(),
                                              style:
                                                  const TextStyle(fontSize: 22),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: InkWell(
                                                onTap: () {},
                                                child: Container(
                                                  height: 35,
                                                  width: 100,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    color: Colors.orange[500],
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            4.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        InkWell(
                                                          onTap: () {
                                                            int quantity =
                                                                snapshot
                                                                    .data![
                                                                        index]
                                                                    .quantity!;
                                                            int price = snapshot
                                                                .data![index]
                                                                .foodPrice!;
                                                            quantity--; // decrement
                                                            int? newPrice =
                                                                price *
                                                                    quantity;
                                                            if (quantity > 0) {
                                                              dbHelper!
                                                                  .updateQuantity(
                                                                      Cart(
                                                                foodID: snapshot
                                                                    .data![
                                                                        index]
                                                                    .foodID!
                                                                    .toString(),
                                                                foodName: snapshot
                                                                    .data![
                                                                        index]
                                                                    .foodName,
                                                                foodPrice: snapshot
                                                                    .data![
                                                                        index]
                                                                    .foodPrice,
                                                                foodImage: snapshot
                                                                    .data![
                                                                        index]
                                                                    .foodImage
                                                                    .toString(),
                                                                quantity:
                                                                    quantity,
                                                                deliveryCharges:
                                                                    snapshot
                                                                        .data![
                                                                            index]
                                                                        .deliveryCharges,
                                                                foodTotalPrice:
                                                                    newPrice,
                                                              ))
                                                                  .then(
                                                                      (value) {
                                                                newPrice = 0;
                                                                quantity = 0;
                                                                cart.removeTotalPrice(
                                                                    double.parse(snapshot
                                                                        .data![
                                                                            index]
                                                                        .foodPrice!
                                                                        .toString()));
                                                              }).onError((error,
                                                                      stackTrace) {
                                                                Utils.toastMessage(
                                                                    error
                                                                        .toString());
                                                              });
                                                            }
                                                          },
                                                          child: const Icon(
                                                            Icons.remove,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        Text(
                                                          snapshot.data![index]
                                                              .quantity
                                                              .toString(),
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                        InkWell(
                                                          onTap: () {
                                                            int quantity =
                                                                snapshot
                                                                    .data![
                                                                        index]
                                                                    .quantity!;
                                                            int price = snapshot
                                                                .data![index]
                                                                .foodPrice!;
                                                            quantity++; // increment
                                                            int? newPrice =
                                                                price *
                                                                    quantity;
                                                            dbHelper!
                                                                .updateQuantity(
                                                              Cart(
                                                                foodID: snapshot
                                                                    .data![
                                                                        index]
                                                                    .foodID!
                                                                    .toString(),
                                                                foodName: snapshot
                                                                    .data![
                                                                        index]
                                                                    .foodName,
                                                                foodPrice: snapshot
                                                                    .data![
                                                                        index]
                                                                    .foodPrice,
                                                                foodImage: snapshot
                                                                    .data![
                                                                        index]
                                                                    .foodImage
                                                                    .toString(),
                                                                quantity:
                                                                    quantity,
                                                                deliveryCharges:
                                                                    snapshot
                                                                        .data![
                                                                            index]
                                                                        .deliveryCharges,
                                                                foodTotalPrice:
                                                                    newPrice,
                                                              ),
                                                            )
                                                                .then((value) {
                                                              newPrice = 0;
                                                              quantity = 0;
                                                              cart.addTotalPrice(
                                                                  double.parse(snapshot
                                                                      .data![
                                                                          index]
                                                                      .foodPrice!
                                                                      .toString()));
                                                            }).onError((error,
                                                                    stackTrace) {
                                                              Utils.toastMessage(
                                                                  error
                                                                      .toString());
                                                            });
                                                          },
                                                          child: const Icon(
                                                              Icons.add,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    );
                  }
                } else {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xffFF8419),
                    ),
                  );
                }
              },
            ),
            Consumer<CartProvider>(builder: (context, value, child) {
              return Visibility(
                visible:
                    value.getTotalPrice().toStringAsFixed(2) == '0.00' // 0.00
                        ? false
                        : true,
                child: Column(
                  children: [
                    const Divider(),
                    ReusableWidget('Total Price',
                        'RS: ${value.getTotalPrice().toStringAsFixed(2)}'),
                    const Divider(),
                  ],
                ),
              );
            }),
            foodLists.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: ButtonWidget(
                        height: 0.06,
                        width: double.infinity,
                        color: const Color(0xffFF8419),
                        child: const FittedBox(
                          child: Text(
                            'Order Now',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        onPress: () async {
                          for (int i = 0; i < foodLists.length; i++) {
                            AuthMethods().orderNow(
                              foodID: foodLists[i].foodID,
                              foodName: foodLists[i].foodName,
                              foodPrice: foodLists[i].foodPrice,
                              quantity: foodLists[i].quantity,
                              foodImage: foodLists[i].foodImage,
                              deliveryCharges: foodLists[i].deliveryCharges,
                              foodTotalPrice: foodLists[i].foodTotalPrice,
                              selectedDates: selectedDates.toString(),
                            );
                            dbHelper?.deleteAll();
                            cart.resetTotalPrice();
                            cart.resetCounter();
                            Utils.toastMessage('Order Successfully');
                            AuthMethods().sendOrderDetails(
                              foodName: foodLists[i].foodName,
                              foodPrice: foodLists[i].foodPrice,
                              quantity: foodLists[i].quantity,
                              deliveryCharges: foodLists[i].deliveryCharges,
                              foodTotalPrice: foodLists[i].foodTotalPrice,
                            );
                            Timer(const Duration(seconds: 2), () {
                              Utils.showDialogMessage(
                                  'Your order will be delivered within the next three days',
                                  context);
                            });
                          }
                        }),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}

class ReusableWidget extends StatelessWidget {
  final String title, value;

  const ReusableWidget(this.title, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium,
          )
        ],
      ),
    );
  }
}
