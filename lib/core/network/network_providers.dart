import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';

/// Единственный HTTP-клиент приложения: в нём живёт bearer-токен.
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());
