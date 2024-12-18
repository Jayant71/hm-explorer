import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hm_explorer/model/product.dart';

class ApiService {
  final Dio dio = Dio();
  String? country = 'in';
  String? lang = 'en';
  String? currentPage = '0';
  String? pageSize = '30';
  String? categories = "men_all";
  String? concepts = "H%26M%20MAN";
  final Options options = Options(method: 'GET', headers: {
    'x-rapidapi-key': dotenv.env['RAPID_API_KEY'],
    'x-rapidapi-host': 'apidojo-hm-hennes-mauritz-v1.p.rapidapi.com'
  });

  Future<Either<Exception, List<Product>>> fetchProducts(
      List<String> selectedCategories, int page) async {
    try {
      if (selectedCategories.isNotEmpty) {
        categories = selectedCategories.join('%3A');
      }
      currentPage = page.toString();

      String url =
          "https://apidojo-hm-hennes-mauritz-v1.p.rapidapi.com/products/list?country=$country&lang=$lang&currentpage=$currentPage&pagesize=$pageSize&categories=$categories";
      url = Uri.encodeFull(url);
      final response = await dio.get(url, options: options);
      final List<Product> products = [];

      // print(response.data);

      for (var item in response.data['results']) {
        var name = item['name'];
        var price = item['price']['formattedValue'];
        var image = item['images'][0]['url'];
        products.add(Product(name: name, price: price, image: image));
      }
      return Right(products);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }
}
