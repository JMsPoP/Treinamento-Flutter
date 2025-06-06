import 'package:flutter/material.dart';
import 'package:sample_flutter/details/moviesdetails.dart';
import 'package:sample_flutter/details/tvseriesdetails.dart';


class descriptioncheckui extends StatefulWidget {
  //precisa do tipo de media para enviar para um ou outro codigo, e do id para receber a descrição do filme escolhido
var newid;
var newtype;


  descriptioncheckui(this.newid, this.newtype);

  @override
  State<descriptioncheckui> createState() => _descriptioncheckuiState();
}

class _descriptioncheckuiState extends State<descriptioncheckui> {

  //verifica qual o media_type do arquivo e envia para o ou movie details ou series details
checktype(){
  if(widget.newtype =='movie'){
    return MoviesDetails(widget.newid);
  }else if(widget.newtype == 'tv'){
    return TvSeriesDetails(widget.newid);
  }else {
    return errorui();
  }
}

  @override
  Widget build(BuildContext context) {

  //retorna a função anterior
    return checktype();
  }
}
Widget errorui(){
  return Scaffold(
    body: Center(
      child: Text("Error"),
    ),
  );

}