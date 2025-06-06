import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sample_flutter/reapeated_function/slider.dart';
import 'package:sample_flutter/apikey/apikey.dart';

class Upcoming extends StatefulWidget {
  const Upcoming({super.key});

  @override
  State<Upcoming> createState() => _UpcomingState();
}

class _UpcomingState extends State<Upcoming> {
  late Future<List<Map<String, dynamic>>> upcomingFuture;

  @override
  void initState() {
    super.initState();
    upcomingFuture = fetchUpcomingMovies();
  }

  Future<List<Map<String, dynamic>>> fetchUpcomingMovies() async {
    List<Map<String, dynamic>> upcoming = [];

    // URL corrigida
    String upcomingMoviesUrl =
        'https://api.themoviedb.org/3/movie/upcoming?api_key=$apiKey';

    var response = await http.get(Uri.parse(upcomingMoviesUrl));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      var results = data['results'];

      for (var movie in results) {
        upcoming.add({
          "name": movie["title"],
          "poster_path": movie["poster_path"],
          "vote_average": movie["vote_average"],
          "Date": movie["release_date"],
          "id": movie["id"],
        });
      }
    } else {
      print('Erro na requisição: ${response.statusCode}');
    }

    return upcoming;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: upcomingFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.amber),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Erro: ${snapshot.error}'),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('Nenhum filme encontrado.'),
          );
        } else {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              sliderList(snapshot.data!, "Em Breve", "filme", 20),
            ],
          );
        }
      },
    );
  }
}
