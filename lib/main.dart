import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_example/core/services/authentication_service.dart';
import 'package:provider_example/core/viewmodels/login_model.dart';
import 'package:provider_example/ui/router.dart';
import 'package:provider_example/ui/views/home_view.dart';
import 'package:provider_example/ui/views/login_view.dart';

import 'core/models/user.dart';
import 'core/services/api.dart';
import 'core/viewmodels/home_model.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(
          builder: (_) => Api(),
          dispose: (_, api) => api.dispose(),
        ),
        ProxyProvider<Api, AuthenticationService>(
          builder: (_, api, previous) =>
              (previous ?? AuthenticationService())..api = api,
          dispose: (_, auth) => auth.dispose(),
        ),
        // TODO(rousselGit) change to StreamProxyProvider<AuthentificationService, User> when available
        StreamProvider<User>(
          builder: (context) =>
              Provider.of<AuthenticationService>(context, listen: false).user,
        ),
        ChangeNotifierProxyProvider2<User, Api, HomeModel>(
          initialBuilder: (_) => HomeModel(),
          builder: (context, user, api, model) => model
            ..api = api
            ..userId = user?.id,
        ),
        ChangeNotifierProxyProvider<AuthenticationService, LoginModel>(
          initialBuilder: (_) => LoginModel(),
          builder: (_, auth, model) => model..authenticationService = auth,
        )
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        routes: {
          // `initialRoute` is not enough
          // the route `/` will always be pushed. So `/` should handle displaying LoginView internally
          // see https://stackoverflow.com/questions/56145378/why-is-initstate-called-twice/56145478#56145478
          '/': (context) => Provider.of<User>(context)?.id != null
              ? const HomeView()
              : const LoginView(),
          '/login': (_) => const LoginView(),
        },
        onGenerateRoute: Router.generateRoute,
        onUnknownRoute: (settings) => MaterialPageRoute(
              builder: (_) => Scaffold(
                    body: Center(
                      child: Text('No route defined for ${settings.name}'),
                    ),
                  ),
            ),
      ),
    );
  }
}
