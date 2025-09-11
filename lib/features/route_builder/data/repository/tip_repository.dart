import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travelcompanion/features/route_builder/data/models/tip_model.dart';
import 'package:travelcompanion/core/error/app_exception.dart';

class TipRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  Future<TipModel> createTip({
    required String routeId,

    required String description,
  }) async {
    try {
      final data = {'description': description, 'route_id': routeId};

      final response = await _supabase
          .from('route_tips')
          .insert(data)
          .select()
          .single();
      return TipModel.fromJson(response);
    } catch (e) {
      throw AppException('Ошибка создания совета: $e');
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
      throw AppException('Ошибка получения советов: $e');
    }
  }
}
