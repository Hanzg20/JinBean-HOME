import 'package:flutter/rendering.dart';

abstract class BasePainter extends CustomPainter {

  Map<String, dynamic> properties = {};
  BasePainter({this.properties = const {}}) : super();

  Path strokeAlign(String type, Path stroke, Path fill, double strokeWeight){
        try{
            if(type == 'INSIDE'){
                Path inter = Path.combine(PathOperation.reverseDifference, stroke, fill);
                return Path.combine(PathOperation.xor, inter, fill);
            }else if(type == 'OUTSIDE'){
                Path inter =  Path.combine(PathOperation.union, stroke, fill);
                return Path.combine(PathOperation.xor, inter, fill);
            }
            return stroke;
        }catch(err){
            return stroke;
        }
    }

    Path resizePathIfNeeded(Path path){
        if(properties.containsKey('width') || properties.containsKey('height')){
            final Rect pathBounds = path.getBounds();
            double scalex = properties.containsKey('width') ? (properties['width'].toDouble()) / pathBounds.width : 1.0;
            double scaley = properties.containsKey('height') ? (properties['height'].toDouble()) / pathBounds.height : 1.0;
            final Matrix4 matrix4 = Matrix4.identity();
            matrix4.scale(scalex, scaley);
            path = path.transform(matrix4.storage);
        }
        return path;
    }

    Path movePath(Path path, double moveX, double moveY){
        final Matrix4 matrix4 = Matrix4.identity();
        matrix4.translate(moveX, moveY);
        path = path.transform(matrix4.storage);
        return path;
    }
}