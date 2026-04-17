import 'dart:convert';
import 'package:flutter/services.dart';

import '../models/ambiences_model.dart';

class AmbienceRepository {
  Future<List<AmbienceModel>> loadAmbiences() async {
    final String raw =
    await rootBundle.loadString('assets/data/ambiences.json');
    final List<dynamic> jsonList = json.decode(raw);
    return jsonList.map((e) => AmbienceModel.fromJson(e)).toList();
  }
}