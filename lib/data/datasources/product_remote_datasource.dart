import 'dart:io';
import '../../../core/network/api_service.dart';
import '../models/product_model.dart';

class ProductRemoteDataSource {
  final ApiService apiService;
  ProductRemoteDataSource({required this.apiService});

  Future<List<ProductModel>> getProducts() async {
    final dynamic responseData = await apiService.get('items/products');
    List<dynamic> jsonList = [];
    if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
      jsonList = responseData['data'] ?? [];
    } else if (responseData is List) {
      jsonList = responseData;
    }
    return jsonList.map((json) => ProductModel.fromJson(json)).toList();
  }

  Future<bool> addProduct(ProductModel product) async {
    final response = await apiService.post('items/products', product.toJson());
    return response != null;
  }

  Future<bool> updateProduct(String id, Map<String, dynamic> data) async {
    final response = await apiService.patch('items/products/$id', data);
    return response != null;
  }

  Future<bool> deleteProduct(String id) async {
    final response = await apiService.delete('items/products/$id');
    return response == true;
  }

  Future<String> uploadImage(File file) async {
    return await apiService.uploadFile(file);
  }
}