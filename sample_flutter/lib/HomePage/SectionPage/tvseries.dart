import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sample_flutter/apikey/apikey.dart';
import 'package:sample_flutter/apilinks/allapi.dart';
import 'package:sample_flutter/reapeated_function/slider.dart';


class TvSeries extends StatefulWidget {
  const TvSeries({super.key});

  @override
  State<TvSeries> createState() => _TvSeriesState();
}

class _TvSeriesState extends State<TvSeries> {
  //lista de series de tv formada
  List<Map<String, dynamic>> populartvseries = [];
  List<Map<String, dynamic>> topratedtvseries = [];
  List<Map<String, dynamic>> onairtvseries = [];

  var populartvseriesurl =
      'https://api.themoviedb.org/3/tv/popular?api_key=$apiKey';
  var topratedtvseriesurl =
      'https://api.themoviedb.org/3/tv/top_rated?api_key=$apiKey';
  var onairtvseriesurl =
      'https://api.themoviedb.org/3/tv/on_the_air?api_key=$apiKey';
  Future<void> tvseriesfunction() async{
    var populartvresponse = await http.get(Uri.parse(populartvseriesurl));
    if(populartvresponse.statusCode == 200){
      var tempdata = jsonDecode(populartvresponse.body);
      var populartvjson = tempdata['results'];
      for (var i = 0; i < populartvjson.length; i++){

        //adiciona caracteristicas (como nome, poster_path, etc)das series de tv na lista
        populartvseries.add({
          "name": populartvjson[i]["name"],
          "poster_path": populartvjson[i]["poster_path"],
          "vote_average": populartvjson[i]["vote_average"],
          "Date": populartvjson[i]["first_air_date"],
          "id": populartvjson[i]["id"],
        });
      }
      //se nao achar nada, mostra o erro
    }else{
      print(populartvresponse.statusCode);
    }
    var topratedtvresponse = await http.get(Uri.parse(topratedtvseriesurl));
    if(topratedtvresponse.statusCode == 200) {
      var tempdata = jsonDecode(topratedtvresponse.body);
      var topratedtvjson = tempdata['results'];
      for (var i = 0; i < topratedtvjson.length; i++) {
        topratedtvseries.add({
          "name": topratedtvjson[i]["name"],
          "poster_path": topratedtvjson[i]["poster_path"],
          "vote_average": topratedtvjson[i]["vote_average"],
          "Date": topratedtvjson[i]["first_air_date"],
          "id": topratedtvjson[i]["id"],
        });
      }
    }else{
      print(topratedtvresponse.statusCode);
    }

    var onairtvresponse = await http.get(Uri.parse(onairtvseriesurl));
    if(onairtvresponse.statusCode == 200){
      var tempdata = jsonDecode(onairtvresponse.body);
      var onairtvjson = tempdata['results'];
      for (var i = 0; i < onairtvjson.length; i++){
        onairtvseries.add({
          "name": onairtvjson[i]["name"],
          "poster_path": onairtvjson[i]["poster_path"],
          "vote_average": onairtvjson[i]["vote_average"],
          "Date": onairtvjson[i]["first_air_date"],
          "id": onairtvjson[i]["id"],
        });
      }
    }else{
      print(onairtvresponse.statusCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(

      //constroi a função anterior
      future: tvseriesfunction(),
      builder: (context, snapshot){
        if(snapshot.connectionState == ConnectionState.waiting)
          return Center(
            child: CircularProgressIndicator(color: Colors.amber.shade400));
            else{
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  sliderList(populartvseries, "Series de Tv populares", "tv", 20),
                  sliderList(onairtvseries, "No ar", "tv", 20),
                  sliderList(topratedtvseries, "Bem avaliadas", "tv", 20)
                ],
              );
        }
    });
  }
}
