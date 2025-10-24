import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/world_clock_model.dart';

abstract class WorldClockRemoteDataSource {
  Future<WorldClockModel> getCurrentTimeByTimezone(String timezone);
}

class WorldClockRemoteDataSourceImpl implements WorldClockRemoteDataSource {
  final http.Client client;
  final String baseUrl = 'http://worldtimeapi.org/api/timezone';

  WorldClockRemoteDataSourceImpl({required this.client});

  @override
  Future<WorldClockModel> getCurrentTimeByTimezone(String timezone) async {
    print('🔄 API CALL: Iniciando llamada a API para timezone: $timezone');
    print('🔄 API CALL: URL: $baseUrl/$timezone');

    try {
      final response = await client
          .get(
            Uri.parse('$baseUrl/$timezone'),
            headers: {
              'Content-Type': 'application/json',
              'User-Agent': 'Flutter-WorldClock/1.0',
            },
          )
          .timeout(const Duration(seconds: 10));

      print('🔄 API CALL: Status Code: ${response.statusCode}');
      print('🔄 API CALL: Headers: ${response.headers}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print('✅ API CALL: Respuesta exitosa para $timezone');
        print('✅ API CALL: Datos recibidos: $data');

        final worldClock = WorldClockModel.fromApiResponse(data);
        print(
          '✅ API CALL: Modelo creado - ID: ${worldClock.id}, Ciudad: ${worldClock.city}, Hora: ${worldClock.currentTime}',
        );
        return worldClock;
      } else {
        print(
          '❌ API CALL: Error HTTP para $timezone - Status: ${response.statusCode}',
        );
        print('❌ API CALL: Response body: ${response.body}');
        throw Exception(
          'Error al obtener la hora: ${response.statusCode} - ${response.body}',
        );
      }
    } on TimeoutException catch (e) {
      print('⏰ API CALL: Timeout para $timezone - $e');
      throw Exception('Timeout al obtener la hora: $e');
    } on FormatException catch (e) {
      print('📝 API CALL: Error de formato para $timezone - $e');
      throw Exception('Error al procesar la respuesta: $e');
    } catch (e) {
      print('💥 API CALL: Error general para $timezone - $e');
      throw Exception('Error de conexión: $e');
    }
  }
}
