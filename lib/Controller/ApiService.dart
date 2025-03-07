import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lifti_app/Api/my_api.dart';
import 'package:lifti_app/Model/BarData.dart';
import 'package:lifti_app/Model/ChartData.dart';
import 'package:lifti_app/Model/DemandeTaxiModel.dart';
import 'package:lifti_app/Model/NotificationModel.dart';
import 'package:lifti_app/Model/PieData.dart';


class ApiService {
  static Future<List<PieData>> fetchPieData(String url) async {
    final response = await http.get(
      Uri.parse(
        "${CallApi.baseUrl.toString()}/${url.toString()}",
      ),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      List data = jsonData['data'];
      return data.map((item) => PieData.fromJson(item)).toList();
    } else {
      throw Exception("Erreur lors de la récupération des données");
    }
  }

  static Future<List<BarData>> fetchBarData(String url) async {
    final response = await http.get(
      Uri.parse("${CallApi.baseUrl.toString()}/${url.toString()}"),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      List data = jsonData['data'];
      return data.map((item) => BarData.fromJson(item)).toList();
    } else {
      throw Exception("Erreur lors de la récupération des données");
    }
  }

  static Future<List<ChartData>> fetchColumnData(String url) async {
    final response = await http.get(
      Uri.parse("${CallApi.baseUrl.toString()}/${url.toString()}"),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      List data = jsonData['data'];
      return data.map((item) => ChartData.fromJson(item)).toList();
    } else {
      throw Exception("Erreur lors de la récupération des données");
    }
  }

  //affichage des commandes

  static Future<List<DemandeTaxiModel>> fetchCommande(String url) async {
    final response = await http.get(
      Uri.parse("${CallApi.baseUrl.toString()}/${url.toString()}"),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      List data = jsonData['data'];
      return data.map((item) => DemandeTaxiModel.fromMap(item)).toList();
    } else {
      throw Exception("Erreur lors de la récupération des données");
    }
  }





 
  






}
