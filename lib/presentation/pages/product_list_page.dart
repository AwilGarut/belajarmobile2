import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/product.dart';
import '../mobx/product_store.dart';

class ProductListPage extends StatefulWidget {
  final ProductStore productStore;

  const ProductListPage({super.key, required this.productStore});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  ProductStore get productStore => widget.productStore;

  // --- STATE PENCARIAN ---
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Muat data otomatis saat halaman dibuka
    productStore.fetchProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filter produk berdasarkan nama, kategori, atau deskripsi
  List<Product> _filterProducts(List<Product> products) {
    final keyword = _searchQuery.trim().toLowerCase();
    if (keyword.isEmpty) return products.toList();

    return products.where((p) {
      final name = p.name.toLowerCase();
      final category = (p.category ?? '').toLowerCase();
      final description = (p.description ?? '').toLowerCase();
      return name.contains(keyword) ||
          category.contains(keyword) ||
          description.contains(keyword);
    }).toList();
  }

  // --- DIALOG TAMBAH / EDIT PRODUK (SATU FORM UNTUK KEDUANYA) ---
  // product == null  -> mode TAMBAH
  // product != null  -> mode EDIT
  Future<void> _showProductFormDialog(BuildContext pageContext,
      {Product? product}) {
    final isEdit = product != null;

    final nameController = TextEditingController(text: product?.name);
    final priceController =
        TextEditingController(text: product?.price.toStringAsFixed(0));
    final descController = TextEditingController(text: product?.description);
    final catController = TextEditingController(text: product?.category);
    final stockController =
        TextEditingController(text: product?.stock?.toString());
    final formKey = GlobalKey<FormState>();

    File? selectedImage;
    final ImagePicker picker = ImagePicker();

    return showDialog<void>(
      context: pageContext,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (_, setDialogState) {
            Future<void> pickImage() async {
              try {
                final pickedFile = await picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 80,
                );
                if (pickedFile != null) {
                  setDialogState(() {
                    selectedImage = File(pickedFile.path);
                  });
                }
              } catch (e) {
                debugPrint("[ERROR PICK IMAGE]: $e");
                if (pageContext.mounted) {
                  ScaffoldMessenger.of(pageContext).showSnackBar(
                    SnackBar(content: Text('Gagal membuka galeri: $e')),
                  );
                }
              }
            }

            Widget imagePlaceholder() => const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                    SizedBox(height: 6),
                    Text('Tap untuk pilih gambar',
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                );

            Widget imagePreview() {
              if (selectedImage != null) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(selectedImage!,
                      fit: BoxFit.cover, width: double.infinity),
                );
              }
              if (isEdit && product.imageUrl != null) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    product.imageUrl!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) => imagePlaceholder(),
                  ),
                );
              }
              return imagePlaceholder();
            }

            return AlertDialog(
              title: Text(isEdit ? 'Edit Produk' : 'Tambah Produk'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: pickImage,
                        child: Container(
                          width: double.infinity,
                          height: 140,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          child: imagePreview(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: nameController,
                        decoration:
                            const InputDecoration(labelText: 'Nama Produk*'),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Wajib diisi' : null,
                      ),
                      TextFormField(
                        controller: priceController,
                        decoration: const InputDecoration(labelText: 'Harga*'),
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            v == null || double.tryParse(v) == null
                                ? 'Harga tidak valid'
                                : null,
                      ),
                      TextFormField(
                        controller: catController,
                        decoration: const InputDecoration(
                            labelText: 'Kategori (Opsional)'),
                      ),
                      TextFormField(
                        controller: stockController,
                        decoration:
                            const InputDecoration(labelText: 'Stok (Opsional)'),
                        keyboardType: TextInputType.number,
                      ),
                      TextFormField(
                        controller: descController,
                        decoration: const InputDecoration(
                            labelText: 'Deskripsi (Opsional)'),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;

                    final name = nameController.text;
                    final price = double.parse(priceController.text);
                    final desc = descController.text;
                    final cat = catController.text;
                    final stock = int.tryParse(stockController.text);

                    Navigator.pop(dialogContext);

                    if (isEdit) {
                      productStore
                          .editProduct(
                        product.id,
                        {
                          'name': name,
                          'price': price,
                          'category': cat,
                          'stock': stock,
                          'description': desc,
                        },
                        imageFile: selectedImage,
                      )
                          .then((success) {
                        if (pageContext.mounted) {
                          ScaffoldMessenger.of(pageContext).showSnackBar(
                            SnackBar(
                              content: Text(success
                                  ? 'Berhasil mengupdate produk!'
                                  : 'Gagal update produk'),
                            ),
                          );
                        }
                      });
                    } else {
                      productStore
                          .addNewProduct(
                        name,
                        price,
                        description: desc.isNotEmpty ? desc : null,
                        category: cat.isNotEmpty ? cat : null,
                        stock: stock,
                        imageFile: selectedImage,
                      )
                          .then((success) {
                        if (pageContext.mounted) {
                          ScaffoldMessenger.of(pageContext).showSnackBar(
                            SnackBar(
                              content: Text(success
                                  ? 'Produk berhasil ditambahkan!'
                                  : productStore.errorMessage ??
                                      'Gagal menambah produk'),
                            ),
                          );
                        }
                      });
                    }
                  },
                  child: Text(isEdit ? 'Simpan' : 'Tambah'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- DIALOG HAPUS ---
  Future<bool?> _confirmDelete(BuildContext context, Product product) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Produk?'),
        content: Text('Hapus "${product.name}" secara permanen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- MODAL DETAIL PRODUK ---
  void _showProductDetail(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: product.imageUrl != null
                        ? Image.network(
                            product.imageUrl!,
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _buildPlaceholder(160),
                          )
                        : _buildPlaceholder(160),
                  ),
                ),
                const SizedBox(height: 20),
                Text(product.name,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  'Rp ${product.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontSize: 20,
                      color: Colors.green,
                      fontWeight: FontWeight.w600),
                ),
                const Divider(height: 30),
                _buildDetailRow(
                    Icons.category, 'Kategori', product.category ?? '-'),
                _buildDetailRow(Icons.inventory, 'Stok',
                    product.stock?.toString() ?? 'Kosong'),
                _buildDetailRow(
                    Icons.info, 'Status', product.status ?? 'Draft'),
                const SizedBox(height: 16),
                const Text('Deskripsi:',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Text(
                  product.description ?? 'Tidak ada deskripsi produk.',
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton.icon(
                      style:
                          OutlinedButton.styleFrom(foregroundColor: Colors.red),
                      onPressed: () async {
                        Navigator.pop(sheetContext);
                        final confirm = await _confirmDelete(context, product);
                        if (confirm == true) {
                          final success =
                              await productStore.removeProduct(product.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(success
                                      ? 'Berhasil dihapus'
                                      : productStore.errorMessage ??
                                          'Gagal menghapus')),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text('Hapus'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        _showProductFormDialog(context, product: product);
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Produk'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder(double height) {
    return Container(
      height: height,
      width: double.infinity,
      color: Colors.grey[200],
      child:
          const Icon(Icons.image_not_supported, color: Colors.grey, size: 50),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text('$title: ', style: const TextStyle(fontWeight: FontWeight.w500)),
          Expanded(
              child: Text(value,
                  style: const TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  // --- ITEM PRODUK (KARTU) ---
  Widget _buildProductItem(BuildContext context, Product item) {
    final stock = item.stock;
    final Color stockColor = (stock == null || stock == 0)
        ? Colors.red
        : (stock <= 5 ? Colors.orange : Colors.green);
    final String stockText =
        (stock == null || stock == 0) ? 'Stok habis' : 'Stok $stock';

    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showProductDetail(context, item),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: item.imageUrl != null
                    ? Image.network(
                        item.imageUrl!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildThumbPlaceholder(),
                      )
                    : _buildThumbPlaceholder(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    if (item.category != null && item.category!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          item.category!,
                          style:
                              const TextStyle(fontSize: 11, color: Colors.blue),
                        ),
                      ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Rp ${item.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.green,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: stockColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            stockText,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: stockColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbPlaceholder() {
    return Container(
      width: 80,
      height: 80,
      color: Colors.grey[200],
      child: const Icon(Icons.image_not_supported, color: Colors.grey),
    );
  }

  // --- KOLOM PENCARIAN ---
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Cari nama, kategori, atau deskripsi...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  tooltip: 'Hapus pencarian',
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                    FocusScope.of(context).unfocus();
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Daftar Produk'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat ulang',
            onPressed: () => productStore.fetchProducts(),
          ),
        ],
      ),
      body: Column(
        children: [
          // --- KOLOM PENCARIAN ---
          _buildSearchBar(),

          // --- DAFTAR PRODUK ---
          Expanded(
            child: Observer(
              builder: (_) {
                if (productStore.isLoading && productStore.products.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (productStore.errorMessage != null &&
                    productStore.products.isEmpty) {
                  return Center(
                      child: Text('Error: ${productStore.errorMessage}'));
                }
                if (productStore.products.isEmpty) {
                  return const Center(child: Text("Belum ada data produk."));
                }

                final filtered = _filterProducts(productStore.products);

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off,
                            size: 60, color: Colors.grey[400]),
                        const SizedBox(height: 8),
                        Text(
                          'Produk "${_searchQuery.trim()}" tidak ditemukan',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => productStore.fetchProducts(),
                  child: ListView.separated(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 90),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (listContext, index) {
                      final item = filtered[index];
                      return Dismissible(
                        key: Key(item.id.toString()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (direction) =>
                            _confirmDelete(context, item),
                        onDismissed: (direction) {
                          productStore.removeProduct(item.id).then((success) {
                            if (context.mounted && !success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(productStore.errorMessage ??
                                        'Gagal menghapus produk')),
                              );
                            }
                          });
                        },
                        child: _buildProductItem(context, item),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Observer(
        builder: (_) => FloatingActionButton.extended(
          onPressed: productStore.isLoading
              ? null
              : () => _showProductFormDialog(context),
          icon: const Icon(Icons.add),
          label: const Text('Tambah'),
        ),
      ),
    );
  }
}
