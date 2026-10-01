import 'package:flutter/material.dart';
import 'data/datasources/product_remote_datasource.dart';
import 'data/repositories/product_repository_impl.dart';
import 'domain/usecases/add_product.dart';
import 'domain/usecases/get_products.dart';
import 'presentation/mobx/product_store.dart';
import 'presentation/pages/product_list_page.dart';
import 'core/network/api_service.dart';
import 'domain/usecases/update_product.dart';
import 'domain/usecases/delete_product.dart';
import 'package:belajarmobile2/domain/usecases/upload_image.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final apiService = ApiService();
  final remoteDataSource = ProductRemoteDataSource(apiService: apiService);
  final repository = ProductRepositoryImpl(remoteDataSource: remoteDataSource);

  final getProductsUseCase = GetProducts(repository);
  final addProductUseCase = AddProduct(repository);
  final updateProductUseCase = UpdateProduct(repository);
  final deleteProductUseCase = DeleteProduct(repository);
  final uploadImageUseCase = UploadImage(repository);

  final productStore = ProductStore(
    getProductsUseCase: getProductsUseCase,
    addProductUseCase: addProductUseCase,
    updateProductUseCase: updateProductUseCase,
    deleteProductUseCase: deleteProductUseCase,
    uploadImageUseCase: uploadImageUseCase,
  );

  runApp(MyApp(productStore: productStore));
}

class MyApp extends StatelessWidget {
  final ProductStore productStore;

  const MyApp({super.key, required this.productStore});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product Listener MobX',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: ProductListPage(productStore: productStore),
    );
  }
}
