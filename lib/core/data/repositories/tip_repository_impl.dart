import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travelcompanion/core/domain/entities/tip_model.dart';
import 'package:travelcompanion/core/domain/repositories/tip_repository.dart';

import 'package:travelcompanion/core/domain/exceptions/app_exception.dart';

class TipRepositoryImpl implements TipRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<List<TipModel>> getTips({required String routeId}) async {
    try {
      final response = await _supabase
          .from('route_tips')
          .select('*')
          .eq('route_id', routeId);

      final tips = response
          .map((response) => TipModel.fromJson(response))
          .toList();
      return tips;
    } catch (e) {
      throw AppException('Ошибка получения советов: $e');
    }
  }

  @override
  Future<TipModel> addTip({
    required String routeId,
    required String text,
  }) async {
    try {
      final response = await _supabase
          .from('route_tips')
          .insert({'route_id': routeId, 'description': text})
          .select()
          .single();

      return TipModel.fromJson(response);
    } catch (e) {
      throw AppException('Ошибка добавления совета: $e');
    }
  }

  @override
  Future<void> deleteTip(String tipId) async {
    try {
      await _supabase.from('route_tips').delete().eq('id', tipId);
    } catch (e) {
      throw AppException('Ошибка удаления совета: $e');
    }
  }

  @override
  Future<TipModel> updateTip({
    required String tipId,
    required String text,
  }) async {
    try {
      final response = await _supabase
          .from('route_tips')
          .update({'description': text})
          .eq('id', tipId)
          .select()
          .single();

      return TipModel.fromJson(response);
    } catch (e) {
      throw AppException('Ошибка обновления совета: $e');
    }
  }
}
