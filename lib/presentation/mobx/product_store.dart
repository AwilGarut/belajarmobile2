import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:mobx/mobx.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/add_product.dart';
import '../../domain/usecases/get_products.dart';
import '../../domain/usecases/update_product.dart';
import '../../domain/usecases/delete_product.dart';
import '../../domain/usecases/upload_image.dart';

part 'product_store.g.dart';

// ignore: library_private_types_in_public_api
class ProductStore = _ProductStore with _$ProductStore;

abstract class _ProductStore with Store {
  final GetProducts getProductsUseCase;
  final AddProduct addProductUseCase;
  final UpdateProduct updateProductUseCase;
  final DeleteProduct deleteProductUseCase;
  final UploadImage uploadImageUseCase;

  _ProductStore({
    required this.getProductsUseCase,
    required this.addProductUseCase,
    required this.updateProductUseCase,
    required this.deleteProductUseCase,
    required this.uploadImageUseCase,
  }) {
    _disposers = [
      reaction((_) => errorMessage, (String? message) {
        if (message != null && message.isNotEmpty) {
          debugPrint("[REACTION LOG]: Exception/Error terjadi - $message");
        }
      })
    ];
  }

  late List<ReactionDisposer> _disposers;

  @observable
  ObservableList<Product> products = ObservableList<Product>();

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @computed
  int get totalProducts => products.length;

  @computed
  double get totalPrice => products.fold(0, (sum, item) => sum + item.price);

  @action
  Future<void> fetchProducts() async {
    isLoading = true;
    errorMessage = null;
    try {
      final result = await getProductsUseCase.execute();
      products.clear();
      products.addAll(result);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<bool> addNewProduct(
    String name,
    double price, {
    String? description,
    String? category,
    int? stock,
    File? imageFile,
  }) async {
    isLoading = true;
    errorMessage = null;
    try {
      String? imageId;
      if (imageFile != null) {
        imageId = await uploadImageUseCase.execute(imageFile);
      }

      final newProduct = Product(
        id: '',
        name: name,
        price: price,
        description: description,
        category: category,
        stock: stock,
        status: 'draft',
        imageUrl: imageId,
      );

      final success = await addProductUseCase.execute(newProduct);
      if (success) {
        await fetchProducts();
        return true;
      }
      return false;
    } catch (e) {
      errorMessage = "Error API (Add): ${e.toString()}";
      return false;
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<bool> editProduct(
    String id,
    Map<String, dynamic> updatedData, {
    File? imageFile,
  }) async {
    isLoading = true;
    errorMessage = null;
    try {
      // Jika pengguna memilih gambar baru saat edit, unggah dulu ke server
      if (imageFile != null) {
        final newImageId = await uploadImageUseCase.execute(imageFile);
        updatedData['image_url'] = newImageId;
      }

      final success = await updateProductUseCase.execute(id, updatedData);
      if (success) {
        await fetchProducts();
        return true;
      }
      return false;
    } catch (e) {
      errorMessage = "Error API (Update): ${e.toString()}";
      return false;
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<bool> removeProduct(String id) async {
    final targetProduct = products.firstWhere((p) => p.id == id);
    products.remove(targetProduct);

    isLoading = true;
    errorMessage = null;
    try {
      final success = await deleteProductUseCase.execute(id);
      if (success) {
        return true;
      } else {
        products.add(targetProduct);
        errorMessage = "Gagal menghapus produk di server";
        return false;
      }
    } catch (e) {
      products.add(targetProduct);
      errorMessage = "Error API (Delete): ${e.toString()}";
      return false;
    } finally {
      isLoading = false;
    }
  }

  void dispose() {
    for (var disposer in _disposers) {
      disposer();
    }
  }
}