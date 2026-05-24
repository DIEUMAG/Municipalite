import 'package:dio/dio.dart';

import '../../models/actualite_model.dart';
import '../constants/api_constants.dart';
import '../../features/auth/services/auth_service.dart';

class ActualiteService {

  final Dio dio = Dio();

  Future<List<ActualiteModel>>
      getActualites() async {

    try {

      final token =
          await AuthService()
              .getAccessToken();

      final response = await dio.get(

        '${ApiConstants.baseUrl}/actualites/',

        options: Options(
          headers: {
            'Authorization':
                'Bearer $token',
          },
        ),
      );

      return (response.data as List)

          .map(
            (e) =>
                ActualiteModel.fromJson(e),
          )

          .toList();

    } catch (e) {

      print(e);

      return [];
    }
  }
}