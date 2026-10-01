import '../entities/product.dart';
import '../repositories/product_repository.dart';

class AddProduct {
  final ProductRepository repository;

  AddProduct(this.repository);

  Future<bool> execute(Product product) {
    return repository.addProduct(product);
  }
}