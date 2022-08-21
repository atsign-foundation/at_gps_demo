import 'dart:convert';

import 'package:at_gps_demo/at_gps_demo.dart' as at_gps_demo;
import 'dart:io';

List<int> data_buffer = [];
List<int> datain_buffer = [];

void main(List<String> arguments) async {
  int port = 2947;

  var socket = await Socket.connect('localhost', port);
  print('Client connected');

  try {
    socket.listen((List<int> event) {
      bufferMe(event);
    });

    var send = '?WATCH={"enable":true,"json":true};';
    socket.writeln(send);
  } on Exception catch (exception) {
    print('Something bad happened on connection to server: ' +
        exception.toString());
  } catch (error) {
    print('Errors occur' + error.toString());
  }
}

void bufferMe(data) {
  datain_buffer.addAll(data);
  String query = utf8.decode(datain_buffer);
  var len = query.length;
  if (query[len - 1] == '\n') {
    try {
      query = query.trimRight();
      query = query.trimLeft();
      var json = jsonDecode(query.toString());
      //print(query);
      Map send = {};
      send['lat'] = (json['lat'].toString());
      send['lon'] = (json['lon'].toString());
      send['speed'] = (json['speed'].toString());

      var sender = jsonEncode(send);
      print(sender);
    } catch (e) {
      // print(e.toString());
    }
  }
  datain_buffer = [];
}
