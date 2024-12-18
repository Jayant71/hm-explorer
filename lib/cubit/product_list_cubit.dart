import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hm_explorer/model/product.dart';
import 'package:hm_explorer/services/api_service.dart';

part 'product_list_state.dart';

class ProductListCubit extends Cubit<ProductListState> {
  ProductListCubit(super.initialState);
  int currentPage = 0;

  Future<void> fetchProducts(
    List<String> selectedCategories,
    int page,
  ) async {
    ApiService apiService = ApiService();
    if (page == 0) {
      currentPage = 0;
      emit(ProductListLoading());
      clearCache();
    }

    if (currentPage == page && _cachedProducts.isNotEmpty) {
      // emit(ProductListLoaded(_cachedProducts));

      emit(ProductListLoaded(_cachedProducts, true));
      return;
    }
    currentPage = page;

    final products = await apiService.fetchProducts(selectedCategories, page);
    products.fold(
      (l) {
        clearCache();
        emit(ProductListError(l));
      },
      (r) {
        addProductsToCache(r);
        emit(ProductListLoaded(_cachedProducts, false));
      },
    );
  }

  // ignore: prefer_final_fields
  List<Product> _cachedProducts = [];

  void addProductsToCache(List<Product> products) {
    _cachedProducts.addAll(products);
  }

  List<Product> getCachedProducts() {
    return _cachedProducts;
  }

  void clearCache() {
    _cachedProducts.clear();
  }
}
