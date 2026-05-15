import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const TeslaApp());
}

class TeslaApp extends StatelessWidget {
  const TeslaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.red,
        scaffoldBackgroundColor: Colors.black,
      ),
      // This part handles the "callback" from Tesla
      onGenerateRoute: (settings) {
        if (settings.name != null && settings.name!.contains('callback')) {
          final uri = Uri.parse(settings.name!);
          final authCode = uri.queryParameters['code'];
          return MaterialPageRoute(
            builder: (context) => TokenExchangePage(authCode: authCode),
          );
        }
        return MaterialPageRoute(builder: (context) => const TeslaHomePage());
      },
    );
  }
}

class TeslaHomePage extends StatelessWidget {
  const TeslaHomePage({super.key});

  Future<void> _launchTeslaLogin() async {
    final String clientId = dotenv.env['TESLA_CLIENT_ID'] ?? '';
    final String callbackUrl = dotenv.env['TESLA_CALLBACK_URL'] ?? '';

    final Uri url = Uri.parse(
      'https://auth.tesla.com/oauth2/v3/authorize'
      '?client_id=$clientId'
      '&locale=en-US'
      '&prompt=login'
      '&redirect_uri=$callbackUrl'
      '&response_type=code'
      '&scope=openid%20offline_access%20vehicle_device_data%20vehicle_cmds'
      '&state=123'
    );

    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tesla Control'), backgroundColor: Colors.red),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: _launchTeslaLogin,
          child: const Text('Connect My Tesla'),
        ),
      ),
    );
  }
}

// THIS IS THE NEW PAGE THAT CATCHES THE 404
class TokenExchangePage extends StatelessWidget {
  final String? authCode;
  const TokenExchangePage({super.key, this.authCode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.vpn_key, size: 80, color: Colors.green),
            const SizedBox(height: 20),
            Text(authCode != null ? "Success! Received Code" : "No Code Found"),
            const SizedBox(height: 10),
            if (authCode != null) SelectableText(authCode!, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/'),
              child: const Text("Go Back"),
            )
          ],
        ),
      ),
    );
  }
}