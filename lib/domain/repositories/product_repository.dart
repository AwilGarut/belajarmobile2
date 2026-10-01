import 'dart:io';
import '../entities/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts();
  Future<bool> addProduct(Product product);
  Future<bool> updateProduct(String id, Map<String, dynamic> data);
  Future<bool> deleteProduct(String id);
  Future<String> uploadImage(File file);
}