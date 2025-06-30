import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travelcompanion/features/routes/data/models/tip_model.dart';

class TipRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  Future<TipModel> createTip({
    required String routeId,
    required String name,
    required String description,
  }) async {
    try {
      final data = {
        'name': name,
        'description': description,
        'route_id': routeId,
      };

      final response = await _supabase
          .from('route_tips')
          .insert(data)
          .select()
          .single();
      return TipModel.fromJson(response);
    } catch (e) {
      print(e.toString());
      throw 'Failed to create tip';
    }
  }

  Future<List<TipModel>> getTips({required String routeId}) async {
    try {
      final response = await _supabase
          .from('route_tips')
          .select()
          .eq('route_id', routeId);
      final tipsList = response
          .map((response) => TipModel.fromJson(response))
          .toList();

      return tipsList;
    } catch (e) {
      print(e.toString());
      throw 'Ошибка получения советов';
    }
  }
}
