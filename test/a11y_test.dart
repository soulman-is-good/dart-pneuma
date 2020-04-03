import 'package:pneuma/src/app.dart';
import 'package:pneuma/src/types.dart';
import 'package:test/test.dart';

void main() {
  test('a11y', () async {
    final server = Pneuma();

    expect(server.status, equals(ServerStatus.NOT_STARTED));
    expect(server, equals(await server.start()));
    expect(server.status, equals(ServerStatus.IDLE));
    await server.stop();
    expect(server.status, equals(ServerStatus.STOPPED));
  });
}
