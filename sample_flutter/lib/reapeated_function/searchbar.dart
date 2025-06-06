import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sample_flutter/details/checker.dart';
import 'package:sample_flutter/apikey/apikey.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class searchbar extends StatefulWidget {
  const searchbar({super.key});

  @override
  State<searchbar> createState() => _searchbarState();
}

class _searchbarState extends State<searchbar> {
  List<Map<String, dynamic>> searchResult = [];
  final TextEditingController searchText = TextEditingController();
  bool showList = false;
  var val1;
  bool sortByNewest = true;

  // função que busca os resultados da barra de busca com base no texto inserido

  Future<void> searchListFunction(String val) async {
    var searchUrl =
        'https://api.themoviedb.org/3/search/multi?api_key=$apiKey&query=$val';

    var searchResponse = await http.get(Uri.parse(searchUrl));

    if (searchResponse.statusCode == 200) {
      var tempData = jsonDecode(searchResponse.body);
      var searchJson = tempData['results'];

      searchResult.clear();

      // preenche a lista com base nos dados da API

      for (var item in searchJson) {
        if (item['id'] != null &&
            item['poster_path'] != null &&
            item['vote_average'] != null &&
            item['media_type'] != null) {

          // Define a data correta com base no tipo de mídia
          String? date = item['media_type'] == 'tv'
              ? item['first_air_date']
              : item['release_date'];

          if (date != null && date.isNotEmpty) {
            searchResult.add({
              'id': item['id'],
              'poster_path': item['poster_path'],
              'vote_average': item['vote_average'],
              'media_type': item['media_type'],
              'popularity': item['popularity'],
              'overview': item['overview'],
              'release_date': date,
            });
          }
        }
      }

      // muda ordem da lista com base na função de verificação de data (mais recentes ou mais antigos)


      searchResult.sort((a, b) {
        DateTime dateA = DateTime.tryParse(a['release_date'] ?? '') ?? DateTime(1900);
        DateTime dateB = DateTime.tryParse(b['release_date'] ?? '') ?? DateTime(1900);
        return sortByNewest ? dateB.compareTo(dateA) : dateA.compareTo(dateB);
      });

      if (searchResult.length > 20) {
        searchResult = searchResult.sublist(0, 20);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // esconde o teclado ao tocar fora
        FocusManager.instance.primaryFocus?.unfocus();
        showList = !showList;
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 10.0, top: 30, bottom: 20, right: 10),
        child: Column(
          children: [


            Container(
              height: 50,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: TextField(
                autofocus: false,
                controller: searchText,
                onSubmitted: (value) {

                  // atualiza o valor da busca ao pressionar "enter"

                  setState(() {
                    val1 = value;
                    FocusManager.instance.primaryFocus?.unfocus();
                  });
                },
                onChanged: (value) {

                  // atualiza dinamicamente conforme o usuário digita

                  setState(() {
                    val1 = value;
                  });
                },
                decoration: InputDecoration(

                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        sortByNewest = !sortByNewest;
                      });
                      Fluttertoast.showToast(
                        msg: sortByNewest
                            ? "Ordenado: Mais Recentes"
                            : "Ordenado: Mais Antigos",
                        backgroundColor: Colors.black,
                        textColor: Colors.white,
                      );
                    },
                    icon: Icon(
                      sortByNewest ? Icons.arrow_downward : Icons.arrow_upward,
                      color: Colors.amber.withOpacity(0.8),
                    ),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.amber,
                  ),
                  hintText: 'Pesquisa',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
                  border: InputBorder.none,
                ),
              ),
            ),

            SizedBox(height: 5),

            // mostra os resultados da busca

            if (searchText.text.isNotEmpty)
              FutureBuilder(
                future: searchListFunction(val1),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return SizedBox(
                      height: 400,
                      child: ListView.builder(
                        itemCount: searchResult.length,
                        scrollDirection: Axis.vertical,
                        physics: BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {

                              // entra no item clicado

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => descriptioncheckui(
                                    searchResult[index]['id'],
                                    searchResult[index]['media_type'],
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 4),
                              height: 180,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(20, 20, 20, 1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [

                                  // imagem do pôster
                                  Container(
                                    width: MediaQuery.of(context).size.width * 0.4,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      image: DecorationImage(
                                        image: NetworkImage(
                                          'https://image.tmdb.org/t/p/w500${searchResult[index]['poster_path']}',
                                        ),
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 20),
                                  //função para a data
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${searchResult[index]['media_type']}',
                                                style: TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              SizedBox(height: 2),
                                              Text(
                                                'Lançamento: ${searchResult[index]['release_date'] ?? 'Desconhecido'}',
                                                style: TextStyle(
                                                  color: Colors.white60,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            //media de fotos
                                          children: [
                                              Container(
                                                padding: EdgeInsets.all(5),
                                                height: 30,
                                                decoration: BoxDecoration(
                                                  color: Colors.amber.withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.star, color: Colors.amber, size: 20),
                                                    SizedBox(width: 5),
                                                    Text('${searchResult[index]['vote_average']}'),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              Container(
                                                padding: EdgeInsets.all(5),
                                                height: 30,
                                                decoration: BoxDecoration(
                                                  color: Colors.amber.withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.people_outline, color: Colors.amber, size: 20),
                                                    SizedBox(width: 5),
                                                    Text('${searchResult[index]['popularity']}'),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),

                                          // sinopse

                                          SizedBox(
                                            height: 60,
                                            child: Text(
                                              '${searchResult[index]['overview']}',
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.white,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(color: Colors.amber),
                    );
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}
