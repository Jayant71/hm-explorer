import "package:flutter/material.dart";
import 'package:flutter_dotenv/flutter_dotenv.dart';

import "package:flutter_bloc/flutter_bloc.dart";
import "package:hm_explorer/cubit/product_list_cubit.dart";
import "package:hm_explorer/homepage.dart";

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProductListCubit(ProductListInitial()),
      child: MaterialApp(
        home: Homepage(),
      ),
    );
  }
}
