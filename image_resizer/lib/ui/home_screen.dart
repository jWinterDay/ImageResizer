import 'package:flutter/material.dart';
import 'package:image_resizer/blocs/home_bloc.dart';
import 'package:image_resizer/models/LoadResult.dart';
//import 'dart:ui' as ui;


class HomeScreen extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> with WidgetsBindingObserver {
  HomeBloc _bloc = new HomeBloc();

  //constructor
  _HomeState() {
    //_bloc.loadFirst();
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
    //gUserBloc.dispose();
    //GlobalSettings.
  }

  @override
  Widget build(BuildContext context) {
    //double deviceWidth = MediaQuery.of(context).size.width;
    //double deviceHeight = MediaQuery.of(context).size.height;
    //print('deviceWidth = $deviceWidth, deviceHeight = $deviceHeight');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Home',
        ),
      ),
      body: 
        SingleChildScrollView(
          padding: EdgeInsets.all(2),
          child:
          StreamBuilder(
            initialData: _bloc.getInitData(),
            stream: _bloc.imageStream,
            builder: (context, AsyncSnapshot<LoadResult> snapshot) {
              //print('snapshot = $snapshot');

              return Column(
                children: <Widget>[
                  _buildBtn(snapshot),
                  _buildImage(snapshot),

                  //test frezing animation
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Just to test animation freezing',
                      contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                      prefixIcon:  Icon(Icons.search),
                      hintStyle: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                  FlatButton.icon(
                    label: Text('Just to test animation freezing'),
                    icon: Icon(Icons.image),
                    onPressed: () {
                      print('simple click');
                    }
                  )
                ],
              );
            },
          )
      )
    );
  }

  Widget _buildBtn(AsyncSnapshot<LoadResult> snapshot) {
    LoadResult state = snapshot.data;

    bool isDisabled = snapshot.hasData && state.isLoading;
    var imgColor = isDisabled ? Colors.red.value : Colors.green.value;
    
    return FlatButton.icon(
      label: Text('Load image'),
      icon: Icon(Icons.image, color: Color(imgColor)),
      onPressed: isDisabled ? null : _bloc.loadImage,
    );
  }

  Widget _buildImage(AsyncSnapshot<LoadResult> snapshot) {
    if (snapshot.hasData) {
      LoadResult state = snapshot.data;

      if (state.isLoading) {
        return Center(child: CircularProgressIndicator());
      }

      Image img = state.image;

      if (state.error != null) {
        return Text('[EXCEPTION] ${state.error.toString()}', style: TextStyle(color: Colors.red),);
      }

      if (img == null) {
        return Text('There are errors to load image...');
      }

      return img;
    } else if (snapshot.hasError) {
      return Padding(padding: EdgeInsets.all(16), child: Text(snapshot.error.toString()));
    }

    return Container();
  }
}