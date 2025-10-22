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
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/$timezone'),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'Flutter-WorldClock/1.0',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final worldClock = WorldClockModel.fromApiResponse(data);
        return worldClock;
      } else {
        throw Exception('Error al obtener la hora: ${response.statusCode} - ${response.body}');
      }
    } on TimeoutException catch (e) {
      throw Exception('Timeout al obtener la hora: $e');
    } on FormatException catch (e) {
      throw Exception('Error al procesar la respuesta: $e');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
