import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sample_flutter/HomePage/SectionPage/movies.dart';
import 'package:sample_flutter/HomePage/SectionPage/tvseries.dart';
import 'package:sample_flutter/HomePage/SectionPage/upcoming.dart';
import 'dart:convert';
import 'package:sample_flutter/apilinks/allapi.dart';

import 'package:carousel_slider/carousel_slider.dart' as cs;
import 'package:sample_flutter/reapeated_function/searchbar.dart';
final cs.CarouselSliderController _controller = cs.CarouselSliderController();


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin{
  List<Map<String, dynamic>> trendinglist = [];

  //traz a trending topics da semana transcrevendo o json para um body palpavel
  Future<void> trendinglisthome() async {
//faz a troca para os trending topics do dia atravez do valor do uval
    if (uval == 1){
      var trendingweekresponse = await http.get(Uri.parse(trendingweekurl));
      if (trendingweekresponse.statusCode == 200) {
        var tempdata = jsonDecode(trendingweekresponse.body);
        var trendingweekjson = tempdata['results'];
        for (var i = 0; i < trendingweekjson.length; i++) {
          trendinglist.add({
            'id': trendingweekjson[i]['id'],
            'poster_path': trendingweekjson[i]['poster_path'],
            'vote_average': trendingweekjson[i]['vote_average'],
            'media_type': trendingweekjson[i]['media_type'],
            'indexno': i,
          });
        }
      }
    }
  else if(uval == 2){
      var trendingdayresponse = await http.get(Uri.parse(trendingdayurl));
      if (trendingdayresponse.statusCode == 200) {
        var tempdata = jsonDecode(trendingdayresponse.body);
        var trendingdayjson = tempdata['results'];
        for (var i = 0; i < trendingdayjson.length; i++) {
          trendinglist.add({
            'id': trendingdayjson[i]['id'],
            'poster_path': trendingdayjson[i]['poster_path'],
            'vote_average': trendingdayjson[i]['vote_average'],
            'media_type': trendingdayjson[i]['media_type'],

          });
        }
      }
    }else{}
  }


  int uval = 1;



  @override
  Widget build(BuildContext context) {
    TabController _tabController = TabController(length: 3, vsync: this);

    return Scaffold(
      body: CustomScrollView(

        //define o front da barra em carrossel
        slivers: [
          SliverAppBar(
            centerTitle: true,
            toolbarHeight: 60,
            pinned: true,
            expandedHeight: MediaQuery.of(context).size.height * 0.5,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: FutureBuilder(future: trendinglisthome(),
              builder: (context, snapshot){
                if(snapshot.connectionState == ConnectionState.done){
                    return cs.CarouselSlider(
                      options: cs.CarouselOptions(
                        viewportFraction: 1,
                        autoPlay: true,
                        autoPlayInterval: Duration(seconds: 2),
                        height: MediaQuery.of(context).size.height ),
                      items: trendinglist.map((i){
                        return Builder(builder: (BuildContext context){
                          return GestureDetector(
                          onTap: () {},
                            child: GestureDetector(
                              onTap: () {},
                              child: Container(
                                width:  MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    colorFilter: ColorFilter.mode(
                                      Colors.black.withOpacity(0.3),
                                      BlendMode.darken),
                                    image: NetworkImage(


                                      //com essa url + o caminho do filme, é possivel alterar dinamicamente as imagens dando o efeito de carrossel
                                      'http://image.tmdb.org/t/p/w500${i['poster_path']}'),
                                    fit: BoxFit.fill)),
                            )));
                        });
                      }).toList(),
                    );
                }else{
                  return Center(
                    child: CircularProgressIndicator(
                      color: Colors.amber,
                    ));
                }
              }
              ),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Em Alta ' + '🔥',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                SizedBox(width: 10),

                //menu selecionavel entre os melhores da semana e do dia
                Container(
                  height: 45,
                  decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(6)),
                  child: Padding(padding: const EdgeInsets.all(4.0),
                  child: DropdownButton(
                    onChanged: (value){

                      //altera o estado de semana para dia
                      setState(() {
                        trendinglist.clear();
                        uval = int.parse(value.toString());
                      });
                    },

                    icon: Icon(
                      Icons.arrow_drop_down_sharp,
                      color: Colors.amber,
                      size: 30,
                    ),
                    value: uval,
                    //A caixinha entre o da semana e o do dia
                    items: [
                      DropdownMenuItem(
                        child: Text(
                          'Semana',
                           style: TextStyle(
                            decoration: TextDecoration.none,
                            color: Colors.white,
                             fontSize: 16
                  )),
                        value: 1,
                      ),
                        DropdownMenuItem(
                        child: Text(
                        'Dia',
                        style: TextStyle(
                        decoration: TextDecoration.none,
                        color: Colors.white,
                        fontSize: 16
                        )),
                        value: 2,
                        ),
                    ],
                  )),
                ),
              ],
            ),
          ),

          //parte abaixo do carrossel
          SliverList(
            delegate: SliverChildListDelegate.fixed([
                searchbar(),
              Container(
                height: 45,
                width: MediaQuery.of(context).size.width,
                child: TabBar(
                  physics: BouncingScrollPhysics(),
                    labelPadding: EdgeInsets.symmetric(horizontal: 25),
                    isScrollable: true,
                    controller: _tabController,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.amber.withOpacity(0.4)),
                    tabs: [
                      Tab(child: Text('Series de Tv')),
                      Tab(child: Text('Filmes')),
                      Tab(child: Text('Em Breve')),
                ])),
                //puxa os arquivos da pasta SectionPage
                Container(
                  height: 1050,

                  child: TabBarView(controller: _tabController,
                  children: [
                    TvSeries(),
                    Movies(),
                    Upcoming(),
                  ],
                  ),
                )
            ]))
        ],
      ),
    );
  }
}