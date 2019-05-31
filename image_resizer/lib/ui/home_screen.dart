import 'package:flutter/material.dart';
import 'package:image_resizer/blocs/home_bloc.dart';
import 'package:image_resizer/models/CustomImageFormat.dart';
import 'package:image_resizer/models/LoadResult.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> with WidgetsBindingObserver {
  HomeBloc _bloc = new HomeBloc();

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Home',
          ),
        ),
        body: SingleChildScrollView(
            padding: EdgeInsets.all(2),
            child: StreamBuilder(
              //initialData: _bloc.getInitData(),
              stream: _bloc.resultStream, //mergedStream,
              builder: (context, AsyncSnapshot<LoadResult> snapshot) {
                //print('snapshot = $snapshot');

                return Column(
                  children: <Widget>[
                    _buildSettings(snapshot),
                    _buildBtn(snapshot),
                    _buildImage(snapshot),

                    //test frezing animation
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Just to test animation freezing',
                        contentPadding:
                            EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                        prefixIcon: Icon(Icons.search),
                        hintStyle: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                    FlatButton.icon(
                        label: Text('Just to test animation freezing'),
                        icon: Icon(Icons.image),
                        onPressed: () {
                          print('simple click');
                        })
                  ],
                );
              },
            )));
  }

  _formatChanged(val) {
    print(val);
    _bloc.changeSettings(val);
  }

  Widget _buildSettings(AsyncSnapshot<LoadResult> snapshot) {
    //LoadResult data = snapshot.data;

    bool isLoading = snapshot.hasData && snapshot.data.isLoading;
    var cb = isLoading ? null : _formatChanged;
    var groupValue = (snapshot.hasData)
        ? snapshot.data.imageFormat
        : CustomImageFormat.IF_16_TO_9;

    return Row(
      children: <Widget>[
        Radio(
          value: CustomImageFormat.IF_ORIG,
          groupValue: groupValue,
          onChanged: cb,
        ),
        Text('Original'),
        Radio(
          value: CustomImageFormat.IF_16_TO_9,
          groupValue: groupValue,
          onChanged: cb,
        ),
        Text('16/9'),
        Radio(
          value: CustomImageFormat.IF_4_TO_3,
          groupValue: groupValue,
          onChanged: cb,
        ),
        Text('4/3'),
      ],
    );
  }

  Widget _buildBtn(AsyncSnapshot<LoadResult> snapshot) {
    LoadResult state = snapshot.data;

    bool isDisabled = snapshot.hasData && state.isLoading;
    var imgColor = isDisabled ? Colors.red.value : Colors.green.value;

    return FlatButton.icon(
      label: Text('Show next image'),
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
        return Text(
          '[EXCEPTION] ${state.error.toString()}',
          style: TextStyle(color: Colors.red),
        );
      }

      if (img == null) {
        return Container();
      }

      return img;
    } else if (snapshot.hasError) {
      return Padding(
          padding: EdgeInsets.all(16), child: Text(snapshot.error.toString()));
    }

    return Container();
  }
}
