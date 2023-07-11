class Cart {
  late String? foodID;
  late final String? foodName;
  late final int? foodPrice;
  late final int? quantity;
  late String? foodImage;
  late int? deliveryCharges;
  late int? foodTotalPrice;

  Cart({
    required this.foodID,
    required this.foodName,
    required this.foodPrice,
    required this.quantity,
    required this.foodImage,
    required this.deliveryCharges,
    required this.foodTotalPrice,
  });

  Cart.fromMap(Map<dynamic, dynamic> res)
      : foodID = res['foodID'],
        foodName = res['foodName'],
        foodPrice = res['foodPrice'],
        quantity = res['quantity'],
        foodImage = res['foodImage'],
        deliveryCharges = res['deliveryCharges'],
        foodTotalPrice = res['foodTotalPrice'];

  Map<String, Object?> toMap() {
    return {
      'foodID': foodID,
      'foodName': foodName,
      'foodPrice': foodPrice,
      'quantity': quantity,
      'foodImage': foodImage,
      'deliveryCharges': deliveryCharges,
      'foodTotalPrice': foodTotalPrice,
    };
  }

  Map<String, dynamic> toJson() => {
        'foodId': foodID,
        'foodName': foodName,
        'foodPrice': foodPrice,
        'quantity': quantity,
        'foodImage': foodImage,
        'deliveryCharges': deliveryCharges,
        'foodTotalPrice': foodTotalPrice,
      };
}
