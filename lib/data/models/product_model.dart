import '../../domain/entities/product.dart';

class ProductModel extends Product {
  ProductModel({
    required super.id,
    required super.name,
    required super.price,
    super.imageUrl,
    super.description,
    super.category,
    super.stock,
    super.status,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    double parsedPrice = 0.0;
    if (json['price'] != null) {
      if (json['price'] is num) {
        parsedPrice = (json['price'] as num).toDouble();
      } else if (json['price'] is String) {
        parsedPrice = double.tryParse(json['price']) ?? 0.0;
      }
    }

    String? finalImageUrl;
    if (json['image_url'] != null && json['image_url'].toString().isNotEmpty) {
      finalImageUrl = 'https://pos.cicd.web.id/assets/${json['image_url']}';
    }

    return ProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'Tanpa Nama',
      price: parsedPrice,
      imageUrl: finalImageUrl,
      description: json['description']?.toString(),
      category: json['category']?.toString(),
      stock: json['stock'] != null ? int.tryParse(json['stock'].toString()) : null,
      status: json['status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price.toStringAsFixed(0), 
      'description': description,
      'category': category,
      'stock': stock,
      'status': status ?? 'draft',
      'image_url': imageUrl, // MENGIRIM ID GAMBAR KE SERVER
    };
  }
}