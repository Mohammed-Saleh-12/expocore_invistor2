import 'package:expocore_invistor2/core/class/crud.dart';
import 'package:expocore_invistor2/linkapi.dart';

class MessagesData {
  Crud crud;

  MessagesData(this.crud);

  Future<Map<String, dynamic>> getConversations() async {
    return await crud.getData(AppLink.investorMessages);
  }

  Future<Map<String, dynamic>> getConversationDetail(int conversationId) async {
    return await crud.getData(AppLink.conversationDetail(conversationId));
  }

  Future<Map<String, dynamic>> createConversation({
    required int exhibitionId,
    required String exhibitionName,
  }) async {
    return await crud.postData(AppLink.investorMessages, {
      'exhibition_id': exhibitionId,
      'exhibition_name': exhibitionName,
    });
  }

  Future<Map<String, dynamic>> sendMessage(int conversationId, String text) async {
    return await crud.postData(AppLink.sendMessage(conversationId), {
      'text': text,
    });
  }
}
