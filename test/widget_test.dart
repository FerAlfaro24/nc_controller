import 'package:flutter_test/flutter_test.dart';
import 'package:nc_controller/main.dart';

void main() {
  testWidgets('Prueba básica de la aplicación', (WidgetTester tester) async {
    // Construir nuestra aplicación y activar un frame
    await tester.pumpWidget(const AplicacionPrincipal());

    // Verificar que existe el título
    expect(find.text('NABOO CUSTOMS'), findsOneWidget);
    expect(find.text('CENTRO DE CONTROL'), findsOneWidget);
  });
}