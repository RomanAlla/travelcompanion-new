import 'package:travelcompanion/core/domain/entities/tip_model.dart';

abstract class TipRepository {
  Future<List<TipModel>> getTips({required String routeId});

  Future<TipModel> addTip({required String routeId, required String text});

  Future<void> deleteTip(String tipId);

  Future<TipModel> updateTip({required String tipId, required String text});
}
