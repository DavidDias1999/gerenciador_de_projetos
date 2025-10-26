import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pub_semver/pub_semver.dart';

const String _githubUser = 'DavidDias1999';
const String _githubRepo = 'gerenciador_de_projetos';

Future<void> checkForUpdates(BuildContext context) async {
  if (!Platform.isWindows) {
    return;
  }

  try {
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = Version.parse(packageInfo.version);
    debugPrint('Versão Atual: $currentVersion');

    final url = Uri.parse(
        'https://api.github.com/repos/$_githubUser/$_githubRepo/releases/latest');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      debugPrint('Falha ao verificar updates: ${response.statusCode}');
      return;
    }

    final jsonResponse = json.decode(response.body);
    final tagName = jsonResponse['tag_name'] as String;
    final latestVersionStr =
        tagName.startsWith('v') ? tagName.substring(1) : tagName;
    final latestVersion = Version.parse(latestVersionStr);
    debugPrint('Última Versão no GitHub: $latestVersion');

    if (latestVersion > currentVersion) {
      debugPrint('Nova versão encontrada!');
      final assets = jsonResponse['assets'] as List;
      final installerAsset = assets.firstWhere(
        (asset) => (asset['name'] as String).endsWith('.exe'),
        orElse: () => null,
      );

      if (installerAsset == null) {
        debugPrint('Nenhum asset .exe encontrado no release.');
        return;
      }

      final downloadUrl = installerAsset['browser_download_url'] as String;

      if (context.mounted) {
        await _showUpdateDialog(context, latestVersion.toString(), downloadUrl);
      }
    } else {
      debugPrint('O aplicativo já está na versão mais recente.');
    }
  } catch (e) {
    debugPrint('Erro ao verificar atualizações: $e');
  }
}

Future<void> _showUpdateDialog(
    BuildContext context, String newVersion, String downloadUrl) async {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: const Text('Atualização Disponível'),
      content: Text(
          'Uma nova versão ($newVersion) está disponível. Deseja atualizar agora? O aplicativo será reiniciado.'),
      actions: [
        TextButton(
          child: const Text('Depois'),
          onPressed: () => Navigator.of(ctx).pop(),
        ),
        FilledButton(
          child: const Text('Atualizar Agora'),
          onPressed: () {
            Navigator.of(ctx).pop();
            _downloadAndRunInstaller(context, downloadUrl);
          },
        ),
      ],
    ),
  );
}

Future<void> _downloadAndRunInstaller(BuildContext context, String url) async {
  try {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const PopScope(
        canPop: false,
        child: AlertDialog(
          title: Text('Baixando Atualização'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Por favor, aguarde...'),
            ],
          ),
        ),
      ),
    );

    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) throw 'Erro no download';

    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}\\update_installer.exe';
    final file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    debugPrint('Download completo. Salvo em: $filePath');

    if (context.mounted) Navigator.of(context).pop();

    await Process.run(filePath, ['/SILENT']);
    exit(0);
  } catch (e) {
    debugPrint('Erro no download ou execução do instalador: $e');
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }
}
