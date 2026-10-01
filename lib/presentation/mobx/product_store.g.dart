// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ProductStore on _ProductStore, Store {
  Computed<int>? _$totalProductsComputed;

  @override
  int get totalProducts =>
      (_$totalProductsComputed ??= Computed<int>(() => super.totalProducts,
              name: '_ProductStore.totalProducts'))
          .value;
  Computed<double>? _$totalPriceComputed;

  @override
  double get totalPrice =>
      (_$totalPriceComputed ??= Computed<double>(() => super.totalPrice,
              name: '_ProductStore.totalPrice'))
          .value;

  late final _$productsAtom =
      Atom(name: '_ProductStore.products', context: context);

  @override
  ObservableList<Product> get products {
    _$productsAtom.reportRead();
    return super.products;
  }

  @override
  set products(ObservableList<Product> value) {
    _$productsAtom.reportWrite(value, super.products, () {
      super.products = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_ProductStore.isLoading', context: context);

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$errorMessageAtom =
      Atom(name: '_ProductStore.errorMessage', context: context);

  @override
  String? get errorMessage {
    _$errorMessageAtom.reportRead();
    return super.errorMessage;
  }

  @override
  set errorMessage(String? value) {
    _$errorMessageAtom.reportWrite(value, super.errorMessage, () {
      super.errorMessage = value;
    });
  }

  late final _$fetchProductsAsyncAction =
      AsyncAction('_ProductStore.fetchProducts', context: context);

  @override
  Future<void> fetchProducts() {
    return _$fetchProductsAsyncAction.run(() => super.fetchProducts());
  }

  late final _$addNewProductAsyncAction =
      AsyncAction('_ProductStore.addNewProduct', context: context);

  @override
  Future<bool> addNewProduct(String name, double price,
      {String? description, String? category, int? stock, File? imageFile}) {
    return _$addNewProductAsyncAction.run(() => super.addNewProduct(name, price,
        description: description,
        category: category,
        stock: stock,
        imageFile: imageFile));
  }

  late final _$editProductAsyncAction =
      AsyncAction('_ProductStore.editProduct', context: context);

  @override
  Future<bool> editProduct(String id, Map<String, dynamic> updatedData,
      {File? imageFile}) {
    return _$editProductAsyncAction
        .run(() => super.editProduct(id, updatedData, imageFile: imageFile));
  }

  late final _$removeProductAsyncAction =
      AsyncAction('_ProductStore.removeProduct', context: context);

  @override
  Future<bool> removeProduct(String id) {
    return _$removeProductAsyncAction.run(() => super.removeProduct(id));
  }

  @override
  String toString() {
    return '''
products: ${products},
isLoading: ${isLoading},
errorMessage: ${errorMessage},
totalProducts: ${totalProducts},
totalPrice: ${totalPrice}
    ''';
  }
}
