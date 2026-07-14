import 'package:expocore_invistor2/core/class/crud.dart';
import 'package:expocore_invistor2/linkapi.dart';

class VisitorMessagesData {
  Crud crud;

  VisitorMessagesData(this.crud);

  Future<Map<String, dynamic>> getConversations() async {
    return await crud.getData(AppLink.investorVisitorMessages);
  }

  Future<Map<String, dynamic>> getConversationDetail(int conversationId) async {
    return await crud.getData(AppLink.visitorConversationDetail(conversationId));
  }

  Future<Map<String, dynamic>> sendMessage(int conversationId, String text) async {
    return await crud.postData(AppLink.sendVisitorMessage(conversationId), {
      'text': text,
    });
  }
}
