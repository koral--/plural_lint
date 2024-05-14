import 'dart:async';
import 'dart:convert';
import 'dart:io';

class CapturingStdout implements Stdout {
  CapturingStdout() {
    _sink = IOSink(_controller.sink, encoding: utf8);
    _output = utf8.decodeStream(_controller.stream);
  }

  final StreamController<List<int>> _controller = StreamController();
  late final Future<String> _output;
  late final IOSink _sink;

  @override
  int get terminalColumns => throw StdoutException('Not supported');

  @override
  int get terminalLines => throw StdoutException('Not supported');

  @override
  bool get supportsAnsiEscapes => false;

  @override
  bool get hasTerminal => false;

  @override
  IOSink get nonBlocking => throw StdoutException('Not supported');

  @override
  Encoding get encoding => _sink.encoding;

  @override
  set encoding(Encoding encoding) {
    _sink.encoding = encoding;
  }

  @override
  void write(Object? object) {
    _sink.write(object);
  }

  @override
  void writeln([Object? object = '']) {
    _sink.writeln(object);
  }

  @override
  void writeAll(covariant Iterable<Object> objects, [String sep = '']) {
    _sink.writeAll(objects, sep);
  }

  @override
  void add(List<int> data) {
    _sink.add(data);
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    _sink.addError(error, stackTrace);
  }

  @override
  void writeCharCode(int charCode) {
    _sink.writeCharCode(charCode);
  }

  @override
  Future<dynamic> addStream(Stream<List<int>> stream) =>
      _sink.addStream(stream);

  @override
  Future<dynamic> flush() => _sink.flush();

  @override
  Future<dynamic> close() => _sink.close();

  @override
  Future<dynamic> get done => _sink.done;

  Future<String> getCapturedOutput() async {
    await flush();
    await close();
    return _output;
  }

  @override
  String lineTerminator = '\n';
}
