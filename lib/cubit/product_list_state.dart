part of 'product_list_cubit.dart';

sealed class ProductListState {}

class ProductListInitial extends ProductListState {}

class ProductListLoading extends ProductListState {}

class ProductListLoaded extends ProductListState {
  List<dynamic> products;
  bool hasReachedMax = false;
  ProductListLoaded(this.products, this.hasReachedMax);
}

class ProductListError extends ProductListState {
  final Exception exception;

  ProductListError(this.exception);
}
