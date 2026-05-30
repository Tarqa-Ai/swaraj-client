import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';

final moduleDetailProvider = FutureProvider.family<Map<String, dynamic>, String>(
  (ref, id) => ref.read(apiClientProvider).get('/modules/$id'),
);
