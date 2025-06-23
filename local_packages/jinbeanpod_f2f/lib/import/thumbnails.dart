library bendis.thumbnails;

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

import '../globals.dart' as globals;
import '../bendis_widget.dart';


ParseObject currentProject;

/// Assuming bendis_widget.dart contains all widget classes and list of widgets to capture thumbnail
/// go trough each one and save to project which id is also specified
/// Map<String, dynamic> config = {
///  'baseUrl': 'http://localhost:1389/parse',
///  'appName': 'project1',
///  'appVersion': 'Version 1',
///  'appPackageName': 'com.example.myapplication',
///  'username':'slobodan',
///  'password':'slobodan',
///  'sebastPass':'foobara',
///  'projectId':'12345'
///}
/// List<Map<String, dynamic>> toCapture = [{
///    'name':'myFileName',
///    'widget':()=>Widget22()
/// }];
/// await captureAllThumbnails(config, toCapture);
/// 
/// 
/// 

bool isDone = false;
void capture(Map<String, dynamic> backendConfig, List<Map<String, dynamic>> thumbnailCapture){
  if(!isDone) {
    globals.subscribeToEventOnce('apploaded', (e) async {
        captureAllThumbnails(backendConfig, thumbnailCapture);
    });
  }
}

void captureAllThumbnails(Map<String, dynamic> config, List<Map<String, dynamic>> toCapture) async {

  // make a server connection
  await Parse().initialize(config['appName'], config['baseUrl'],
      appName: globals.isWeb ? config['appName'] : null,
      appVersion: globals.isWeb ? config['appVersion'] : null,
      appPackageName: globals.isWeb ? config['appPackageName'] : null,
      debug: false,
      autoSendSessionId: true,
      coreStore: await CoreStoreSembastImp.getInstance(password: config['sebastPass']));
  
  var projectId = config['projectId'];

  // var uname = config['username'];
  // var pass = config['password'];
  // var user = ParseUser(uname, pass, "");
  // ParseResponse userResponse = await user.login();
  // if (!userResponse.success) {
  //   print('Could not log in  {user}');
  //   return;
  // }

  var user = await ParseUser.currentUser();

  // get project reference
  var q = QueryBuilder<ParseObject>(ParseObject("CollabProject"))
      ..whereEqualTo('objectId', projectId);
  ParseResponse response = await q.query();
  if (!response.success || !response.results.isNotEmpty) {
    print('Could not find project  {projectId}');
    return;
  }
  currentProject = response.results[0];

  // when done run the app normally
  done(){
    isDone = true;
    globals.navigatorKey.currentState.pushReplacement(MaterialPageRoute(builder: (context){
      return const BendisWidget();
    }));
  }

  // replace current screen with ThumbnailGenerator widget
  globals.navigatorKey.currentState.pushReplacement(MaterialPageRoute(builder: (context){
    return ThumbnailGenerator(toCapture, currentProject, done);
  }));
  
}


class ThumbnailGenerator extends StatefulWidget {

    final List<Map<String, dynamic>> toCapture;
    final ParseObject project;
    final _captureKey = GlobalKey<CaptureWidgetState>();
    final Function() done;
    ThumbnailGenerator(this.toCapture, this.project, this.done, {super.key});

    @override
    _ThumbnailGeneratorState createState() {
        return _ThumbnailGeneratorState();
    }
}
class _ThumbnailGeneratorState extends State<ThumbnailGenerator> {
    int count = 0;
    
    @override
    void initState() {
        super.initState();


        // globals.subscribeToEvent('captureWidgetLoaded', (e) async {
        //   print('EVT capture widget loaded');
        // });
    }

    @override
    Widget build(BuildContext context) {
      if(count < widget.toCapture.length){

        Map<String, dynamic> item = widget.toCapture[count];
        var getWidget = item['widget'] as Function;
        var widgetToCapture = getWidget();

        if(widgetToCapture == null) {
          return const Text('Unknown widget');
        }

        // Timer ended
        // Widget Widget328100
        // TypeError: Cannot read property 'toString' of null


        var child = CaptureWidget(
          key: widget._captureKey,
          capture: widgetToCapture,
          child: const Text(' {count} Generating \${widgetToCapture?.nodeName} thumbnail')
        );

        Timer( const Duration(milliseconds: 300), () async {
            print('Timer ended');
            await doCapture(widget._captureKey.currentState, item);
            setState((){
              count = count + 1;
              print('New count:  {count}');
            });
        });

        return child;
      }else{
        Timer( const Duration(milliseconds: 300), ()=>widget.done());
        return const Text('Done.');
      }
      
    }


    doCapture(dynamic capturer, Map<String, dynamic> item) async{
      String fileName = item['name'];
      String nodeId = item['id'];
      String state = item['state'];
      String type = item['type'];
      String componentType = item['componentType'];

      var widgetToCapture = capturer.widget.capture;
      //var fileName = widgetToCapture?.nodeName.replaceAll(new RegExp(r'[^a-zA-Z0-9]'), '_');

      print(' {widgetToCapture}  {fileName}');

      var image;
      try{
        image = await capturer.captureImage();
      }catch(err){
        print('Error catch,  {err}');
        return;
      }

      if(image == null) return;
      print('IMAGE: \${_image.width} \${_image.height}');
      ParseFileBase parseFile;
      if (globals.isWeb) {
        parseFile = ParseWebFile(image.data, name: ' {fileName}.png');
      }else{
        print('TODO: Test native file');
        parseFile = ParseWebFile(image.data, name: ' {fileName}.png');
      }
      // create or update file
      var name = widgetToCapture?.nodeName;
      var q = QueryBuilder<ParseObject>(ParseObject("CollabProjectFile"))
      ..whereEqualTo('project', widget.project)
      ..whereEqualTo('Name', name)
      ..setLimit(1);
      ParseResponse response = await q.query();
      if (response.success && response.results != null && response.results.isNotEmpty) {
        var doc = response.results[0];
        doc.set('File', parseFile);
        await doc.save();
      }else{
        var doc = ParseObject('CollabProjectFile');
        doc.set('project', widget.project);
        doc.set('File', parseFile);
        doc.set('Name', name);
        doc.set('nodeId', nodeId);
        doc.set('state', state);
        doc.set('type', type);
        doc.set('componentType', componentType);
        await doc.save();
      }
    }
}



class CaptureWidget extends StatefulWidget {
  final Widget child;
  final Widget capture;

  const CaptureWidget({
    Key key,
    this.capture,
    this.child,
  }) : super(key: key);

  @override
  CaptureWidgetState createState() => CaptureWidgetState();
}

class CaptureWidgetState extends State<CaptureWidget> {
  final _boundaryKey = GlobalKey();

  Future<CaptureResult> captureImage() async {
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final boundary = _boundaryKey.currentContext.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return CaptureResult(data.buffer.asUint8List(), image.width, image.height);
  }

  @override
  void initState() {
     // Timer( Duration(milliseconds: 1), ()=>globals.triggerEvent('captureWidgetLoaded', '', this) );
  }

  @override
  Widget build(BuildContext context) {

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final height = constraints.maxHeight * 2;
        return Stack(
          fit: StackFit.passthrough,
          children: <Widget>[
            widget.child,
            Positioned(
              left: 0.0,
              right: 0.0,
              top: height,
              height: height,
              child: Center(
                child: RepaintBoundary(
                  key: _boundaryKey,
                  child: widget.capture,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class CaptureResult {
  final Uint8List data;
  final int width;
  final int height;

  const CaptureResult(this.data, this.width, this.height);
}