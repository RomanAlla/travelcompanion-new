import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _supabaseClient;

  SupabaseService(this._supabaseClient);

  Future<double?> getAvgRating(String routeId) async {
    try {
      final response = await _supabaseClient
          .from('comments')
          .select('rating')
          .eq('route_id', routeId);

      final data = response as List<dynamic>;

      if (data.isEmpty) {
        return null;
      }

      double totalRating = 0;
      for (var item in data) {
        totalRating += (item['rating'] as int).toDouble();
      }
      return totalRating / data.length;
    } catch (e) {
      print('Error getting average rating: $e');
      return null;
    }
  }
}
