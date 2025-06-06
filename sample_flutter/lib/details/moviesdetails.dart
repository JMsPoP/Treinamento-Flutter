import 'package:flutter/material.dart';
import 'package:sample_flutter/HomePage/HomePage.dart';
import 'package:sample_flutter/apikey/apikey.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sample_flutter/reapeated_function/slider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sample_flutter/reapeated_function/userreview.dart';

class MoviesDetails extends StatefulWidget {
  var id;
  MoviesDetails(this.id);

  @override
  State<MoviesDetails> createState() => _MoviesDetailsState();
}

//monta uma forma com base no filme escolhido, onde terá a sinopse, review dos usuarios(puxa de userreview.dart) etc.

class _MoviesDetailsState extends State<MoviesDetails> {
  List<Map<String, dynamic>> MoviesDetails = [];
  List<Map<String, dynamic>> UserReviews = [];
  List<Map<String, dynamic>> similarmovieslist = [];
  List<Map<String, dynamic>> recommendadmovieslist = [];
 // List<Map<String, dynamic>> movietrailerslist = [];        codigo para exibir trailer
  List MovieGeneres = [];

  Future<void> MoviesDetail() async {

    //apis para a base de dados

    var moviesdetailurl =
        'https://api.themoviedb.org/3/movie/${widget.id}?api_key=$apiKey';
    var UserReviewurl =
        'https://api.themoviedb.org/3/movie/${widget.id}/reviews?api_key=$apiKey';
    var similarmoviesurl =
        'https://api.themoviedb.org/3/movie/${widget.id}/similar?api_key=$apiKey';
    var recommendedmoviesurl =
        'https://api.themoviedb.org/3/movie/${widget.id}/recommendations?api_key=$apiKey';
   // var moviestrailersurl =
  //      'https://api.themoviedb.org/3/movie/${widget.id}/videos?api_key=$apiKey';


    //faz a conexao
    var moviedetailresponse = await http.get(Uri.parse(moviesdetailurl));
    //se der certo
    if (moviedetailresponse.statusCode == 200) {
      //monta o corpo com base no json da base de dados
      var moviedetailjson = jsonDecode(moviedetailresponse.body);
      MoviesDetails.add({
        //com essas caracteristicas da url details
        "backdrop_path": moviedetailjson['backdrop_path'],
        "title": moviedetailjson['title'],
        "vote_average": moviedetailjson['vote_average'],
        "overview": moviedetailjson['overview'],
        "release_date": moviedetailjson['release_date'],
        "runtime": moviedetailjson['runtime'],
        "budget": moviedetailjson['budget'],
        "revenue": moviedetailjson['revenue'],
      });
//o mesmo vale para os codigos abaixo
      for (var i = 0; i < moviedetailjson['genres'].length; i++) {
        MovieGeneres.add(moviedetailjson['genres'][i]['name']);
      }
    }

    //puxa do codigo userreview e monta a forma para os detalhes do filme

    var UserReviewresponse = await http.get(Uri.parse(UserReviewurl));
    if (UserReviewresponse.statusCode == 200) {
      var UserReviewjson = jsonDecode(UserReviewresponse.body);
      for (var i = 0; i < UserReviewjson['results'].length; i++) {
        UserReviews.add({
          "name": UserReviewjson['results'][i]['author'],
          "review": UserReviewjson['results'][i]['content'],
          "rating": UserReviewjson['results'][i]['author_details']['rating'] == null
              ? "Not Rated"
              : UserReviewjson['results'][i]['author_details']['rating'].toString(),
          "avatarphoto": UserReviewjson['results'][i]['author_details']['avatar_path'] == null
              ? "https://www.pngitem.com/ping/m/146-1468478_my-profile-icon-blanck-profile-picture-circle-hd"
              : "https://image.tmdb.org/t/p/w500" +
              UserReviewjson['results'][i]['author_details']['avatar_path'],
          "creationdate": UserReviewjson['results'][i]['created_at'].substring(0, 10),
          "fullreviewurl": UserReviewjson['results'][i]['url'],
        });
      }
    }

    var similarmoviesresponse = await http.get(Uri.parse(similarmoviesurl));
    if (similarmoviesresponse.statusCode == 200) {
      var similarmoviesjson = jsonDecode(similarmoviesresponse.body);
      for (var i = 0; i < similarmoviesjson['results'].length; i++) {
        similarmovieslist.add({
          "poster_path": similarmoviesjson['results'][i]['poster_path'],
          "name": similarmoviesjson['results'][i]['title'],
          "vote_average": similarmoviesjson['results'][i]['vote_average'],
          "Date": similarmoviesjson['results'][i]['release_date'],
          "id": similarmoviesjson['results'][i]['id'],
        });
      }
    }

    var recommendedmoviesresponse = await http.get(Uri.parse(recommendedmoviesurl));
    if (recommendedmoviesresponse.statusCode == 200) {
      var recommendedmoviesjson = jsonDecode(recommendedmoviesresponse.body);
      for (var i = 0; i < recommendedmoviesjson['results'].length; i++) {
        recommendadmovieslist.add({
          "poster_path": recommendedmoviesjson['results'][i]['poster_path'],
          "name": recommendedmoviesjson['results'][i]['title'],
          "vote_average": recommendedmoviesjson['results'][i]['vote_average'],
          "Date": recommendedmoviesjson['results'][i]['release_date'],
          "id": recommendedmoviesjson['results'][i]['id'],
        });
      }
    }
/*
    var movietrailersresponse = await http.get(Uri.parse(moviestrailersurl));
    if (movietrailersresponse.statusCode == 200) {
      var movietrailersjson = jsonDecode(movietrailersresponse.body);
      for (var i = 0; i < movietrailersjson['results'].length; i++) {
        if (movietrailersjson['results'][i]['type'] == "Trailer") {
          movietrailerslist.add({
            "key": movietrailersjson['results'][i]['key'],
          });
        }
      }
    }*/
  }
//montagem do front
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(14, 14, 14, 1),
      body: FutureBuilder(
        future: MoviesDetail(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  automaticallyImplyLeading: false,
                  leading: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(FontAwesomeIcons.circleArrowLeft),
                    iconSize: 28,
                    color: Colors.white,
                  ),
                  actions: [
                    IconButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                              (route) => false,
                        );
                      },
                      icon: Icon(FontAwesomeIcons.houseUser),
                      iconSize: 25,
                      color: Colors.white,
                    ),
                  ],

                  //geracao do baner do filme

                  backgroundColor: Color.fromRGBO(18, 18, 18, 0.5),
                  centerTitle: false,
                  pinned: true,
                  expandedHeight: MediaQuery.of(context).size.height * 0.4,
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.parallax,
                    background: MoviesDetails.isNotEmpty
                        ? Image.network(
                      'https://image.tmdb.org/t/p/w500${MoviesDetails[0]['backdrop_path']}',
                      fit: BoxFit.cover,
                    )
                        : Container(color: Colors.black),
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate([
                    Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.only(left: 10, top: 10),
                              height: 50,
                              width: MediaQuery.of(context).size.width,
                              child: ListView.builder(
                                physics: BouncingScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                itemCount: MovieGeneres.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    margin: EdgeInsets.only(right: 10),
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Color.fromRGBO(25, 25, 25, 1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(MovieGeneres[index]),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),

                        //row para os detalhes do filme, como sinopse, gasto, etc

                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10),
                              margin: EdgeInsets.only(left: 10, top: 10),
                              height: 40,
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(25, 25, 25, 1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                MoviesDetails[0]['runtime'].toString() + ' min',
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 20, top: 10),
                      child: Text('Sinopse :'),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 20, top: 10),
                      child: Text(MoviesDetails[0]['overview'].toString()),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 20,top: 10),
                    child: UserReview(UserReviews),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 20, top: 20),
                      child: Text('Data de Lançamento : ' +
                          MoviesDetails[0]['release_date'].toString()),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 20, top: 20),
                      child: Text(
                          'Orçamento : \$' + MoviesDetails[0]['budget'].toString()),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 20, top: 20),
                      child: Text(
                          'Bilheteria : \$' + MoviesDetails[0]['revenue'].toString()),
                    ),
                    sliderList(similarmovieslist, "Filmes Similares", "filme",
                        similarmovieslist.length),
                    sliderList(recommendadmovieslist, "Filmes Recomendados",
                        "filme", recommendadmovieslist.length),
                  ]),
                )
              ],
            );
          } else {
            return Center(
              child: CircularProgressIndicator(color: Colors.amber),
            );
          }
        },
      ),
    );
  }
}
