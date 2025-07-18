//@JS()
library genf;


//import 'stub.dart' if (dart.library.js) 'package:js/js.dart';
//import 'package:js/js.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:math' as math;

import 'app.dart';

//import 'package:flutter_test/flutter_test.dart'; // https://api.flutter.dev/flutter/flutter_test/CommonFinders-class.html
var isWeb = kIsWeb;

class Elem {
  final String name;
  final String id;
  final dynamic widget;
  String type = "";
  String componentName;
  dynamic painter;
  String pageName="";
  Elem({this.name="", this.id="", this.widget, this.componentName=""});
}

class Event {
  final String eventName;
  final Function(Event) callback;
  final String componentName;
  final int componentIndex;
  Elem target = Elem();
  int id = 0;
  String payload = "";
  Map<String, dynamic> data = {};
  Event(this.eventName, this.callback, this.componentName, this.componentIndex);
}

class GradientReshape extends GradientTransform {
    final double radians;
    final double scaleX;
    final double scaleY;
    const GradientReshape(this.radians, this.scaleX, this.scaleY);
    @override
    Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {

        final double rads = radians - math.pi/2;
        final double sinRadians = math.sin(rads);
        final double oneMinusCosRadians = 1 - math.cos(rads);
        Offset center = bounds.center;

        final double dx = center.dx * (1 - scaleX);
        final double dy = center.dy * (1 - scaleY);
        final double originX = (sinRadians * center.dy + oneMinusCosRadians * center.dx);
        final double originY = -sinRadians * center.dx + oneMinusCosRadians * center.dy;

        return Matrix4.identity()
            ..translate(originX, originY)
            ..rotateZ(rads)
            ..translate(dx, dy)
            ..scale(scaleX, scaleY)
            ; 
    }
}


class GradientTransformMatrix extends GradientTransform {
    final Matrix4 matrix;
    const GradientTransformMatrix(this.matrix);
    @override
    Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
        return matrix; 
    }
}

Map<String, List<Event>> simpleEvents = {};
Map<String, Map<String, Map<int, List<Event>>>> eventSubscriptions = {};

Map<int, Elem> elementInstances = {};
Map<String, Elem> screenClasses = {};
Map<String, Image> images = {};
String currentScreenName = '';

bool isInitialized = false;

App getApp({withInit=Function}){
  if(!isInitialized){
    //if(isWeb) jsInteropInit();
    isInitialized = true;
  }
  withInit ??= (){};
  return App(withInit);
}

List<Elem> getElementsByName(String name, [int limit = 1]) {
  List<Elem> results = [];
  int cnt = 0;
  for (int key in elementInstances.keys) {
    if ((elementInstances[key]?.name == name ||
            elementInstances[key]?.componentName == name) &&
        elementInstances[key]?.widget.mounted == true) {
      results.add(elementInstances[key]!);
      cnt++;
    }
    if (cnt == limit) {
      break;
    }
  }
  return results;
}

Elem getFirstElementByName(String name) {
  var elems = getElementsByName(name);
  return elems.isNotEmpty ? elems[0] : Elem();
}

void setComponentState(String name, String stateName,
    [int index = 0, bool asDefault = false]) {
  var elems = getElementsByName(name, index + 1);

  if (index < elems.length) {
    elems[index].widget?.setState(() {
      elems[index].widget.componentState = stateName;
      if (asDefault) elems[index].widget.defaultState = stateName;
    });
  }
}

String getComponentState(String name, [int index = 1]) {
  var elems = getElementsByName(name, index);
  if (index < elems.length) {
    return elems[index].widget?.componentState;
  }
  return '';
}

void setComponentImageUrl(String name, String url, [int index = 0]) {
  var elems = getElementsByName(name, index + 1);
  if (index < elems.length) {
    elems[index].widget?.setState(() {
        elems[index].widget?.image = Image.network(url);
    });
  }
}

void setComponentText(String name, String text, [int index = 0]) {
  var elems = getElementsByName(name, index + 1);
  if (index < elems.length) {
    var type = elems[index].widget?.widget?.componentType;
    if(type == 'TextInput' || type == 'MultiTextInput'){
      elems[index].widget?.setState(() {
        elems[index].widget?.controller?.text = text;
      });
    }else{
      elems[index].widget?.setState(() {
        elems[index].widget?.characters = text;
      });
    }
  }
}

String getComponentText(String name, [int index = 0]) {
  var elems = getElementsByName(name, index + 1);
  if (index < elems.length) {
    var type = elems[index].widget?.widget?.componentType;
    if(type == 'TextInput' || type == 'MultiTextInput'){
      return elems[index].widget?.controller?.text;
    }else{
      return elems[index].widget?.characters;
    }
  }
  return "";
}

List<Map<String, dynamic>> parseItems(dynamic itemsString){
  List<Map<String, dynamic>> items = [];
  if(itemsString is String){
    List<dynamic> rawItems = jsonDecode(itemsString);
    for (var i = 0; i < rawItems.length; i++) {
      items.add(rawItems[i] as Map<String, dynamic>);
    }
  }else if(itemsString is List<dynamic>){
    for (var i = 0; i < itemsString.length; i++) {
      items.add(itemsString[i] as Map<String, dynamic>);
    }
  }else if(itemsString is List<Map<String, dynamic>>){
    for (var i = 0; i < itemsString.length; i++) {
      items.add(itemsString[i]);
    }
  }
  return items;
}

Map<String, dynamic> parseItem(dynamic item){
  Map<String, dynamic> res = {};
  if(item is String){
    dynamic rawItem = jsonDecode(item);
    return rawItem as Map<String, dynamic>;
  }else if(item is Map<String, dynamic>){
    return item;
  }
  return res;
}

void setComponentItems(String name, dynamic itemsString, [int index = 0]) {
  List<Map<String, dynamic>> items = parseItems(itemsString);
  
  var elems = getElementsByName(name, index + 1);
  if (index < elems.length) {
    elems[index].widget?.setState(() {
      elems[index]
          .widget
          ?.items
          ?.replaceRange(0, elems[index].widget.items.length, items);
    });
  }
}

void replaceComponentItems(String name, dynamic itemsString,
    [int index = 0, int offset = 0]) {
  List<Map<String, dynamic>> items = parseItems(itemsString);
  var elems = getElementsByName(name, index + 1);
  if (index < elems.length) {
    elems[index].widget?.setState(() {
      elems[index]
          .widget
          ?.items
          ?.replaceRange(offset, offset + items.length, items);
    });
  }
}



void addComponentItems(String name, dynamic itemsString, [int index = 0]) {
  List<Map<String, dynamic>> items = parseItems(itemsString);
  var elems = getElementsByName(name, index + 1);
  if (index < elems.length) {
    elems[index].widget?.setState(() {
      for (var i = 0; i < items.length; i++) {
        elems[index].widget?.items?.add(items[i]);
      }
    });
  }
}

void setComponentProperties(String name, String props, [int index = 0]) {
  Map<String, dynamic> properties = jsonDecode(props);
  var elems = getElementsByName(name, index + 1);

  if (index < elems.length) {
    elems[index].widget?.setState(() {
      elems[index].widget?.properties = properties;
    });
  }
}

void openAppPage(String name) {
  if (screenClasses.containsKey(name)) {
    //navigatorKey.currentState.push(MaterialPageRoute(builder: (context) => screenClasses[name].widget));
    //navigatorKey.currentState.pushReplacement(MaterialPageRoute(builder: (context) => screenClasses[name].widget));
    
    String componentType = screenClasses[name]?.type ?? '';
    if(componentType == 'popups'){
      //final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();
      showGeneralDialog(
                    context: navigatorKey.currentState?.context,
                    useRootNavigator:false,
                    barrierLabel:'Discard',
                    barrierDismissible:true,
                    barrierColor: const Color(0x00000000),
                    transitionDuration: const Duration(milliseconds: 500),
                    pageBuilder: (BuildContext buildContext, Animation animation, Animation secondaryAnimation) {
                        return screenClasses[name]?.widget;
                    }
                );
    }else{
      // if(navigatorKey.currentState?.canPop() ?? false){
      //   navigatorKey.currentState?.pop();
      // }
      navigatorKey.currentState?.pushReplacement(
        PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => screenClasses[name]?.widget,
            transitionDuration: const Duration(seconds: 0),
        ),
      );
    }


  }
}

int getWidgetHashCode(String name, [int index = 0]) {
  var elems = getElementsByName(name, index + 1);
  if (index < elems.length) {
    var code = elems[index].widget?.widget?.hashCode;
    code ??= -1;
    return code;
  }
  return -1;
}

void setDropdownValues(String name, List<dynamic> values, [int index = 0]) {
  var elems = getElementsByName(name, index + 1);

  List<String> vals = List.from(values);

  if (index < elems.length) {
    elems[index].widget?.setState(() {
      elems[index].widget?.values = vals;
      elems[index].widget?.dropdownValue = elems[index].widget?.values[0];
    });
  }
}

void triggerComponentEvent(String eventName, int hashCode, String componentName, [dynamic payload = '']) {

  bool? hasSubs = eventSubscriptions.containsKey(eventName);
  if(hasSubs) hasSubs = eventSubscriptions[eventName]?.containsKey(componentName);
  hasSubs ??= false;
  if(hasSubs) hasSubs = elementInstances.containsKey(hashCode);

  if (hasSubs) {
    var el = elementInstances[hashCode];
    eventSubscriptions[eventName]?[componentName]?.forEach((key, value) {
      var events = eventSubscriptions[eventName]?[componentName]?[key];
      events ??= [];
      for (var i = 0; i < events.length; i++) {
        Event evt = events[i];
        el ??= Elem();
        evt.target = el as Elem;
        if (payload is String) {
          evt.payload = payload;
        }else if(payload is Map<String, dynamic>){
          evt.data = payload;
        }
        evt.callback(evt);
      }
    });

    //var elems = getElementsByName(componentName, 100);
    //int idx = elems.indexOf(el);
    /*
    if (idx != -1 &&
        eventSubscriptions[eventName][componentName].containsKey(idx)) {
      var events = eventSubscriptions[eventName][componentName][idx];
      for (var i = 0; i < events.length; i++) {
        Event evt = events[i];
        evt.target = el;
        evt.payload = payload;
        evt.callback(evt);
      }
    }
    */

  }
  // if (kIsWeb) {
  //   triggerComponentEventJS(eventName, hashCode, componentName, payload);
  // }
}

int subscribeToEvent(String eventName, Function(Event) callback) {
  var event = Event(eventName, callback, '', 0);
  if(!simpleEvents.containsKey(eventName)){
    simpleEvents[eventName] = List<Event>.empty(growable: true);
  }
  simpleEvents[eventName] ??= List<Event>.empty(growable: true);
  simpleEvents[eventName]?.add(event);
  var length = simpleEvents[eventName]?.length;
  length ??= 0;
  return length - 1;
}
int subscribeToEventOnce(String eventName, Function(Event) callback) {
  int evtId = 0;
  evtId = subscribeToEvent(eventName, (Event evt){
    if((simpleEvents[eventName]?.length ?? 0) > evtId) simpleEvents[eventName]?.removeAt(evtId);
    callback(evt);
  });
  return evtId;
}

void triggerEvent(String eventName, [String payload = '', Map<String, dynamic> data = const {}]) {
  //if(eventName == 'pageLoaded'){ removeAllComponentEvents(); } // remove all component events from previous page
  if (simpleEvents.containsKey(eventName)) {
    int? length = simpleEvents[eventName]?.length;
    length ??= 0;
    for(int i=0 ;i<length; i++){
      Event evt = simpleEvents[eventName]![i];
      if(data.containsKey('target')) evt.target = data['target'];
      evt.payload = payload;
      evt.callback(evt);
    }
  }
}

/*
  Subscribes to events emitted by the components
  - eventName is Flutter event name (tap, tapUp, tapDown ...)
  - index is index of componentName in case there are multiple instances with the same name, defaults to 0 (first found element with componentName)
  Example:
  Event myEvent = subscribeToComponentEvent('tap', 'MyButton', (e){
     print('Target: \${e.target}, Payload: \${e.payload}');
  })
*/
Event subscribeToComponentEvent(
    String eventName, String componentName, Function(Event) callback,
    [int index = 0]) {
  var evt = Event(eventName, callback, componentName, index);
  if (!eventSubscriptions.containsKey(eventName)) eventSubscriptions[eventName] = <String, Map<int, List<Event>>>{};


  bool? hasComponent = eventSubscriptions[eventName]?.containsKey(componentName);
  hasComponent ??= false;
  if (!hasComponent) eventSubscriptions[eventName]?[componentName] = <int, List<Event>>{};

  bool? hasEvent = eventSubscriptions[eventName]?[componentName]?.containsKey(index);
  hasEvent ??= false;
  if (!hasEvent) eventSubscriptions[eventName]?[componentName]?[index] = List<Event>.empty(growable: true);

  eventSubscriptions[eventName]?[componentName]?[index]?.add(evt);

  int? length = eventSubscriptions[eventName]?[componentName]?[index]?.length;
  length ??= 0;
  evt.id = length - 1;
  return evt;
}

/*
  Removes component event
  - evt is Event returned by the subscribeToComponentEvent 
  Example:
  removeComponentEvent(myEvent);
*/
void removeComponentEvent(Event evt) {
  bool? hasEvent = eventSubscriptions.containsKey(evt.eventName);
  if(hasEvent) hasEvent = eventSubscriptions[evt.eventName]?.containsKey(evt.componentName);
  hasEvent ??= false;
  if(hasEvent) hasEvent = eventSubscriptions[evt.eventName]?[evt.componentName]?.containsKey(evt.componentIndex);
  hasEvent ??= false;
  if (hasEvent) {
    int? length = eventSubscriptions[evt.eventName]?[evt.componentName]?[evt.componentIndex]?.length;
    length ??= 0;
    if (length < evt.id) {
      eventSubscriptions[evt.eventName]?[evt.componentName]?[evt.componentIndex]?.removeAt(evt.id);
    }
  }
}

void removeAllComponentEvents() {
  var toRemove = List<String>.empty(growable: true);
  eventSubscriptions.forEach((k, v) => toRemove.add(k));
  for (int i = 0; i < toRemove.length; i++) {
    eventSubscriptions.remove(toRemove[i]);
  }
}

String getLocationSearch(){
  var uri = Uri.base;
  return uri.query;
}

dynamic getWidgetInstanceByName(String name, {Map<String, dynamic> properties = const {}}) {
  var elem = getFirstElementByName(name);
  return elem.widget.widget.createInstance(properties);
}

// navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Scaffold Messender key
final GlobalKey<ScaffoldMessengerState> scaffoldKey =
    GlobalKey<ScaffoldMessengerState>();

// startup

// JS INTEROP

/*
void jsInteropInit() {
  _navigateToPage = allowInterop(openAppPage);

  _setComponentState = allowInterop(setComponentState);

  _setComponentText = allowInterop(setComponentText);
  _getComponentText = allowInterop(getComponentText);

  

  _setComponentItems = allowInterop(setComponentItems);
  _replaceComponentItems = allowInterop(replaceComponentItems);
  _addComponentItems = allowInterop(addComponentItems);

  _setComponentProperties = allowInterop(setComponentProperties);

  _getWidgetHashCode = allowInterop(getWidgetHashCode);

  _setDropdownValues = allowInterop(setDropdownValues);
}

/// JavaScript Control
/// Allows assigning a function to be callable from `window.navigateToPage('Page name')`
@JS('navigateToPage')
external set _navigateToPage(void Function(String name) f);
@JS()
external void navigateToPage(String name);

@JS('setComponentState')
external set _setComponentState(
    void Function(String name, String stateName, int index, bool isDefault) f);

@JS('setComponentText')
external set _setComponentText(
    void Function(String name, String text, int index) f);

@JS('getComponentText')
external set _getComponentText(String Function(String name, int index) f);

@JS('setComponentProperties')
external set _setComponentProperties(
    void Function(String name, String properties, int index) f);

@JS('setComponentItems')
external set _setComponentItems(
    void Function(String name, String items, int index) f);

@JS('replaceComponentItems')
external set _replaceComponentItems(
    void Function(String name, String items, int index, int offset) f);

@JS('addComponentItems')
external set _addComponentItems(
    void Function(String name, String items, int index) f);

@JS('getWidgetHashCode')
external set _getWidgetHashCode(int Function(String name, int index) f);

@JS('callFuncJS')
external String callFuncJS(String funcName, String params, String selector);

@JS('triggerComponentEventJS')
external String triggerComponentEventJS(
    String eventName, int hashCode, String componentName,
    [String payload = '']);

@JS('setDropdownValues')
external set _setDropdownValues(
    void Function(String name, List<dynamic> values, int index) f);

*/