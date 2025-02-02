import 'package:equatable/equatable.dart';

import '../../store_items/models/product_model.dart';

class CartModel extends Equatable {
  final List<ProductModel> products;

  const CartModel({required this.products});

  double get subtotalPrice =>
      products.fold(0, (total, current) => total + current.price);

  String get totalItems => products.length.toString();

  double deliveryFee(totalPrice) {
    if (totalPrice >= 30) {
      return 0;
    } else {
      return 10;
    }
  }

  String freeDelivery(totalPrice) {
    if (totalPrice > 30) {
      return "You have Free Delivery";
    } else {
      double remaining = 30.0 - totalPrice;
      return "Add \$${remaining.toStringAsFixed(2)} to get free Delivery";
    }
  }

  double totalAmount(totalPrice, deliveryFee) {
    return totalPrice + deliveryFee(totalPrice);
  }

  @override
  List<Object?> get props => [
        products,
        subtotalPrice,
        totalItems,
        deliveryFee,
        freeDelivery,
        totalAmount
      ];
}
