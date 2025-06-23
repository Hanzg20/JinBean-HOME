import 'package:flutter/material.dart';
import 'bendis_widget.dart';
import 'figma_to_flutter.dart' as globals;


class App extends StatelessWidget {

    const App(this.init, {super.key});
    final Function init;

    @override
    Widget build(BuildContext context) {
        init();
        return GestureDetector(
            onTap: () {
              globals.triggerEvent('tapOutside');
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              }
            },
            child: MaterialApp(
        scaffoldMessengerKey: globals.scaffoldKey,
              home: const BendisWidget(),
              navigatorKey: globals.navigatorKey,
            ),
        );
    }
}