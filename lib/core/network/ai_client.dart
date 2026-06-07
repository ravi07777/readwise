import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/secure_storage_service.dart';
import '../constants/api_constants.dart';

enum AIProvider {
  openAI,
  gemini,
  anthropic,
  openRouter,
  groq,
  deepSeek,
  ollama,
  custom;

  String get displayName {
    switch (this) {
      case openAI:
        return 'OpenAI';
      case gemini:
        return 'Gemini';
      case anthropic:
        return 'Anthropic';
      case openRouter:
        return 'OpenRouter';
      case groq:
        return 'Groq';
      case deepSeek:
        return 'DeepSeek';
      case ollama:
        return 'Ollama';
      case custom:
        return 'Custom';
    }
  }

  String get defaultModel {
    switch (this) {
      case openAI:
        return 'gpt-4o';
      case gemini:
        return 'gemini-1.5-pro';
      case anthropic:
        return 'claude-3-sonnet-20240229';
      case openRouter:
        return 'openai/gpt-4o';
      case groq:
        return 'llama-3.1-70b-versatile';
      case deepSeek:
        return 'deepseek-chat';
      case ollama:
        return 'llama3.1';
      case custom:
        return 'custom-model';
    }
  }

  String get baseUrl {
    switch (this) {
      case openAI:
        return ApiConstants.openAIBaseUrl;
      case gemini:
        return ApiConstants.geminiBaseUrl;
      case anthropic:
        return ApiConstants.anthropicBaseUrl;
      case openRouter:
        return ApiConstants.openRouterBaseUrl;
      case groq:
        return ApiConstants.groqBaseUrl;
      case deepSeek:
        return ApiConstants.deepSeekBaseUrl;
      case ollama:
        return ApiConstants.ollamaBaseUrl;
      case custom:
        return '';
    }
  }
}

class AIProviderConfig {
  final AIProvider provider;
  final String model;
  final double temperature;
  final int maxTokens;
  final String? customBaseUrl;

  const AIProviderConfig({
    this.provider = AIProvider.openAI,
    this.model = 'gpt-4o',
    this.temperature = 0.7,
    this.maxTokens = 4096,
    this.customBaseUrl,
  });

  AIProviderConfig copyWith({
    AIProvider? provider,
    String? model,
    double? temperature,
    int? maxTokens,
    String? customBaseUrl,
  }) {
    return AIProviderConfig(
      provider: provider ?? this.provider,
      model: model ?? this.model,
      temperature: temperature ?? this.temperature,
      maxTokens: maxTokens ?? this.maxTokens,
      customBaseUrl: customBaseUrl ?? this.customBaseUrl,
    );
  }

  Map<String, dynamic> toJson() => {
    'provider': provider.name,
    'model': model,
    'temperature': temperature,
    'maxTokens': maxTokens,
    'customBaseUrl': customBaseUrl,
  };

  factory AIProviderConfig.fromJson(Map<String, dynamic> json) => AIProviderConfig(
    provider: AIProvider.values.firstWhere(
      (e) => e.name == json['provider'],
      orElse: () => AIProvider.openAI,
    ),
    model: json['model'] as String? ?? 'gpt-4o',
    temperature: (json['temperature'] as num?)?.toDouble() ?? 0.7,
    maxTokens: json['maxTokens'] as int? ?? 4096,
    customBaseUrl: json['customBaseUrl'] as String?,
  );
}

class AIClient {
  final Dio _dio;
  final SecureStorageService _storage;
  AIProviderConfig _config;

  AIClient({
    required SecureStorageService storage,
    AIProviderConfig? config,
  })  : _storage = storage,
        _config = config ?? const AIProviderConfig(),
        _dio = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 60),
          sendTimeout: const Duration(seconds: 30),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ));

  AIProviderConfig get config => _config;

  void updateConfig(AIProviderConfig config) {
    _config = config;
  }

  Future<String> sendMessage({
    required String message,
    String? systemPrompt,
    List<Map<String, String>>? history,
  }) async {
    final apiKey = await _storage.getApiKey(_config.provider.name);
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('API key not configured for ${_config.provider.displayName}');
    }

    switch (_config.provider) {
      case AIProvider.openAI:
        return _sendOpenAI(apiKey, message, systemPrompt, history);
      case AIProvider.gemini:
        return _sendGemini(apiKey, message, systemPrompt, history);
      case AIProvider.anthropic:
        return _sendAnthropic(apiKey, message, systemPrompt, history);
      case AIProvider.openRouter:
        return _sendOpenRouter(apiKey, message, systemPrompt, history);
      case AIProvider.groq:
        return _sendGroq(apiKey, message, systemPrompt, history);
      case AIProvider.deepSeek:
        return _sendDeepSeek(apiKey, message, systemPrompt, history);
      case AIProvider.ollama:
        return _sendOllama(message, systemPrompt, history);
      case AIProvider.custom:
        return _sendCustom(apiKey, message, systemPrompt, history);
    }
  }

  Future<String> sendStreamingMessage({
    required String message,
    String? systemPrompt,
    List<Map<String, String>>? history,
    required Function(String chunk) onChunk,
  }) async {
    final apiKey = await _storage.getApiKey(_config.provider.name);
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('API key not configured for ${_config.provider.displayName}');
    }

    switch (_config.provider) {
      case AIProvider.openAI:
      case AIProvider.openRouter:
      case AIProvider.groq:
      case AIProvider.deepSeek:
      case AIProvider.custom:
        return _sendStreamingOpenAICompatible(
          apiKey, message, systemPrompt, history, onChunk,
        );
      case AIProvider.gemini:
        return _sendStreamingGemini(apiKey, message, systemPrompt, history, onChunk);
      case AIProvider.anthropic:
        return _sendStreamingAnthropic(apiKey, message, systemPrompt, history, onChunk);
      case AIProvider.ollama:
        return _sendStreamingOllama(message, systemPrompt, history, onChunk);
    }
  }

  Future<String> _sendOpenAI(
    String apiKey,
    String message,
    String? systemPrompt,
    List<Map<String, String>>? history,
  ) async {
    final messages = _buildMessages(message, systemPrompt, history);

    try {
      final response = await _dio.post(
        '${ApiConstants.openAIBaseUrl}${ApiConstants.openAIChatEndpoint}',
        options: Options(headers: {'Authorization': 'Bearer $apiKey'}),
        data: {
          'model': _config.model,
          'messages': messages,
          'temperature': _config.temperature,
          'max_tokens': _config.maxTokens,
        },
      );

      return response.data['choices'][0]['message']['content'] ?? '';
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  Future<String> _sendGemini(
    String apiKey,
    String message,
    String? systemPrompt,
    List<Map<String, String>>? history,
  ) async {
    try {
      final contents = <Map<String, dynamic>>[];
      if (history != null) {
        for (final h in history) {
          contents.add({
            'role': h['role'] == 'assistant' ? 'model' : 'user',
            'parts': [{'text': h['content']}],
          });
        }
      }
      contents.add({
        'role': 'user',
        'parts': [{'text': message}],
      });

      final requestBody = {
        'contents': contents,
        'generationConfig': {
          'temperature': _config.temperature,
          'maxOutputTokens': _config.maxTokens,
        },
      };

      if (systemPrompt != null) {
        requestBody['systemInstruction'] = {
          'parts': [{'text': systemPrompt}],
        };
      }

      final url = '${ApiConstants.geminiBaseUrl}/models/${_config.model}:generateContent?key=$apiKey';
      final response = await _dio.post(url, data: requestBody);

      return response.data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '';
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  Future<String> _sendAnthropic(
    String apiKey,
    String message,
    String? systemPrompt,
    List<Map<String, String>>? history,
  ) async {
    try {
      final messages = <Map<String, dynamic>>[];
      if (history != null) {
        for (final h in history) {
          messages.add({
            'role': h['role'],
            'content': h['content'],
          });
        }
      }
      messages.add({
        'role': 'user',
        'content': message,
      });

      final requestBody = {
        'model': _config.model,
        'max_tokens': _config.maxTokens,
        'messages': messages,
      };

      if (systemPrompt != null) {
        requestBody['system'] = systemPrompt;
      }

      final response = await _dio.post(
        '${ApiConstants.anthropicBaseUrl}${ApiConstants.anthropicMessagesEndpoint}',
        options: Options(headers: {
          'x-api-key': apiKey,
          'anthropic-version': '2023-06-01',
        }),
        data: requestBody,
      );

      return response.data['content']?[0]?['text'] ?? '';
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  Future<String> _sendOpenRouter(
    String apiKey,
    String message,
    String? systemPrompt,
    List<Map<String, String>>? history,
  ) async {
    final messages = _buildMessages(message, systemPrompt, history);

    try {
      final response = await _dio.post(
        '${ApiConstants.openRouterBaseUrl}${ApiConstants.openRouterChatEndpoint}',
        options: Options(headers: {
          'Authorization': 'Bearer $apiKey',
          'HTTP-Referer': 'https://readwise.app',
          'X-Title': 'ReadWise AI Assistant',
        }),
        data: {
          'model': _config.model,
          'messages': messages,
          'temperature': _config.temperature,
          'max_tokens': _config.maxTokens,
        },
      );

      return response.data['choices']?[0]?['message']?['content'] ?? '';
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  Future<String> _sendGroq(
    String apiKey,
    String message,
    String? systemPrompt,
    List<Map<String, String>>? history,
  ) async {
    final messages = _buildMessages(message, systemPrompt, history);

    try {
      final response = await _dio.post(
        '${ApiConstants.groqBaseUrl}${ApiConstants.groqChatEndpoint}',
        options: Options(headers: {'Authorization': 'Bearer $apiKey'}),
        data: {
          'model': _config.model,
          'messages': messages,
          'temperature': _config.temperature,
          'max_tokens': _config.maxTokens,
        },
      );

      return response.data['choices']?[0]?['message']?['content'] ?? '';
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  Future<String> _sendDeepSeek(
    String apiKey,
    String message,
    String? systemPrompt,
    List<Map<String, String>>? history,
  ) async {
    final messages = _buildMessages(message, systemPrompt, history);

    try {
      final response = await _dio.post(
        '${ApiConstants.deepSeekBaseUrl}${ApiConstants.deepSeekChatEndpoint}',
        options: Options(headers: {'Authorization': 'Bearer $apiKey'}),
        data: {
          'model': _config.model,
          'messages': messages,
          'temperature': _config.temperature,
          'max_tokens': _config.maxTokens,
        },
      );

      return response.data['choices']?[0]?['message']?['content'] ?? '';
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  Future<String> _sendOllama(
    String message,
    String? systemPrompt,
    List<Map<String, String>>? history,
  ) async {
    try {
      final messages = <Map<String, dynamic>>[];
      if (systemPrompt != null) {
        messages.add({'role': 'system', 'content': systemPrompt});
      }
      if (history != null) {
        for (final h in history) {
          messages.add({'role': h['role'], 'content': h['content']});
        }
      }
      messages.add({'role': 'user', 'content': message});

      final response = await _dio.post(
        '${ApiConstants.ollamaBaseUrl}${ApiConstants.ollamaChatEndpoint}',
        data: {
          'model': _config.model,
          'messages': messages,
          'stream': false,
          'options': {
            'temperature': _config.temperature,
            'num_predict': _config.maxTokens,
          },
        },
      );

      return response.data['message']?['content'] ?? '';
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  Future<String> _sendCustom(
    String apiKey,
    String message,
    String? systemPrompt,
    List<Map<String, String>>? history,
  ) async {
    final baseUrl = _config.customBaseUrl ?? ApiConstants.openAIBaseUrl;
    final messages = _buildMessages(message, systemPrompt, history);

    try {
      final response = await _dio.post(
        '$baseUrl/chat/completions',
        options: Options(headers: {'Authorization': 'Bearer $apiKey'}),
        data: {
          'model': _config.model,
          'messages': messages,
          'temperature': _config.temperature,
          'max_tokens': _config.maxTokens,
        },
      );

      return response.data['choices']?[0]?['message']?['content'] ?? '';
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  Future<String> _sendStreamingOpenAICompatible(
    String apiKey,
    String message,
    String? systemPrompt,
    List<Map<String, String>>? history,
    Function(String chunk) onChunk,
  ) async {
    final baseUrl = _getBaseUrl();
    final messages = _buildMessages(message, systemPrompt, history);
    final buffer = StringBuffer();

    try {
      final response = await _dio.post(
        '$baseUrl/chat/completions',
        options: Options(
          headers: {'Authorization': 'Bearer $apiKey'},
          responseType: ResponseType.stream,
        ),
        data: {
          'model': _config.model,
          'messages': messages,
          'temperature': _config.temperature,
          'max_tokens': _config.maxTokens,
          'stream': true,
        },
      );

      final stream = response.data.stream;
      await for (final chunk in stream) {
        final decoded = utf8.decode(chunk as List<int>);
        for (final line in const LineSplitter().convert(decoded)) {
          if (line.startsWith('data: ')) {
            final data = line.substring(6);
            if (data == '[DONE]') continue;
            try {
              final json = jsonDecode(data);
              final content = json['choices']?[0]?['delta']?['content'] ?? '';
              if (content.isNotEmpty) {
                buffer.write(content);
                onChunk(content);
              }
            } catch (_) {}
          }
        }
      }

      return buffer.toString();
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  Future<String> _sendStreamingGemini(
    String apiKey,
    String message,
    String? systemPrompt,
    List<Map<String, String>>? history,
    Function(String chunk) onChunk,
  ) async {
    final contents = <Map<String, dynamic>>[];
    if (history != null) {
      for (final h in history) {
        contents.add({
          'role': h['role'] == 'assistant' ? 'model' : 'user',
          'parts': [{'text': h['content']}],
        });
      }
    }
    contents.add({
      'role': 'user',
      'parts': [{'text': message}],
    });

    final requestBody = {
      'contents': contents,
      'generationConfig': {
        'temperature': _config.temperature,
        'maxOutputTokens': _config.maxTokens,
      },
    };

    if (systemPrompt != null) {
      requestBody['systemInstruction'] = {
        'parts': [{'text': systemPrompt}],
      };
    }

    try {
      final url =
          '${ApiConstants.geminiBaseUrl}/models/${_config.model}:streamGenerateContent?alt=sse&key=$apiKey';
      final response = await _dio.post(
        url,
        options: Options(responseType: ResponseType.stream),
        data: requestBody,
      );

      final buffer = StringBuffer();
      final stream = response.data.stream;
      await for (final chunk in stream) {
        final decoded = utf8.decode(chunk as List<int>);
        for (final line in const LineSplitter().convert(decoded)) {
          if (line.startsWith('data: ')) {
            try {
              final json = jsonDecode(line.substring(6));
              final text = json['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '';
              if (text.isNotEmpty) {
                buffer.write(text);
                onChunk(text);
              }
            } catch (_) {}
          }
        }
      }

      return buffer.toString();
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  Future<String> _sendStreamingAnthropic(
    String apiKey,
    String message,
    String? systemPrompt,
    List<Map<String, String>>? history,
    Function(String chunk) onChunk,
  ) async {
    final messages = <Map<String, dynamic>>[];
    if (history != null) {
      for (final h in history) {
        messages.add({'role': h['role'], 'content': h['content']});
      }
    }
    messages.add({'role': 'user', 'content': message});

    final requestBody = {
      'model': _config.model,
      'max_tokens': _config.maxTokens,
      'messages': messages,
      'stream': true,
    };

    if (systemPrompt != null) {
      requestBody['system'] = systemPrompt;
    }

    try {
      final response = await _dio.post(
        '${ApiConstants.anthropicBaseUrl}${ApiConstants.anthropicMessagesEndpoint}',
        options: Options(
          headers: {
            'x-api-key': apiKey,
            'anthropic-version': '2023-06-01',
          },
          responseType: ResponseType.stream,
        ),
        data: requestBody,
      );

      final buffer = StringBuffer();
      final stream = response.data.stream;
      await for (final chunk in stream) {
        final decoded = utf8.decode(chunk as List<int>);
        for (final line in const LineSplitter().convert(decoded)) {
          if (line.startsWith('data: ')) {
            try {
              final json = jsonDecode(line.substring(6));
              if (json['type'] == 'content_block_delta') {
                final text = json['delta']?['text'] ?? '';
                if (text.isNotEmpty) {
                  buffer.write(text);
                  onChunk(text);
                }
              }
            } catch (_) {}
          }
        }
      }

      return buffer.toString();
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  Future<String> _sendStreamingOllama(
    String message,
    String? systemPrompt,
    List<Map<String, String>>? history,
    Function(String chunk) onChunk,
  ) async {
    final messages = <Map<String, dynamic>>[];
    if (systemPrompt != null) {
      messages.add({'role': 'system', 'content': systemPrompt});
    }
    if (history != null) {
      for (final h in history) {
        messages.add({'role': h['role'], 'content': h['content']});
      }
    }
    messages.add({'role': 'user', 'content': message});

    try {
      final response = await _dio.post(
        '${ApiConstants.ollamaBaseUrl}${ApiConstants.ollamaChatEndpoint}',
        options: Options(responseType: ResponseType.stream),
        data: {
          'model': _config.model,
          'messages': messages,
          'stream': true,
          'options': {
            'temperature': _config.temperature,
            'num_predict': _config.maxTokens,
          },
        },
      );

      final buffer = StringBuffer();
      final stream = response.data.stream;
      await for (final chunk in stream) {
        final decoded = utf8.decode(chunk as List<int>);
        for (final line in const LineSplitter().convert(decoded)) {
          if (line.trim().isEmpty) continue;
          try {
            final json = jsonDecode(line);
            final content = json['message']?['content'] ?? '';
            if (content.isNotEmpty) {
              buffer.write(content);
              onChunk(content);
            }
            if (json['done'] == true) break;
          } catch (_) {}
        }
      }

      return buffer.toString();
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  List<Map<String, dynamic>> _buildMessages(
    String message,
    String? systemPrompt,
    List<Map<String, String>>? history,
  ) {
    final messages = <Map<String, dynamic>>[];
    if (systemPrompt != null) {
      messages.add({'role': 'system', 'content': systemPrompt});
    }
    if (history != null) {
      for (final h in history) {
        messages.add({'role': h['role'], 'content': h['content']});
      }
    }
    messages.add({'role': 'user', 'content': message});
    return messages;
  }

  String _getBaseUrl() {
    switch (_config.provider) {
      case AIProvider.openAI:
        return ApiConstants.openAIBaseUrl;
      case AIProvider.openRouter:
        return ApiConstants.openRouterBaseUrl;
      case AIProvider.groq:
        return ApiConstants.groqBaseUrl;
      case AIProvider.deepSeek:
        return ApiConstants.deepSeekBaseUrl;
      case AIProvider.custom:
        return _config.customBaseUrl ?? ApiConstants.openAIBaseUrl;
      default:
        return ApiConstants.openAIBaseUrl;
    }
  }

  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.sendTimeout:
        return 'Request timeout. Please try again.';
      case DioExceptionType.receiveTimeout:
        return 'Response timeout. The AI provider took too long to respond.';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final body = e.response?.data;
        if (statusCode == 401) {
          return 'Invalid API key. Please check your API key.';
        } else if (statusCode == 429) {
          return 'Rate limit exceeded. Please wait and try again.';
        } else if (statusCode == 500) {
          return 'AI provider server error. Please try again later.';
        }
        if (body is Map && body['error'] != null) {
          final error = body['error'];
          if (error is Map && error['message'] != null) {
            return 'Error $statusCode: ${error['message']}';
          }
          return 'Error $statusCode: $body';
        }
        return 'Error $statusCode: $body';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.connectionError:
        return 'Connection error. Please check your internet connection.';
      default:
        return 'Unexpected error: ${e.message}';
    }
  }
}

final aiClientProvider = Provider<AIClient>((ref) {
  final storage = ref.watch(secureStorageServiceProvider);
  return AIClient(storage: storage);
});
