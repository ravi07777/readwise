# AI Provider Guide

## Overview

ReadWise AI Assistant supports multiple AI providers for text processing. Users can choose their preferred provider and model.

## Supported Providers

### OpenAI
- **Models:** gpt-4o, gpt-4o-mini, gpt-4-turbo, gpt-4, gpt-3.5-turbo
- **API Key:** https://platform.openai.com/api-keys
- **Base URL:** https://api.openai.com/v1

### Gemini
- **Models:** gemini-1.5-pro, gemini-1.5-flash, gemini-1.0-pro
- **API Key:** https://makersuite.google.com/app/apikey
- **Base URL:** https://generativelanguage.googleapis.com/v1beta

### Anthropic
- **Models:** claude-3-opus, claude-3-sonnet, claude-3-haiku
- **API Key:** https://console.anthropic.com/
- **Base URL:** https://api.anthropic.com/v1

### OpenRouter
- **Models:** Multiple providers via single API
- **API Key:** https://openrouter.ai/keys
- **Base URL:** https://openrouter.ai/api/v1

### Groq
- **Models:** llama-3.1, mixtral, gemma2
- **API Key:** https://console.groq.com/keys
- **Base URL:** https://api.groq.com/openai/v1

### DeepSeek
- **Models:** deepseek-chat, deepseek-coder
- **API Key:** https://platform.deepseek.com/
- **Base URL:** https://api.deepseek.com/v1

### Ollama (Local)
- **Models:** llama3.1, mistral, mixtral, phi3, and more
- **No API key required** (runs locally)
- **Base URL:** http://localhost:11434

### Custom (OpenAI-compatible)
- Any OpenAI-compatible API endpoint
- Examples: LocalAI, vLLM, Text Generation Inference
- Requires custom base URL and API key

## Configuration

### Adding an API Key
1. Go to Settings > AI Providers
2. Select your provider
3. Enter your API key
4. Key is stored securely using encrypted storage

### Switching Providers
1. Go to Settings > AI Providers
2. Tap on the desired provider
3. The active provider is marked with a badge

### Model Selection
1. After selecting a provider, choose from available models
2. Each provider has different model options

## Settings

### Temperature (0.0 - 2.0)
- **Lower values (0.0-0.5):** More focused, deterministic responses
- **Default (0.7):** Balanced creativity and accuracy
- **Higher values (1.0-2.0):** More creative, varied responses

### Max Tokens (256 - 8192)
- Controls maximum response length
- Higher values allow longer responses
- Default: 4096

## API Key Security

- API keys are stored using `flutter_secure_storage`
- On Android, this uses EncryptedSharedPreferences
- Keys are never logged or transmitted outside the app
- Keys can be deleted from the UI at any time

## Connection Testing

Each provider can be tested:
1. Go to AI Providers settings
2. Tap "Test Connection"
3. App sends a simple test message
4. Success/failure is displayed

## Error Handling

| Error | Cause | Solution |
|-------|-------|----------|
| Invalid API key | Wrong or expired key | Check and update API key |
| Rate limit | Too many requests | Wait and retry |
| Model not found | Invalid model name | Select different model |
| Connection timeout | Network issues | Check internet connection |
| Server error | Provider outage | Try again later or switch provider |

## Custom Provider Setup

For custom OpenAI-compatible endpoints:
1. Select "Custom" provider
2. Enter your endpoint URL (e.g., https://your-server.com/v1)
3. Enter API key if required
4. Select model name used by your endpoint

## Ollama Setup

1. Install Ollama on your machine: https://ollama.ai
2. Pull a model: `ollama pull llama3.1`
3. Ensure Ollama is running: `ollama serve`
4. In the app, select Ollama provider
5. No API key needed
6. The app connects to localhost:11434

## Best Practices

1. **Use appropriate models** for different tasks
2. **Start with default temperature** and adjust as needed
3. **Monitor token usage** for cost management
4. **Test connections** after changing settings
5. **Keep API keys secure** - never share them
