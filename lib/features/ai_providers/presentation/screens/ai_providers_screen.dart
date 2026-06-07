import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/ai_client.dart';
import '../../../../core/services/secure_storage_service.dart';

final aiProviderConfigProvider =
    StateNotifierProvider<AIProviderConfigNotifier, AIProviderConfig>((ref) {
  return AIProviderConfigNotifier(ref.watch(secureStorageServiceProvider));
});

class AIProviderConfigNotifier extends StateNotifier<AIProviderConfig> {
  final SecureStorageService _storage;

  AIProviderConfigNotifier(this._storage) : super(const AIProviderConfig()) {
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final providerStr = _storage.getString(ApiConstants.storageKeyProvider);
    final model = _storage.getString(ApiConstants.storageKeyModel);
    final temp = _storage.getDouble(ApiConstants.storageKeyTemperature);
    final maxTokens = _storage.getInt(ApiConstants.storageKeyMaxTokens);
    final baseUrl = _storage.getString(ApiConstants.storageKeyBaseUrl);

    final provider = providerStr != null
        ? AIProvider.values.firstWhere(
            (e) => e.name == providerStr,
            orElse: () => AIProvider.openAI,
          )
        : AIProvider.openAI;

    state = AIProviderConfig(
      provider: provider,
      model: model ?? provider.defaultModel,
      temperature: temp ?? 0.7,
      maxTokens: maxTokens ?? 4096,
      customBaseUrl: baseUrl,
    );
  }

  Future<void> setProvider(AIProvider provider) async {
    final currentModel = _storage.getString(ApiConstants.storageKeyModel);
    state = state.copyWith(
      provider: provider,
      model: currentModel ?? provider.defaultModel,
    );
    await _storage.setString(ApiConstants.storageKeyProvider, provider.name);
  }

  Future<void> setModel(String model) async {
    state = state.copyWith(model: model);
    await _storage.setString(ApiConstants.storageKeyModel, model);
  }

  Future<void> setTemperature(double temp) async {
    state = state.copyWith(temperature: temp);
    await _storage.setDouble(ApiConstants.storageKeyTemperature, temp);
  }

  Future<void> setMaxTokens(int tokens) async {
    state = state.copyWith(maxTokens: tokens);
    await _storage.setInt(ApiConstants.storageKeyMaxTokens, tokens);
  }

  Future<void> setCustomBaseUrl(String url) async {
    state = state.copyWith(customBaseUrl: url);
    await _storage.setString(ApiConstants.storageKeyBaseUrl, url);
  }

  Future<void> saveApiKey(String provider, String apiKey) async {
    await _storage.saveApiKey(provider, apiKey);
  }

  Future<String?> getApiKey(String provider) async {
    return await _storage.getApiKey(provider);
  }

  Future<void> deleteApiKey(String provider) async {
    await _storage.deleteApiKey(provider);
  }

  Future<bool> hasApiKey(String provider) async {
    return await _storage.hasApiKey(provider);
  }
}

class AIProvidersScreen extends ConsumerStatefulWidget {
  const AIProvidersScreen({super.key});

  @override
  ConsumerState<AIProvidersScreen> createState() => _AIProvidersScreenState();
}

class _AIProvidersScreenState extends ConsumerState<AIProvidersScreen> {
  final _apiKeyControllers = <String, TextEditingController>{};
  final _baseUrlController = TextEditingController();
  bool _obscureKeys = true;

  @override
  void initState() {
    super.initState();
    for (final provider in AIProvider.values) {
      _apiKeyControllers[provider.name] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final controller in _apiKeyControllers.values) {
      controller.dispose();
    }
    _baseUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(aiProviderConfigProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Providers'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Select Provider', Icons.cloud_outlined, colorScheme),
          const SizedBox(height: 12),
          ...AIProvider.values.map((provider) => _buildProviderCard(provider, config, colorScheme)),
          const SizedBox(height: 24),
          _buildSectionHeader('Model Settings', Icons.tune_outlined, colorScheme),
          const SizedBox(height: 12),
          _buildModelSelector(config, colorScheme),
          const SizedBox(height: 16),
          _buildTemperatureSlider(config, colorScheme),
          const SizedBox(height: 16),
          _buildMaxTokensSlider(config, colorScheme),
          if (config.provider == AIProvider.custom) ...[
            const SizedBox(height: 16),
            _buildCustomUrlField(config, colorScheme),
          ],
          const SizedBox(height: 24),
          _buildSectionHeader('Connection Test', Icons.wifi_tethering_outlined, colorScheme),
          const SizedBox(height: 12),
          _buildConnectionTestButton(config, colorScheme),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, ColorScheme colorScheme) {
    return Row(
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildProviderCard(AIProvider provider, AIProviderConfig config, ColorScheme colorScheme) {
    final isSelected = config.provider == provider;
    final hasKey = ref.watch(aiProviderConfigProvider).maybeWhen(
          orElse: () => false,
        );

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          ref.read(aiProviderConfigProvider.notifier).setProvider(provider);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primaryContainer
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      _getProviderIcon(provider),
                      color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              provider.displayName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (isSelected)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Active',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: colorScheme.onPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Model: ${config.provider == provider ? config.model : provider.defaultModel}',
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Radio<AIProvider>(
                    value: provider,
                    groupValue: config.provider,
                    onChanged: (value) {
                      if (value != null) {
                        ref.read(aiProviderConfigProvider.notifier).setProvider(value);
                      }
                    },
                  ),
                ],
              ),
              if (provider != AIProvider.ollama) ...[
                const SizedBox(height: 12),
                _buildApiKeyField(provider, colorScheme),
              ],
            ],
          ),
        ),
      ),
    ).animate().fadeIn();
  }

  Widget _buildApiKeyField(AIProvider provider, ColorScheme colorScheme) {
    return FutureBuilder<String?>(
      future: ref.read(aiProviderConfigProvider.notifier).getApiKey(provider.name),
      builder: (context, snapshot) {
        final hasKey = snapshot.data != null && snapshot.data!.isNotEmpty;
        final controller = _apiKeyControllers[provider.name]!;
        if (hasKey && controller.text.isEmpty) {
          controller.text = '********';
        }

        return Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                obscureText: _obscureKeys,
                decoration: InputDecoration(
                  hintText: 'Enter ${provider.displayName} API key',
                  isDense: true,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureKeys ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      size: 18,
                    ),
                    onPressed: () => setState(() => _obscureKeys = !_obscureKeys),
                  ),
                ),
                onChanged: (value) {
                  if (value.isNotEmpty && value != '********') {
                    ref.read(aiProviderConfigProvider.notifier).saveApiKey(provider.name, value);
                  }
                },
              ),
            ),
            if (hasKey)
              IconButton(
                icon: Icon(Icons.delete_outline, color: colorScheme.error, size: 20),
                onPressed: () async {
                  await ref.read(aiProviderConfigProvider.notifier).deleteApiKey(provider.name);
                  controller.clear();
                },
              ),
          ],
        );
      },
    );
  }

  Widget _buildModelSelector(AIProviderConfig config, ColorScheme colorScheme) {
    final models = ApiConstants.providerModels[config.provider.name] ?? ['gpt-4o'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Model',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: models.contains(config.model) ? config.model : models.first,
              decoration: const InputDecoration(
                isDense: true,
              ),
              items: models.map((model) {
                return DropdownMenuItem(
                  value: model,
                  child: Text(model, style: const TextStyle(fontSize: 14)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  ref.read(aiProviderConfigProvider.notifier).setModel(value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemperatureSlider(AIProviderConfig config, ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Temperature',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  config.temperature.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            Slider(
              value: config.temperature,
              min: 0.0,
              max: 2.0,
              divisions: 20,
              label: config.temperature.toStringAsFixed(1),
              onChanged: (value) {
                ref.read(aiProviderConfigProvider.notifier).setTemperature(value);
              },
            ),
            Text(
              'Lower = precise, Higher = creative',
              style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaxTokensSlider(AIProviderConfig config, ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Max Tokens',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  '${config.maxTokens}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            Slider(
              value: config.maxTokens.toDouble(),
              min: 256,
              max: 8192,
              divisions: 31,
              label: '${config.maxTokens}',
              onChanged: (value) {
                ref.read(aiProviderConfigProvider.notifier).setMaxTokens(value.toInt());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomUrlField(AIProviderConfig config, ColorScheme colorScheme) {
    if (_baseUrlController.text.isEmpty && config.customBaseUrl != null) {
      _baseUrlController.text = config.customBaseUrl!;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Custom Base URL',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _baseUrlController,
              decoration: const InputDecoration(
                hintText: 'https://your-api-endpoint.com/v1',
                isDense: true,
              ),
              onChanged: (value) {
                ref.read(aiProviderConfigProvider.notifier).setCustomBaseUrl(value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionTestButton(AIProviderConfig config, ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Test your ${config.provider.displayName} connection',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.wifi_tethering, size: 18),
              label: const Text('Test Connection'),
              onPressed: () async {
                // Implement connection test
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Testing connection...')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  IconData _getProviderIcon(AIProvider provider) {
    switch (provider) {
      case AIProvider.openAI:
        return Icons.psychology_outlined;
      case AIProvider.gemini:
        return Icons.auto_awesome_outlined;
      case AIProvider.anthropic:
        return Icons.smart_toy_outlined;
      case AIProvider.openRouter:
        return Icons.hub_outlined;
      case AIProvider.groq:
        return Icons.bolt_outlined;
      case AIProvider.deepSeek:
        return Icons.explore_outlined;
      case AIProvider.ollama:
        return Icons.laptop_outlined;
      case AIProvider.custom:
        return Icons.code_outlined;
    }
  }
}
