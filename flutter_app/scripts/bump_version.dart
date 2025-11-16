import 'dart:io';

/// TekTech Version Bump Script
/// 
/// Automatically bumps version in pubspec.yaml
/// Usage:
///   dart scripts/bump_version.dart [major|minor|patch]
/// 
/// Examples:
///   dart scripts/bump_version.dart patch  // 1.0.0 -> 1.0.1
///   dart scripts/bump_version.dart minor  // 1.0.0 -> 1.1.0
///   dart scripts/bump_version.dart major  // 1.0.0 -> 2.0.0

void main(List<String> args) {
  if (args.isEmpty) {
    print('❌ Usage: dart scripts/bump_version.dart [major|minor|patch]');
    exit(1);
  }

  final bumpType = args[0].toLowerCase();
  if (!['major', 'minor', 'patch'].contains(bumpType)) {
    print('❌ Invalid bump type: $bumpType');
    print('   Valid types: major, minor, patch');
    exit(1);
  }

  final pubspecFile = File('pubspec.yaml');
  if (!pubspecFile.existsSync()) {
    print('❌ pubspec.yaml not found');
    exit(1);
  }

  // Read pubspec.yaml
  final content = pubspecFile.readAsStringSync();
  final lines = content.split('\n');

  // Find version line
  int versionLineIndex = -1;
  String? currentVersion;

  for (var i = 0; i < lines.length; i++) {
    final line = lines[i].trim();
    if (line.startsWith('version:')) {
      versionLineIndex = i;
      currentVersion = line.split('version:')[1].trim();
      break;
    }
  }

  if (currentVersion == null) {
    print('❌ Version not found in pubspec.yaml');
    exit(1);
  }

  // Parse version (format: 1.0.0+1)
  final versionParts = currentVersion.split('+');
  final versionNumbers = versionParts[0].split('.');
  final buildNumber = versionParts.length > 1 ? int.parse(versionParts[1]) : 1;

  if (versionNumbers.length != 3) {
    print('❌ Invalid version format: $currentVersion');
    print('   Expected format: x.y.z+build');
    exit(1);
  }

  var major = int.parse(versionNumbers[0]);
  var minor = int.parse(versionNumbers[1]);
  var patch = int.parse(versionNumbers[2]);

  // Bump version
  switch (bumpType) {
    case 'major':
      major++;
      minor = 0;
      patch = 0;
      break;
    case 'minor':
      minor++;
      patch = 0;
      break;
    case 'patch':
      patch++;
      break;
  }

  final newVersion = '$major.$minor.$patch+${buildNumber + 1}';

  // Update pubspec.yaml
  lines[versionLineIndex] = 'version: $newVersion';
  pubspecFile.writeAsStringSync(lines.join('\n'));

  print('✅ Version bumped: $currentVersion -> $newVersion');
  print('');
  print('📝 Next steps:');
  print('   1. Review the changes');
  print('   2. Commit: git add pubspec.yaml');
  print('   3. Commit: git commit -m "chore: bump version to $newVersion"');
  print('   4. Tag: git tag v$newVersion');
  print('   5. Push: git push && git push --tags');
}
