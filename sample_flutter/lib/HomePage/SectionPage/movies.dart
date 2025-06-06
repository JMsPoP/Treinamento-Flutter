import 'package:flutter/material.dart';
import 'package:sample_flutter/apikey/apikey.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sample_flutter/reapeated_function/slider.dart';


class Movies extends StatefulWidget {
  const Movies({super.key});

  @override
  State<Movies> createState() => _MoviesState();
}

class _MoviesState extends State<Movies> {

  List<Map<String, dynamic>> popularmovies = [];
  List<Map<String, dynamic>> nowplayingmovies = [];
  List<Map<String, dynamic>> topratedmovies = [];

  Future<void> movieslist() async{

    String popularmoviesurl =
        'https://api.themoviedb.org/3/movie/popular?api_key=$apiKey';
    String nowplayingmoviesurl =
        'https://api.themoviedb.org/3/movie/now_playing?api_key=$apiKey';
    String topratedmoviesurl =
        'https://api.themoviedb.org/3/movie/top_rated?api_key=$apiKey';


    var popularmoviesresponse = await http.get(Uri.parse(popularmoviesurl));
    if(popularmoviesresponse.statusCode == 200){
      var tempdata = jsonDecode(popularmoviesresponse.body);
      var popularmoviesjson = tempdata['results'];
      for (var i = 0; i < popularmoviesjson.length; i++){

        //adiciona caracteristicas (como nome, poster_path, etc)dos filmes na lista
        popularmovies.add({
          "name": popularmoviesjson[i]["title"],
          "poster_path": popularmoviesjson[i]["poster_path"],
          "vote_average": popularmoviesjson[i]["vote_average"],
          "Date": popularmoviesjson[i]["release_date"],
          "id": popularmoviesjson[i]["id"],
        });
      }
      //se nao achar nada, mostra o erro
    }else{
      print(popularmoviesresponse.statusCode);
    }
    var topratedmoviesresponse = await http.get(Uri.parse(topratedmoviesurl));
    if(topratedmoviesresponse.statusCode == 200) {
      var tempdata = jsonDecode(topratedmoviesresponse.body);
      var topratedmoviesjson = tempdata['results'];
      for (var i = 0; i < topratedmoviesjson.length; i++) {
        topratedmovies.add({
          "name": topratedmoviesjson[i]["title"],
          "poster_path": topratedmoviesjson[i]["poster_path"],
          "vote_average": topratedmoviesjson[i]["vote_average"],
          "Date": topratedmoviesjson[i]["release_date"],
          "id": topratedmoviesjson[i]["id"],
        });
      }
    }else{
      print(topratedmoviesresponse.statusCode);
    }

    var nowplayingmoviesresponse = await http.get(Uri.parse(nowplayingmoviesurl));
    if(nowplayingmoviesresponse.statusCode == 200){
      var tempdata = jsonDecode(nowplayingmoviesresponse.body);
      var nowplayingmoviesjson = tempdata['results'];
      for (var i = 0; i < nowplayingmoviesjson.length; i++){
        nowplayingmovies.add({
          "name": nowplayingmoviesjson[i]["title"],
          "poster_path": nowplayingmoviesjson[i]["poster_path"],
          "vote_average": nowplayingmoviesjson[i]["vote_average"],
          "Date": nowplayingmoviesjson[i]["release_date"],
          "id": nowplayingmoviesjson[i]["id"],
        });
      }
    }else{
      print(nowplayingmoviesresponse.statusCode);
    }
  }



  @override
  Widget build(BuildContext context) {
    return FutureBuilder(future: movieslist(), builder: (context, snapshot) {
      if(snapshot.connectionState == ConnectionState.waiting){
        return Center(
             child: CircularProgressIndicator(color: Colors.amber,));
      }else{
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            sliderList(popularmovies, "Filmes populares", "filme", 20),
            sliderList(nowplayingmovies, "Em Cartaz", "filme", 20),
            sliderList(topratedmovies, "Bem avaliadas", "filme", 20)
          ],
        );
      }
    },);

  }
}
