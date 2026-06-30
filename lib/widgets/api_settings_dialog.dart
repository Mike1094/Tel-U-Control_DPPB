import 'package:flutter/material.dart';
import '../config/api_config.dart';

/// Dialog widget untuk mengubah pengaturan API URL
class ApiSettingsDialog extends StatefulWidget {
  const ApiSettingsDialog({super.key});

  /// Show the API settings dialog
  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const ApiSettingsDialog(),
    );
  }

  @override
  State<ApiSettingsDialog> createState() => _ApiSettingsDialogState();
}

class _ApiSettingsDialogState extends State<ApiSettingsDialog> {
  final _urlController = TextEditingController();
  bool _isLoading = false;
  String? _selectedPreset;
  
  final List<Map<String, String>> _presets = [
    {
      'name': 'Production Server',
      'url': ApiConfig.defaultProductionUrl,
      'description': 'Server Dosen (Online)',
    },
    {
      'name': 'Local Development',
      'url': ApiConfig.defaultLocalUrl,
      'description': 'Localhost (LAN)',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentUrl();
  }

  Future<void> _loadCurrentUrl() async {
    final currentUrl = await ApiConfig.getBaseUrl();
    _urlController.text = currentUrl;
    
    // Check if current URL matches a preset
    for (final preset in _presets) {
      if (preset['url'] == currentUrl) {
        setState(() => _selectedPreset = preset['name']);
        break;
      }
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _saveAndContinue() async {
    final url = _urlController.text.trim();
    
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('URL tidak boleh kosong'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Basic URL validation
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('URL harus dimulai dengan http:// atau https://'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ApiConfig.setBaseUrl(url);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AlertDialog(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE4002B).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.settings_ethernet,
              color: Color(0xFFE4002B),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Pengaturan API',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pilih server atau masukkan URL API secara manual:',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            
            // Preset buttons
            ...List.generate(_presets.length, (index) {
              final preset = _presets[index];
              final isSelected = _selectedPreset == preset['name'];
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedPreset = preset['name'];
                      _urlController.text = preset['url']!;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected 
                            ? const Color(0xFFE4002B) 
                            : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: isSelected 
                          ? const Color(0xFFE4002B).withValues(alpha: 0.05)
                          : null,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected 
                              ? Icons.radio_button_checked 
                              : Icons.radio_button_off,
                          color: isSelected 
                              ? const Color(0xFFE4002B) 
                              : Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                preset['name']!,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: isSelected 
                                      ? const Color(0xFFE4002B) 
                                      : null,
                                ),
                              ),
                              Text(
                                preset['description']!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            
            const SizedBox(height: 8),
            
            // Custom URL option
            InkWell(
              onTap: () {
                setState(() => _selectedPreset = null);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _selectedPreset == null 
                        ? const Color(0xFFE4002B) 
                        : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
                    width: _selectedPreset == null ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: _selectedPreset == null 
                      ? const Color(0xFFE4002B).withValues(alpha: 0.05)
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      _selectedPreset == null 
                          ? Icons.radio_button_checked 
                          : Icons.radio_button_off,
                      color: _selectedPreset == null 
                          ? const Color(0xFFE4002B) 
                          : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Custom URL',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: _selectedPreset == null 
                                  ? const Color(0xFFE4002B) 
                                  : null,
                            ),
                          ),
                          Text(
                            'Masukkan URL API manual',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // URL Input field
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: 'API Base URL',
                hintText: 'http://192.168.x.x:8000/api/v1',
                prefixIcon: const Icon(Icons.link),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              keyboardType: TextInputType.url,
              onChanged: (value) {
                // Check if the entered URL matches any preset
                bool matchesPreset = false;
                for (final preset in _presets) {
                  if (preset['url'] == value) {
                    setState(() => _selectedPreset = preset['name']);
                    matchesPreset = true;
                    break;
                  }
                }
                if (!matchesPreset && _selectedPreset != null) {
                  setState(() => _selectedPreset = null);
                }
              },
            ),
            
            const SizedBox(height: 8),
            Text(
              'Contoh: http://192.168.0.100:8000/api/v1',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.grey[500] : Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveAndContinue,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE4002B),
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Simpan & Lanjutkan'),
        ),
      ],
    );
  }
}
