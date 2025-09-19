import 'package:cente_pice/src/core/errors/failures.dart';
import 'package:cente_pice/src/features/parts/presentation/controllers/conversations_controller.dart';
import 'package:cente_pice/src/features/parts/domain/entities/conversation.dart';
import 'package:cente_pice/src/features/parts/domain/entities/message.dart';
import 'package:cente_pice/src/features/parts/domain/entities/conversation_enums.dart';
import 'package:cente_pice/src/features/parts/domain/usecases/get_conversations.dart';
import 'package:cente_pice/src/features/parts/domain/usecases/get_conversation_messages.dart';
import 'package:cente_pice/src/features/parts/domain/usecases/send_message.dart';
import 'package:cente_pice/src/features/parts/domain/usecases/manage_conversation.dart';
import 'package:cente_pice/src/features/parts/data/datasources/conversations_remote_datasource.dart';
import 'package:cente_pice/src/core/services/realtime_service.dart';
import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'conversations_controller_test.mocks.dart';

@GenerateMocks([
  GetConversations,
  GetConversationMessages,
  SendMessage,
  MarkMessagesAsRead,
  DeleteConversation,
  BlockConversation,
  CloseConversation,
  ConversationsRemoteDataSource,
  RealtimeService,
])
void main() {
  late ConversationsController controller;
  late MockGetConversations mockGetConversations;
  late MockGetConversationMessages mockGetConversationMessages;
  late MockSendMessage mockSendMessage;
  late MockMarkMessagesAsRead mockMarkMessagesAsRead;
  late MockDeleteConversation mockDeleteConversation;
  late MockBlockConversation mockBlockConversation;
  late MockCloseConversation mockCloseConversation;
  late MockConversationsRemoteDataSource mockDataSource;
  late MockRealtimeService mockRealtimeService;

  setUp(() {
    mockGetConversations = MockGetConversations();
    mockGetConversationMessages = MockGetConversationMessages();
    mockSendMessage = MockSendMessage();
    mockMarkMessagesAsRead = MockMarkMessagesAsRead();
    mockDeleteConversation = MockDeleteConversation();
    mockBlockConversation = MockBlockConversation();
    mockCloseConversation = MockCloseConversation();
    mockDataSource = MockConversationsRemoteDataSource();
    mockRealtimeService = MockRealtimeService();

    // Setup basic stream behavior
    when(mockRealtimeService.conversationStream).thenAnswer((_) => Stream.empty());

    controller = ConversationsController(
      getConversations: mockGetConversations,
      getConversationMessages: mockGetConversationMessages,
      sendMessage: mockSendMessage,
      markMessagesAsRead: mockMarkMessagesAsRead,
      deleteConversation: mockDeleteConversation,
      blockConversation: mockBlockConversation,
      closeConversation: mockCloseConversation,
      dataSource: mockDataSource,
      realtimeService: mockRealtimeService,
    );
  });

  tearDown(() {
    controller.dispose();
  });

  // Test conversation data - kept for potential future use
  // ignore: unused_local_variable
  final tConversation = Conversation(
    id: 'conv1',
    userId: 'user1',
    sellerId: 'seller1',
    requestId: 'request1',
    sellerName: 'Vendeur Test',
    sellerCompany: 'Test Company',
    status: ConversationStatus.active,
    lastMessageContent: 'Hello',
    lastMessageAt: DateTime.now(),
    unreadCount: 2,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    updatedAt: DateTime.now(),
  );

  final tMessage = Message(
    id: 'msg1',
    conversationId: 'conv1',
    senderId: 'user1',
    senderType: MessageSenderType.user,
    content: 'Test message',
    messageType: MessageType.text,
    isRead: false,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  group('État initial', () {
    test('doit avoir l\'état initial correct', () {
      // assert
      expect(controller.state.conversations, isEmpty);
      expect(controller.state.conversationMessages, isEmpty);
      expect(controller.state.isLoading, false);
      expect(controller.state.isLoadingMessages, false);
      expect(controller.state.isSendingMessage, false);
      expect(controller.state.error, null);
      expect(controller.state.activeConversationId, null);
      expect(controller.state.totalUnreadCount, 0);
    });
  });

  group('loadConversationMessages', () {
    test('doit charger les messages d\'une conversation', () async {
      // arrange
      when(mockGetConversationMessages(any))
          .thenAnswer((_) async => Right([tMessage]));

      // act
      await controller.loadConversationMessages('conv1');

      // assert
      expect(controller.state.conversationMessages['conv1']?.length, 1);
      expect(controller.state.conversationMessages['conv1']?.first.id, 'msg1');
      expect(controller.state.isLoadingMessages, false);
      expect(controller.state.error, null);
      verify(mockGetConversationMessages(any));
    });

    test('doit gérer les erreurs de chargement des messages', () async {
      // arrange
      when(mockGetConversationMessages(any))
          .thenAnswer((_) async => const Left(ServerFailure('Erreur messages')));

      // act
      await controller.loadConversationMessages('conv1');

      // assert
      expect(controller.state.conversationMessages['conv1'], null);
      expect(controller.state.isLoadingMessages, false);
      expect(controller.state.error, 'Erreur messages');
    });
  });

  group('setConversationInactive', () {
    test('doit désactiver la conversation active', () async {
      // arrange
      controller.state = controller.state.copyWith(activeConversationId: 'conv1');

      // act
      controller.setConversationInactive();
      await Future.delayed(Duration.zero); // Attendre microtask

      // assert
      expect(controller.state.activeConversationId, null);
    });
  });

  group('getMessagesForConversation', () {
    test('doit retourner les messages d\'une conversation', () {
      // arrange
      controller.state = controller.state.copyWith(
        conversationMessages: {'conv1': [tMessage]},
      );

      // act
      final messages = controller.getMessagesForConversation('conv1');

      // assert
      expect(messages.length, 1);
      expect(messages.first.id, 'msg1');
    });

    test('doit retourner une liste vide si la conversation n\'existe pas', () {
      // act
      final messages = controller.getMessagesForConversation('conv_not_found');

      // assert
      expect(messages, isEmpty);
    });
  });

  group('Gestion des états de chargement', () {
    test('doit mettre isLoadingMessages à true pendant le chargement des messages', () async {
      // arrange
      final completer = Completer<Either<Failure, List<Message>>>();
      when(mockGetConversationMessages(any)).thenAnswer((_) => completer.future);

      // act
      final future = controller.loadConversationMessages('conv1');

      // assert
      expect(controller.state.isLoadingMessages, true);

      // complete
      completer.complete(Right([tMessage]));
      await future;
      expect(controller.state.isLoadingMessages, false);
    });
  });
}