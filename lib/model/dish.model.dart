import 'package:cloud_firestore/cloud_firestore.dart';

class DishModel {
  final String dishId;
  final String dishName;
  final String category; //mains, desserts, etc
  final String description;

  final String kitchenId;
  final String kitchenName;
  final List<String> images; // 👈 array of image URLs
  final bool isVeg;
  final List<String> ingredients;
  final double price;
  final int qntAvailable;
  final int qntTotal;
  final int preparationTime;
  final double rating;
  final int ordersCount;
  final String mealCategory;
  final DateTime createdAt;
  final String ownerName;
  final String ownerProfileImage;
  final bool isAvailable;

  DishModel({
    required this.dishId,
    required this.dishName,
    required this.category,
    required this.description,

    required this.kitchenId,
    required this.kitchenName,
    required this.images,
    required this.isVeg,
    required this.ingredients,

    required this.price,
    required this.qntAvailable,
    required this.qntTotal,

    required this.preparationTime,
    required this.rating,
    required this.ordersCount,
    required this.mealCategory,

    required this.createdAt,
    required this.ownerName,
    required this.ownerProfileImage,
    required this.isAvailable,
  });

  /// Firestore -> Dart
  factory DishModel.fromMap(Map<String, dynamic> map) {
    return DishModel(
      dishId: map['dish_id'] ?? '', //s
      dishName: map['dish_name'] ?? '', //
      description: map['description'] ?? '', //
      category: map['category'] ?? '', //
      kitchenId: map['kitchen_id'] ?? '', //
      kitchenName: map['kitchen_name'] ?? 'Unknown', //
      images: List<String>.from(map['image'] ?? ['']), // 👈 image array
      isVeg: map['isVeg'] ?? false,
      ingredients: map['ingredients'] ?? [],
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      qntAvailable: map['qnt_available'] ?? 0,
      qntTotal: map['qnt_total'] ?? 0,
      preparationTime: map['preparation_time'] ?? 0,
      rating: map['rating'] ?? 5,
      ordersCount: map['orders_count'] ?? 0,
      mealCategory:
          map['meal_category'] ??
          'Lunch', // e.g., "Breakfast", "Lunch", "Dinner",
      createdAt: (map['created_at'] as Timestamp).toDate(),
      ownerName: map['owner_name'] ?? 'unknown',
      ownerProfileImage: map['owner_profile_image'] ?? 'unknown',
      isAvailable: map['is_available'] ?? false,
    );
  }

  /// Dart -> Firestore

  Map<String, dynamic> toMap() {
    return {
      'dish_id': dishId,
      'dish_name': dishName,
      'description': description,
      'category': category,

      'kitchen_id': kitchenId,
      'kitchen_name': kitchenName,

      'image': images,

      'isVeg': isVeg,
      'ingredients': ingredients,

      'price': price,
      'qnt_available': qntAvailable,
      'qnt_total': qntTotal,

      'preparation_time': preparationTime,
      'rating': rating,
      'orders_count': ordersCount,
      'meal_category': mealCategory,

      'created_at': Timestamp.fromDate(createdAt),

      'owner_name': ownerName,
      'owner_profile_image': ownerProfileImage,

      'is_available': isAvailable,
    };
  }
}
