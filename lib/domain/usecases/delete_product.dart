import '../repositories/product_repository.dart';

class DeleteProduct {
  final ProductRepository repository;

  DeleteProduct(this.repository);

  Future<bool> execute(String id) async {
    return await repository.deleteProduct(id);
  }
}