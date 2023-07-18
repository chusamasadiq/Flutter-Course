import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttercourse/provider/cart_provider.dart';
import 'package:fluttercourse/resources/getlocation.dart';
import 'package:fluttercourse/screen/favourite_screen.dart';
import 'package:fluttercourse/utils/utils.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'cart_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double? lan;
  double? lat;
  String? userLocation;

  getUserLocation() {
    Future<Position> location = GetUserLocation().getCurrentLocation();
    location.then(
      (value) {
        lat = value.latitude;
        lan = value.longitude;

        getLocationFromLatLng(value.latitude, value.longitude);
      },
    ).catchError(
      (error) {
        return Utils.toastMessage(error.toString());
      },
    );
  }
  // Get Location from Latitude and Longitude
  Future<void> getLocationFromLatLng(latitude, longitude) async {
    List<Placemark> placeMarks = await placemarkFromCoordinates(latitude, longitude);
    Placemark place = placeMarks[0];
    if (mounted) {
      setState(() {
        userLocation = '${place.locality}, ${place.country}';
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserLocation();
  }

  @override
  void dispose() {
    lat = null;
    lan = null;
    userLocation = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Delivery App'),
          automaticallyImplyLeading: false,
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
                        style:
                            const TextStyle(fontSize: 12, color: Colors.white),
                      );
                    }),
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
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Hi, Fabien',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  CircleAvatar(
                    backgroundImage: AssetImage('assets/images/avatar.png'),
                  )
                ],
              ),
              ListTile(
                contentPadding: const EdgeInsets.only(left: 0),
                leading: const Icon(Icons.location_on),
                title: userLocation != null
                    ? Text(userLocation.toString())
                    : const Text('Turn on Location'),
                minLeadingWidth: 5,
                horizontalTitleGap: 5,
              ),
              Container(
                height: screenHeight / 15,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextFormField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                    label: Text('Search Food'),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 5),
                child: Text(
                  'Categories',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              SizedBox(
                height: screenHeight / 5,
                child: FutureBuilder<QuerySnapshot>(
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
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: foodList.length,
                      itemBuilder: (BuildContext context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Column(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.orangeAccent,
                                    ),
                                  ),
                                  child: AspectRatio(
                                    aspectRatio: 4 / 3,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        foodList[index]['foodImage'],
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                foodList[index]['foodName'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: screenHeight / 75),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Menu'),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FavouriteScreen(),
                      ),
                    ),
                    child: const Text(
                      'View all',
                      style: TextStyle(color: Colors.orange),
                    ),
                  )
                ],
              ),
              SizedBox(height: screenHeight / 50),
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

                    return ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: foodList.length,
                      itemBuilder: (BuildContext context, index) {
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Container(
                                height: screenHeight / 4,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.orangeAccent,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(
                                        foodList[index]['foodImage']),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
