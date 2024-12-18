import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hm_explorer/constants/category_list.dart';
import 'package:hm_explorer/cubit/product_list_cubit.dart';
import 'package:hm_explorer/widgets/product_card.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int pageIndex = 1;
  List<String> selectedCategories = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          bottomOpacity: 0,
          backgroundColor: Colors.white,
          leading: IconButton(onPressed: () {}, icon: Icon(Icons.menu)),
          actions: [
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {},
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
            onTap: (value) {
              setState(() {
                pageIndex = value;
              });
            },
            currentIndex: pageIndex,
            items: [
              BottomNavigationBarItem(
                  icon: Icon(Icons.category), label: "Category"),
              BottomNavigationBarItem(icon: Icon(Icons.menu), label: "Product"),
            ]),
        body: IndexedStack(index: pageIndex, children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Select Your Categories",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 12.0,
                  runSpacing: 8.0,
                  children: CategoryList.keys.map((category) {
                    final categoryValue = CategoryList[category]!;
                    final isSelected =
                        selectedCategories.contains(categoryValue);
                    return ChoiceChip(
                      label: Text(
                        category,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: Colors.blue,
                      backgroundColor: Colors.grey[200],
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            selectedCategories.add(categoryValue);
                          } else {
                            selectedCategories.remove(categoryValue);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        context
                            .read<ProductListCubit>()
                            .fetchProducts(selectedCategories, 0);
                        setState(() {
                          pageIndex = 1;
                        });
                      },
                      child: const Text("See Products"),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          context
                              .read<ProductListCubit>()
                              .fetchProducts(selectedCategories, 0);
                          selectedCategories.clear();
                          pageIndex = 1;
                        });
                      },
                      child: const Text("Clear All"),
                    ),
                  ],
                ),
              ],
            ),
          ),
          RefreshIndicator(
            onRefresh: () {
              return context.read<ProductListCubit>().fetchProducts(
                    selectedCategories,
                    0,
                  );
            },
            child: BlocBuilder<ProductListCubit, ProductListState>(
              builder: (context, state) {
                if (state is ProductListInitial) {
                  context.read<ProductListCubit>().fetchProducts(
                        selectedCategories,
                        0,
                      );
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (state is ProductListLoading) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (state is ProductListLoaded) {
                  if (state.products.isEmpty) {
                    return Column(
                      children: [
                        Center(
                          child: Text("No products found"),
                        ),
                        ElevatedButton(
                          onPressed: () =>
                              context.read<ProductListCubit>().fetchProducts(
                                    selectedCategories,
                                    0,
                                  ),
                          child: Text("Retry"),
                        ),
                      ],
                    );
                  }
                  // ignore: no_leading_underscores_for_local_identifiers
                  ScrollController _scrollController = ScrollController();
                  _scrollController.addListener(() {
                    if (_scrollController.position.pixels ==
                        _scrollController.position.maxScrollExtent) {
                      if (state.hasReachedMax) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("No more products to load"),
                            behavior: SnackBarBehavior.floating,
                            duration: Duration(seconds: 3),
                          ),
                        );
                        return;
                      }
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Loading more products..."),
                          behavior: SnackBarBehavior.floating,
                          duration: Duration(seconds: 3),
                        ),
                      );
                      context.read<ProductListCubit>().fetchProducts(
                            selectedCategories,
                            ((state.products.length / 30)).toInt(),
                          );
                    }
                  });

                  return GridView.builder(
                    controller: _scrollController,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: state.products.length,
                    itemBuilder: (context, index) {
                      if (state.products[index] is Widget) {
                        return state.products[index];
                      }
                      return ProductCard(
                        product: state.products[index],
                      );
                    },
                  );
                } else if (state is ProductListError) {
                  return Center(
                    child: Column(
                      children: [
                        Text("Error: ${state.exception}"),
                        ElevatedButton(
                          onPressed: () => context
                              .read<ProductListCubit>()
                              .fetchProducts(selectedCategories, 0),
                          child: Text("Retry"),
                        ),
                      ],
                    ),
                  );
                } else {
                  return Container();
                }
              },
            ),
          ),
        ]));
  }
}
