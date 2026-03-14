import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/llm_config.dart';
import '../../services/preference_service.dart';
import '../../services/ambient_service.dart';
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
                        ? "您正通过公共思维信标与先贤微弱共鸣。即刻开启寻觅。"
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

          // 2. Ambient Music Control Card
          // Extracted to a separate method for cleaner UI structure.
          const SizedBox(height: 20),
          _buildAmbientMusicCard(),

          // 3. Configuration Area (Only for Speed Mode)
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
                          child: Text('Minimax (海螺)'),
                        ),
                        DropdownMenuItem(
                          value: LLMProvider.moonshot,
                          child: Text('Moonshot (Kimi)'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            // Clear token when switching providers to avoid using wrong key
                            _apiKeyController.clear();
                            _config = _config.copyWith(
                              provider: value,
                              apiKey: '',
                            );
                          });
                          // 交互优化：去除自动保存，等待用户手动点击“确认”
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
                        // Manual save only
                      },
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.indigoAccent, // Highlight color
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ), // Taller
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        onPressed: () {
                          // Validation Logic
                          if (_config.mode == AppMode.speed &&
                              _apiKeyController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  '⚠️ 请输入 API Key (Token) / Please enter a valid token',
                                ),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }
                          _saveConfig();
                        },
                        icon: const Icon(Icons.check_circle, size: 24),
                        label: const Text(
                          "确认 / Confirm",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Restart Journey Button
          const SizedBox(height: 40),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black54,
                  side: const BorderSide(color: Colors.black26),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  // Reset First Run Flag
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('is_first_run', true);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('已重置指引，即将重新开始旅程...')),
                    );
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const OnboardingPage()),
                      (route) => false,
                    );
                  }
                },
                icon: const Icon(Icons.restart_alt_rounded, size: 20),
                label: const Text(
                  "重启旅程 (Reset Guide)",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// Builds the Ambient Music Control Card.
  /// Uses a ListenableBuilder to reactively update the UI when the AmbientService state changes,
  /// ensuring smooth slider and toggle interactions.
  Widget _buildAmbientMusicCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListenableBuilder(
          listenable: AmbientService.instance,
          builder: (context, _) {
            final ambient = AmbientService.instance;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Row(
                    children: const [
                      Icon(Icons.music_note_rounded, size: 18, color: Colors.black54),
                      SizedBox(width: 8),
                      Text("环境音乐 / Ambient Music", style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  subtitle: const Text("平静的声学纹理 (Calm acoustic textures)", style: TextStyle(fontSize: 12)),
                  value: ambient.isEnabled,
                  activeColor: Colors.black87,
                  onChanged: (value) {
                    HapticFeedback.lightImpact();
                    ambient.setEnabled(value);
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
