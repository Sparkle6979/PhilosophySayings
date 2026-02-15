import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/llm_config.dart';
import '../../services/preference_service.dart';
import 'onboarding_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _preferenceService = PreferenceService();
  late LLMConfig _config;
  bool _isLoading = true;
  final TextEditingController _apiKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    await _preferenceService.init(); // Ensure init
    setState(() {
      _config = _preferenceService.getLLMConfig();
      _apiKeyController.text = _config.apiKey;
      _isLoading = false;
    });
  }

  Future<void> _saveConfig() async {
    final newConfig = _config.copyWith(apiKey: _apiKeyController.text.trim());
    await _preferenceService.saveLLMConfig(newConfig);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('设置已保存 / Settings Saved')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('心智连接 / Mind Link')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Mode Toggle Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _config.mode == AppMode.experience
                            ? Icons.hourglass_empty_rounded
                            : Icons.all_inclusive_rounded,
                        color: _config.mode == AppMode.experience
                            ? Colors.amber
                            : Colors.indigoAccent,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _config.mode == AppMode.experience
                            ? "浅尝辄止 (Ephemeral)"
                            : "深度共鸣 (Resonance)",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _config.mode == AppMode.experience
                        ? "您正使用公共通道与先贤微弱共鸣。每日都在消耗着缘分。"
                        : "您已建立私有的灵魂链路。在此，思想的流动不再受限。",
                    style: TextStyle(color: Colors.grey[600], height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text("建立深度连接"),
                    subtitle: const Text("Establish Deep Resonance"),
                    value: _config.mode == AppMode.speed,
                    activeColor: Colors.indigoAccent,
                    onChanged: (value) {
                      setState(() {
                        _config = _config.copyWith(
                          mode: value ? AppMode.speed : AppMode.experience,
                        );
                      });
                      _saveConfig();
                    },
                  ),
                ],
              ),
            ),
          ),

          // 2. Configuration Area (Only for Speed Mode)
          if (_config.mode == AppMode.speed) ...[
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.only(left: 8, bottom: 8),
              child: Text(
                "灵魂媒介 / Medium",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
            ),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Provider Dropdown
                    DropdownButtonFormField<LLMProvider>(
                      decoration: const InputDecoration(
                        labelText: '选择一位摆渡人 / Choose a Guide',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      value: _config.provider,
                      items: const [
                        DropdownMenuItem(
                          value: LLMProvider.deepseek,
                          child: Text("DeepSeek (深度求索)"),
                        ),
                        DropdownMenuItem(
                          value: LLMProvider.qwen,
                          child: Text("Qwen (通义千问)"),
                        ),
                        DropdownMenuItem(
                          value: LLMProvider.minimax,
                          child: Text("Minimax (海螺)"),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _config = _config.copyWith(provider: value);
                          });
                          _saveConfig();
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    // API Key Input
                    TextField(
                      controller: _apiKeyController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: '信物 (Token)',
                        border: OutlineInputBorder(),
                        helperText: "您的信物 (API Key) 仅封存于本地",
                        suffixIcon: Icon(Icons.vpn_key_outlined),
                      ),
                      onChanged: (_) {
                        // Delay save or save on separate button?
                        // For simplicity, let's have a manual save button at bottom or save on exit.
                        // But here we can just update local state and rely on explicit save.
                      },
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black87,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: _saveConfig,
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text("缔结契约 / Seal the Pact"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Debug Reset Button (Moved to end of list)
          const SizedBox(height: 40),
          SafeArea(
            child: Center(
              child: TextButton(
                onPressed: () async {
                  // Reset First Run Flag
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('is_first_run', true);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('已重置引导，即将重启...')),
                    );
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const OnboardingPage()),
                      (route) => false,
                    );
                  }
                },
                child: const Text(
                  "[Debug] 重置首次引导",
                  style: TextStyle(color: Colors.redAccent, fontSize: 12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
