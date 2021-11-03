
import 'dart:math';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meme Generator',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".


  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey globalKey = new GlobalKey();

  String headertext = "";
  String footertext = "";

  File _image;
  File _imageFile;

  bool SelectedImage = false;

  Random rng = new Random();

  Future getImage() async{
    var image;
    try{
      image = await ImagePicker.pickImage(source: ImageSource.gallery);
    } catch(platformException){
      print("not allowing "+ platformException);
    }
    setState(() {
      if(image != null){
        SelectedImage = true;
      }else{}
      _image = image;
    });
    new Directory('storage/emulated/0/'+'Meme Generator').create(recursive: true);

  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 50,
              ),
              Image.asset(
                "assets/memegenrator.png",
                height: 70,
              ),
              SizedBox(
                height: 14,
              ),
              RepaintBoundary(
                key: globalKey,
                child: Stack(
                  children: <Widget>[
                    _image != null
                        ? Image.file(
                      _image,
                      height: 300,
                      fit: BoxFit.fitHeight,
                    )
                        : Container(),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 300,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              headertext.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 26,
                                shadows: <Shadow>[
                                  Shadow(
                                    offset: Offset(2.0, 2.0),
                                    blurRadius: 3.0,
                                    color: Colors.black87,
                                  ),
                                  Shadow(
                                    offset: Offset(2.0, 2.0),
                                    blurRadius: 8.0,
                                    color: Colors.black87,
                                  ),
                                ],),

                            ),
                          ),
                          Spacer(),
                          Container(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                footertext.toUpperCase(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 26,
                                  shadows: <Shadow>[
                                    Shadow(
                                      offset: Offset(2.0, 2.0),
                                      blurRadius: 3.0,
                                      color: Colors.black87,
                                    ),
                                    Shadow(
                                      offset: Offset(2.0, 2.0),
                                      blurRadius: 8.0,
                                      color: Colors.black87,
                                    ),
                                  ],),
                              ))
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              SelectedImage
                  ? Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: <Widget>[
                    TextField(
                      onChanged: (val) {
                        setState(() {
                          headertext = val;
                        });
                      },
                      decoration: InputDecoration(hintText: "Header Text"),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    TextField(
                      onChanged: (val) {
                        setState(() {
                          footertext = val;
                        });
                      },
                      decoration: InputDecoration(hintText: "Footer Text"),
                    ),
                    SizedBox(height: 20,),
                    RaisedButton(
                      onPressed: () {
                        //TODO
                        takeScreenshot();
                      },
                      child: Text("Save"),
                    )
                  ],
                ),
              )
                  : Container(
                child: Center(
                  child: Text("Select image to get started"),
                ),
              ),
              _imageFile != null ? Image.file(_imageFile) : Container(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          getImage();
        },
        child: Icon(Icons.add_a_photo),
      ),
    );
  }
  takeScreenshot () async{
      RenderRepaintBoundary boundary = globalKey.currentContext.findRenderObject();
      ui.Image image = await boundary.toImage();
      final directory = (await getApplicationDocumentsDirectory()).path;
      ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();
      print(pngBytes);
      File imgFile = File('$directory/screenshot${rng.nextInt(200)}.png');
      setState(() {
        _imageFile = imgFile;
      });
      _savefile(_imageFile);
      //saveFileLocal();
      imgFile.writeAsBytes(pngBytes);
  }

  _savefile(File file) async {
    await _askPermission();
    final result = await ImageGallerySaver.saveImage(
        Uint8List.fromList(await file.readAsBytes()));
    print(result);
  }
  _askPermission() async {
    Map<PermissionGroup, PermissionStatus> permissions =
    await PermissionHandler().requestPermissions([PermissionGroup.photos]);
  }
}
