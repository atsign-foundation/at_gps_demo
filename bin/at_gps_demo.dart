import 'dart:convert';
import 'dart:io';

void main(List<String> arguments) async {
  int port = 2947;
  List<int> dataBuffer = [];

  var socket = await Socket.connect('localhost', port);
  print('Client connected');

  try {
    socket.listen((List<int> event) {
      dataBuffer = bufferMe(event, dataBuffer);
    });

    var send = '?WATCH={"enable":true,"json":true};';
    socket.writeln(send);
  } on Exception catch (exception) {
    print('Unable to connect to server:  On port $port : $exception');
  } catch (error) {
    print('Errors occured: $error');
  }
}

List<int> bufferMe(data, List<int> dataBuffer) {
  dataBuffer.addAll(data);
  String query = utf8.decode(dataBuffer);
  var len = query.length;
        print('\n\r############$query\n\r###########');
  if (!query.contains('"lat"') || !query.contains('"lon"')) {
    // the first line just gives us a version number
    // we will ignore and reset the buffer
    dataBuffer.length = 0;
  } else {
    if (query[len - 1] == '\n') {
      try {
        query = query.trimRight();
        query = query.trimLeft();
        
        var json = jsonDecode(query.toString());
        Map send = {};
        send['lat'] = (json['lat'].toString());
        send['lon'] = (json['lon'].toString());
        send['speed'] = (json['speed'].toString());

        var sender = jsonEncode(send);
        print(sender);
      } catch (e) {
        print(e.toString());
      }
      // Reset the buffer
      dataBuffer = [];
    }
  }
  return (dataBuffer);
}
