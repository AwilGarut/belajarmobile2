import 'dart:io';
import '../repositories/product_repository.dart';

class UploadImage {
  final ProductRepository repository;
  UploadImage(this.repository);

  Future<String> execute(File file) async {
    return await repository.uploadImage(file);
  }
}