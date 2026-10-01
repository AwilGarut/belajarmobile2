import '../repositories/product_repository.dart';

class UpdateProduct {
  final ProductRepository repository;

  UpdateProduct(this.repository);

  Future<bool> execute(String id, Map<String, dynamic> data) async {
    return await repository.updateProduct(id, data);
  }
}