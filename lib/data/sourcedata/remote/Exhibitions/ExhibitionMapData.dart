import 'package:expocore_invistor2/core/class/crud.dart';
import 'package:expocore_invistor2/linkapi.dart';

class ExhibitionMapData {
  final Crud crud;
  ExhibitionMapData(this.crud);

  /// جلب بيانات الخريطة ثلاثية الأبعاد لمعرض معين
  /// GET /exhibitions/{id}/map
  Future<Map<String, dynamic>> getExhibitionMap(int exhibitionId) async {
    final url = AppLink.exhibitionMap(exhibitionId);
    print('[Map API] GET $url');
    return await crud.getData(url);
  }
}
