import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttercourse/screen/food_description.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/cart.dart';
import '../provider/cart_provider.dart';
import '../resources/db_helper.dart';
import '../utils/utils.dart';
import 'cart_screen.dart';

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({Key? key}) : super(key: key);

  @override
  State<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  DBHelper? dbHelper = DBHelper();
  bool isLoading = true;
  List<DocumentSnapshot> foodList = [];

  @override
  void initState() {
    super.initState();
    fetchFoodData();
  }

  // Fetch food data using StreamBuilder and pagination
  void fetchFoodData() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('food').limit(10).get();

      setState(() {
        foodList = snapshot.docs;
        isLoading = false;
      });
    } catch (error) {
      Utils.toastMessage('Something went wrong');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context); // reference
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favourite'),
        actions: [
          InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CartScreen(),
              ),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Badge(
                  backgroundColor: Colors.orange,
                  label: Consumer<CartProvider>(
                    builder: (context, value, child) {
                      return Text(
                        value.getCounter().toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                  child: const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(Icons.shopping_cart),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'All available favourite food',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xffFF8419),
                      ),
                    )
                  : foodList.isEmpty
                      ? const Center(
                          child: Text('No data available.'),
                        )
                      : GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.68,
                          ),
                          itemCount: foodList.length,
                          itemBuilder: (BuildContext context, index) {
                            final foodItem = foodList[index];
                            return InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FoodDescription(
                                    foodName: foodItem['foodName'],
                                    foodImage: foodItem['foodImage'],
                                    foodPrice: foodItem['foodPrice'],
                                    deliveryCharges:
                                        foodItem['deliveryCharges'],
                                    deliveryTime: foodItem['deliveryTime'],
                                    foodRatings: foodItem['ratings'],
                                    foodDescription:
                                        foodItem['foodDescription'],
                                  ),
                                ),
                              ),
                              child: Ink(
                                height: 200,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        foodList[index]['foodImage'],
                                        fit: BoxFit.cover,
                                        height: 150,
                                        width: double.infinity,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      foodItem['foodName'],
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'Price: ${foodItem['foodPrice'].toString()}/-',
                                    ),
                                    const SizedBox(height: 5),
                                    ElevatedButton(
                                      onPressed: () {
                                        dbHelper!.insert(
                                          Cart(foodID: foodItem['foodID'].toString(),
                                            foodName:
                                            foodItem['foodName'].toString(),
                                            foodPrice: foodItem['foodPrice'],
                                            quantity: foodItem['quantity'],
                                            foodImage: foodItem['foodImage'].toString(),
                                            deliveryCharges: foodItem['deliveryCharges'],
                                            foodTotalPrice: foodItem['foodPrice'],
                                          ),
                                        )
                                            .then((value) {
                                          Utils.toastMessage("Product is Added to Cart");
                                          cart.addTotalPrice(double.parse(foodItem['foodPrice'].toString()));
                                          cart.addCounter();
                                        }).catchError((error) {
                                          if (error is DatabaseException) {
                                            if (error.toString().contains('UNIQUE constraint failed')) {
                                              Utils.toastMessage("Product is already in the Cart");
                                            } else {
                                              Utils.toastMessage("Error occurred while adding the product");
                                            }
                                          } else {
                                            Utils.toastMessage("Error occurred while adding the product");
                                          }
                                        });
                                      },
                                      child: const Text('Add to Cart'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
