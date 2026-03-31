import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stylo_ai/shared/widgets/stylo_text_field.dart';

Widget buildTestApp(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    ),
  );
}

void main() {
  group('StyloTextField', () {
    group('basic rendering', () {
      testWidgets('renders without throwing', (tester) async {
        await tester.pumpWidget(buildTestApp(
          const StyloTextField(),
        ));

        expect(find.byType(StyloTextField), findsOneWidget);
      });

      testWidgets('renders TextFormField internally', (tester) async {
        await tester.pumpWidget(buildTestApp(
          const StyloTextField(),
        ));

        expect(find.byType(TextFormField), findsOneWidget);
      });

      testWidgets('renders label when provided', (tester) async {
        await tester.pumpWidget(buildTestApp(
          const StyloTextField(label: 'Email'),
        ));

        expect(find.text('Email'), findsOneWidget);
      });

      testWidgets('renders hint text when provided', (tester) async {
        await tester.pumpWidget(buildTestApp(
          const StyloTextField(hint: 'Enter your email'),
        ));

        expect(find.text('Enter your email'), findsOneWidget);
      });

      testWidgets('renders without label or hint', (tester) async {
        await tester.pumpWidget(buildTestApp(
          const StyloTextField(),
        ));

        expect(find.byType(TextFormField), findsOneWidget);
      });
    });

    group('controller', () {
      testWidgets('uses provided controller', (tester) async {
        final controller = TextEditingController(text: 'initial value');
        await tester.pumpWidget(buildTestApp(
          StyloTextField(controller: controller),
        ));

        expect(find.text('initial value'), findsOneWidget);
        controller.dispose();
      });

      testWidgets('reflects controller text changes', (tester) async {
        final controller = TextEditingController();
        await tester.pumpWidget(buildTestApp(
          StyloTextField(controller: controller),
        ));

        controller.text = 'updated value';
        await tester.pump();
        expect(find.text('updated value'), findsOneWidget);
        controller.dispose();
      });

      testWidgets('allows text input when no controller provided', (tester) async {
        await tester.pumpWidget(buildTestApp(
          const StyloTextField(),
        ));

        await tester.enterText(find.byType(TextFormField), 'typed text');
        expect(find.text('typed text'), findsOneWidget);
      });
    });

    group('obscureText', () {
      testWidgets('obscures text when obscureText is true', (tester) async {
        await tester.pumpWidget(buildTestApp(
          const StyloTextField(obscureText: true),
        ));

        // Access the underlying EditableText to check obscureText
        final editableText = tester.widget<EditableText>(
          find.byType(EditableText),
        );
        expect(editableText.obscureText, isTrue);
      });

      testWidgets('does not obscure text by default', (tester) async {
        await tester.pumpWidget(buildTestApp(
          const StyloTextField(),
        ));

        final editableText = tester.widget<EditableText>(
          find.byType(EditableText),
        );
        expect(editableText.obscureText, isFalse);
      });

      testWidgets('maxLines forced to 1 when obscureText is true', (tester) async {
        await tester.pumpWidget(buildTestApp(
          const StyloTextField(obscureText: true, maxLines: 5),
        ));

        // When obscureText is true, the underlying EditableText maxLines is 1
        final editableText = tester.widget<EditableText>(
          find.byType(EditableText),
        );
        expect(editableText.maxLines, 1);
      });
    });

    group('validator', () {
      testWidgets('calls validator on form validation', (tester) async {
        final formKey = GlobalKey<FormState>();
        String? validatorResult;

        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: StyloTextField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Field is required';
                  }
                  validatorResult = null;
                  return null;
                },
              ),
            ),
          ),
        ));

        formKey.currentState!.validate();
        await tester.pump();

        expect(find.text('Field is required'), findsOneWidget);
        expect(validatorResult, isNull);
      });

      testWidgets('shows no error when validator returns null', (tester) async {
        final formKey = GlobalKey<FormState>();

        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: StyloTextField(
                validator: (value) => null,
              ),
            ),
          ),
        ));

        formKey.currentState!.validate();
        await tester.pump();

        // No error text should appear
        expect(find.text('Field is required'), findsNothing);
      });

      testWidgets('validator receives entered text', (tester) async {
        String? capturedValue;
        final formKey = GlobalKey<FormState>();

        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: StyloTextField(
                validator: (value) {
                  capturedValue = value;
                  return null;
                },
              ),
            ),
          ),
        ));

        await tester.enterText(find.byType(TextFormField), 'hello');
        formKey.currentState!.validate();
        await tester.pump();

        expect(capturedValue, 'hello');
      });
    });

    group('suffix and prefix icons', () {
      testWidgets('renders suffix icon when provided', (tester) async {
        await tester.pumpWidget(buildTestApp(
          const StyloTextField(
            suffixIcon: Icon(Icons.visibility),
          ),
        ));

        expect(find.byIcon(Icons.visibility), findsOneWidget);
      });

      testWidgets('renders prefix icon when provided', (tester) async {
        await tester.pumpWidget(buildTestApp(
          const StyloTextField(
            prefixIcon: Icon(Icons.email),
          ),
        ));

        expect(find.byIcon(Icons.email), findsOneWidget);
      });

      testWidgets('renders with both prefix and suffix icons', (tester) async {
        await tester.pumpWidget(buildTestApp(
          const StyloTextField(
            prefixIcon: Icon(Icons.email),
            suffixIcon: Icon(Icons.visibility),
          ),
        ));

        expect(find.byIcon(Icons.email), findsOneWidget);
        expect(find.byIcon(Icons.visibility), findsOneWidget);
      });
    });

    group('readOnly', () {
      testWidgets('field is editable by default', (tester) async {
        await tester.pumpWidget(buildTestApp(
          const StyloTextField(),
        ));

        // readOnly is reflected in the underlying EditableText
        final editableText = tester.widget<EditableText>(
          find.byType(EditableText),
        );
        expect(editableText.readOnly, isFalse);
      });

      testWidgets('field is read-only when readOnly is true', (tester) async {
        await tester.pumpWidget(buildTestApp(
          const StyloTextField(readOnly: true),
        ));

        final editableText = tester.widget<EditableText>(
          find.byType(EditableText),
        );
        expect(editableText.readOnly, isTrue);
      });
    });

    group('onChanged callback', () {
      testWidgets('calls onChanged when text is entered', (tester) async {
        String? changedValue;

        await tester.pumpWidget(buildTestApp(
          StyloTextField(
            onChanged: (value) => changedValue = value,
          ),
        ));

        await tester.enterText(find.byType(TextFormField), 'new text');
        expect(changedValue, 'new text');
      });
    });

    group('keyboardType', () {
      testWidgets('sets email keyboard type correctly', (tester) async {
        await tester.pumpWidget(buildTestApp(
          const StyloTextField(
            keyboardType: TextInputType.emailAddress,
          ),
        ));

        // keyboardType is available via the EditableText widget
        final editableText = tester.widget<EditableText>(
          find.byType(EditableText),
        );
        expect(editableText.keyboardType, TextInputType.emailAddress);
      });
    });
  });
}
