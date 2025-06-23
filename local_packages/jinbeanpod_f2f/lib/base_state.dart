import 'package:flutter/material.dart';
import 'figma_to_flutter.dart' as globals;
import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'dart:typed_data';

abstract class BaseState<T extends StatefulWidget> extends State {
  BaseState() : super();
  BaseState.withProperties({this.properties = const {}});
  BaseState.withItems(this.items);
  String name = '';

  String id = '';

  String componentState = 'default';

  String componentName = '';

  String text = '';

  List<Map<String, dynamic>> items = [];

  Map<String, dynamic> properties = {};

  bool isCurrent = false;

  List<Timer> timers = [];
  int reloadCounter = 0;
  Object redrawObject = Object();

  bool triggersBuiltInEvents = true;


  GlobalKey globalKey = GlobalKey();
  /*
   wrap in 
  RepaintBoundary(
        key: globalKey,
        child:
  )
  */
  screenShot() async{
      RenderRepaintBoundary? boundary = globalKey.currentContext?.findRenderObject() as RenderRepaintBoundary;

      ui.Image image = await boundary.toImage();
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      print('IMAGE: \${byteData?.buffer.asUint8List()}');
      /*
  
      var filePath = await ImagePickerSaver.saveFile(
          fileData:byteData.buffer.asUint8List() );
      print(filePath);
      */
  
  }

  void onBuild(BuildContext context) {
    bool? current = ModalRoute.of(context)?.isCurrent;
    current ??= false;

    this.isCurrent = current;
    globals.elementInstances[widget.hashCode] =
        globals.Elem(name: this.name, id: this.id, widget: this);
  }

  void onDispose() {
    // cancel all timers
    for (var i = 0; i < timers.length; i++) {
      timers[i].cancel();
    }
    if (globals.elementInstances.containsKey(widget.hashCode)) {
      globals.elementInstances.remove(widget.hashCode);
    }
  }

  Future<void> reloadAfter(milliseconds) async {
    timers.add(Timer(
        Duration(milliseconds: milliseconds),
        () => setState(() {
              reloadCounter++;
            })));
  }

  void redraw(){
    redrawObject = Object();
  }

  @override
  void dispose() {
    onDispose();
    super.dispose();
  }
}
