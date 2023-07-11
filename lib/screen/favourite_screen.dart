import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttercourse/screen/food_description.dart';
import 'package:provider/provider.dart';

import '../models/cart.dart';
import '../provider/cart_provider.dart';
import '../resources/db_helper.dart';
import '../utils/utils.dart';

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({Key? key}) : super(key: key);

  @override
  State<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  DBHelper? dbHelper = DBHelper();

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context); // reference
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favourite'),
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
              child: FutureBuilder(
                future: FirebaseFirestore.instance.collection('food').get(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    if (snapshot.hasError) {
                      return Utils.toastMessage('Some went wrong');
                    }
                    return const Center(child: CircularProgressIndicator());
                  }
                  final List<DocumentSnapshot> foodList = snapshot.data!.docs;
                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Means Number of Item in a Row
                      crossAxisSpacing: 10, // For Spacing
                      mainAxisSpacing: 10, // For Spacing
                      childAspectRatio: 0.68, // For Size of the GridView Item
                    ),
                    itemCount: foodList.length,
                    itemBuilder: (BuildContext context, index) {
                      return InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FoodDescription(
                              foodName: foodList[index]['foodName'],
                              foodImage: foodList[index]['foodImage'],
                              foodPrice: foodList[index]['foodPrice'],
                              deliveryCharges: foodList[index]['deliveryCharges'],
                              deliveryTime: foodList[index]['deliveryTime'],
                              foodRatings: foodList[index]['ratings'],
                              foodDescription: foodList[index]['foodDescription'],
                            ),
                          ),
                        ),
                        child: Ink(
                          height: 200,
                          decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12)),
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
                                foodList[index]['foodName'],
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                  'Price: ${foodList[index]['foodPrice'].toString()}/-'),
                              const SizedBox(height: 5),
                              ElevatedButton(
                                onPressed: () {
                                  dbHelper!.insert(
                                    Cart(
                                      foodID: foodList[index]['foodID'].toString(),
                                      foodName: foodList[index]['foodName'].toString(),
                                      foodPrice: foodList[index]['foodPrice'],
                                      quantity: foodList[index]['quantity'],
                                      foodImage: foodList[index]['foodImage'].toString(),
                                      deliveryCharges: foodList[index]['deliveryCharges'],
                                      foodTotalPrice: foodList[index]['foodPrice'],
                                    ),
                                  )
                                      .then((value) {
                                    Utils.toastMessage("Product is Added to Cart");
                                    cart.addTotalPrice(double.parse(foodList[index]['foodPrice'].toString(),
                                      ),
                                    );
                                    cart.addCounter();
                                  }).onError((error, stackTrace) {
                                    Utils.toastMessage(error.toString());
                                  });
                                },
                                child: const Text('Add to Cart'),
                              )
                            ],
                          ),
                        ),
                      );
                    },
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
