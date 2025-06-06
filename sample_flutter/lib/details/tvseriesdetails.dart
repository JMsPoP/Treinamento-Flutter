import 'package:flutter/material.dart';
import 'package:sample_flutter/HomePage/HomePage.dart';
import 'package:sample_flutter/apikey/apikey.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sample_flutter/reapeated_function/slider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sample_flutter/reapeated_function/userreview.dart';

class TvSeriesDetails extends StatefulWidget {
  var id;
  TvSeriesDetails(this.id);

  @override
  State<TvSeriesDetails> createState() => _TvSeriesDetailsState();
}

// monta uma forma com base na série escolhida, onde terá a sinopse, review dos usuários etc.

class _TvSeriesDetailsState extends State<TvSeriesDetails> {
  List<Map<String, dynamic>> TvDetails = [];
  List<Map<String, dynamic>> UserReviews = [];
  List<Map<String, dynamic>> similarTvList = [];
  List<Map<String, dynamic>> recommendedTvList = [];
  List TvGenres = [];

  Future<void> getTvDetails() async {
    // endpoints da API para séries de Tv
    var tvDetailUrl =
        'https://api.themoviedb.org/3/tv/${widget.id}?api_key=$apiKey';
    var userReviewUrl =
        'https://api.themoviedb.org/3/tv/${widget.id}/reviews?api_key=$apiKey';
    var similarTvUrl =
        'https://api.themoviedb.org/3/tv/${widget.id}/similar?api_key=$apiKey';
    var recommendedTvUrl =
        'https://api.themoviedb.org/3/tv/${widget.id}/recommendations?api_key=$apiKey';

    var detailResponse = await http.get(Uri.parse(tvDetailUrl));
    if (detailResponse.statusCode == 200) {
      var json = jsonDecode(detailResponse.body);
      TvDetails.add({
        "backdrop_path": json['backdrop_path'],
        "name": json['name'],
        "vote_average": json['vote_average'],
        "overview": json['overview'],
        "first_air_date": json['first_air_date'],
        "number_of_episodes": json['number_of_episodes'],
        "number_of_seasons": json['number_of_seasons'],
      });

      for (var genre in json['genres']) {
        TvGenres.add(genre['name']);
      }
    }

    var reviewResponse = await http.get(Uri.parse(userReviewUrl));
    if (reviewResponse.statusCode == 200) {
      var json = jsonDecode(reviewResponse.body);
      for (var i = 0; i < json['results'].length; i++) {
        UserReviews.add({
          "name": json['results'][i]['author'],
          "review": json['results'][i]['content'],
          "rating": json['results'][i]['author_details']['rating'] == null
              ? "Not Rated"
              : json['results'][i]['author_details']['rating'].toString(),
          "avatarphoto": json['results'][i]['author_details']['avatar_path'] == null
              ? "https://www.pngitem.com/ping/m/146-1468478_my-profile-icon-blanck-profile-picture-circle-hd"
              : "https://image.tmdb.org/t/p/w500" +
              json['results'][i]['author_details']['avatar_path'],
          "creationdate": json['results'][i]['created_at'].substring(0, 10),
          "fullreviewurl": json['results'][i]['url'],
        });
      }
    }

    var similarResponse = await http.get(Uri.parse(similarTvUrl));
    if (similarResponse.statusCode == 200) {
      var json = jsonDecode(similarResponse.body);
      for (var i = 0; i < json['results'].length; i++) {
        similarTvList.add({
          "poster_path": json['results'][i]['poster_path'],
          "name": json['results'][i]['name'],
          "vote_average": json['results'][i]['vote_average'],
          "Date": json['results'][i]['first_air_date'],
          "id": json['results'][i]['id'],
        });
      }
    }

    var recommendedResponse = await http.get(Uri.parse(recommendedTvUrl));
    if (recommendedResponse.statusCode == 200) {
      var json = jsonDecode(recommendedResponse.body);
      for (var i = 0; i < json['results'].length; i++) {
        recommendedTvList.add({
          "poster_path": json['results'][i]['poster_path'],
          "name": json['results'][i]['name'],
          "vote_average": json['results'][i]['vote_average'],
          "Date": json['results'][i]['first_air_date'],
          "id": json['results'][i]['id'],
        });
      }
    }
  }

  // montagem do front
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(14, 14, 14, 1),
      body: FutureBuilder(
        future: getTvDetails(),
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
                  backgroundColor: Color.fromRGBO(18, 18, 18, 0.5),
                  centerTitle: false,
                  pinned: true,
                  expandedHeight: MediaQuery.of(context).size.height * 0.4,
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.parallax,
                    background: TvDetails.isNotEmpty
                        ? Image.network(
                      'https://image.tmdb.org/t/p/w500${TvDetails[0]['backdrop_path']}',
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
                                itemCount: TvGenres.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    margin: EdgeInsets.only(right: 10),
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Color.fromRGBO(25, 25, 25, 1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(TvGenres[index]),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
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
                                '${TvDetails[0]['number_of_seasons']} temporadas, ${TvDetails[0]['number_of_episodes']} episódios',
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
                      child: Text(TvDetails[0]['overview'].toString()),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 20, top: 10),
                      child: UserReview(UserReviews),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 20, top: 20),
                      child: Text(
                        'Data de Lançamento : ${TvDetails[0]['first_air_date']}',
                      ),
                    ),
                    sliderList(similarTvList, "Séries Similares", "serie",
                        similarTvList.length),
                    sliderList(recommendedTvList, "Séries Recomendadas",
                        "serie", recommendedTvList.length),
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