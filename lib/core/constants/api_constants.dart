class ApiConstants {
  ApiConstants._();

  // OpenAI
  static const String openAIBaseUrl = 'https://api.openai.com/v1';
  static const String openAIChatEndpoint = '/chat/completions';
  static const String openAIModels = '/models';

  // Gemini
  static const String geminiBaseUrl = 'https://generativelanguage.googleapis.com/v1beta';
  static const String geminiGenerateContent = '/models/{model}:generateContent';

  // Anthropic
  static const String anthropicBaseUrl = 'https://api.anthropic.com/v1';
  static const String anthropicMessagesEndpoint = '/messages';

  // OpenRouter
  static const String openRouterBaseUrl = 'https://openrouter.ai/api/v1';
  static const String openRouterChatEndpoint = '/chat/completions';

  // Groq
  static const String groqBaseUrl = 'https://api.groq.com/openai/v1';
  static const String groqChatEndpoint = '/chat/completions';

  // DeepSeek
  static const String deepSeekBaseUrl = 'https://api.deepseek.com/v1';
  static const String deepSeekChatEndpoint = '/chat/completions';

  // Ollama
  static const String ollamaBaseUrl = 'http://localhost:11434';
  static const String ollamaChatEndpoint = '/api/chat';
  static const String ollamaGenerateEndpoint = '/api/generate';

  // Storage keys
  static const String storageKeyProvider = 'ai_provider';
  static const String storageKeyModel = 'ai_model';
  static const String storageKeyApiKey = 'api_key_';
  static const String storageKeyTemperature = 'temperature';
  static const String storageKeyMaxTokens = 'max_tokens';
  static const String storageKeyBaseUrl = 'custom_base_url';

  // Provider models
  static const Map<String, List<String>> providerModels = {
    'openai': [
      'gpt-4o',
      'gpt-4o-mini',
      'gpt-4-turbo',
      'gpt-4',
      'gpt-3.5-turbo',
    ],
    'gemini': [
      'gemini-1.5-pro',
      'gemini-1.5-flash',
      'gemini-1.0-pro',
    ],
    'anthropic': [
      'claude-3-opus-20240229',
      'claude-3-sonnet-20240229',
      'claude-3-haiku-20240307',
    ],
    'openrouter': [
      'openai/gpt-4o',
      'anthropic/claude-3-opus',
      'google/gemini-1.5-pro',
      'meta-llama/llama-3-70b-instruct',
      'mistralai/mixtral-8x22b',
    ],
    'groq': [
      'llama-3.1-70b-versatile',
      'llama-3.1-8b-instant',
      'mixtral-8x7b-32768',
      'gemma2-9b-it',
    ],
    'deepseek': [
      'deepseek-chat',
      'deepseek-coder',
    ],
    'ollama': [
      'llama3.1',
      'llama3',
      'mistral',
      'mixtral',
      'phi3',
    ],
    'custom': [
      'custom-model',
    ],
  };
}
