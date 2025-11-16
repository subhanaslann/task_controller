import 'package:flutter/material.dart';

/// TekTech UserAvatar Component
/// 
/// Displays user avatar with initials fallback
/// - Circular avatar with optional image
/// - Initials fallback (first letters of firstName + lastName)
/// - Size variants (small, medium, large)
/// - Color-coded background based on username
class UserAvatar extends StatelessWidget {
  final String? firstName;
  final String? lastName;
  final String? name; // Alternative to firstName/lastName
  final String? imageUrl;
  final AvatarSize size;
  final VoidCallback? onTap;

  const UserAvatar({
    Key? key,
    this.firstName,
    this.lastName,
    this.name,
    this.imageUrl,
    this.size = AvatarSize.medium,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dimensions = _getDimensions(size);
    
    // Use name if provided, otherwise use firstName/lastName
    final nameParts = name != null ? _splitName(name!) : (null, null);
    final effectiveFirstName = firstName ?? nameParts.$1;
    final effectiveLastName = lastName ?? nameParts.$2;
    
    final initials = _getInitials(effectiveFirstName, effectiveLastName);
    final backgroundColor = _getColorFromName(effectiveFirstName, effectiveLastName);

    final avatarLabel = effectiveFirstName != null || effectiveLastName != null
        ? 'Kullanıcı: ${effectiveFirstName ?? ''} ${effectiveLastName ?? ''}'
        : name != null
            ? 'Kullanıcı: $name'
            : 'Kullanıcı avatarı';

    final avatar = Semantics(
      label: avatarLabel,
      button: onTap != null,
      child: Container(
        width: dimensions.size,
        height: dimensions.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
        image: imageUrl != null
            ? DecorationImage(
                image: NetworkImage(imageUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: imageUrl == null
          ? Center(
              child: Text(
                initials,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: dimensions.fontSize,
                ),
              ),
            )
          : null,
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(dimensions.size / 2),
        child: avatar,
      );
    }

    return avatar;
  }

  (String?, String?) _splitName(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return (null, null);
    if (parts.length == 1) return (parts[0], null);
    return (parts[0], parts[parts.length - 1]);
  }

  String _getInitials(String? firstName, String? lastName) {
    final first = firstName?.isNotEmpty == true ? firstName![0].toUpperCase() : '';
    final last = lastName?.isNotEmpty == true ? lastName![0].toUpperCase() : '';
    
    if (first.isEmpty && last.isEmpty) {
      return '?';
    }
    
    return '$first$last';
  }

  Color _getColorFromName(String? firstName, String? lastName) {
    // Generate consistent color based on name hash
    final name = '${firstName ?? ''}${lastName ?? ''}'.toLowerCase();
    if (name.isEmpty) {
      return const Color(0xFF6B7280); // Gray for unknown
    }

    final colors = [
      const Color(0xFF3B82F6), // Blue
      const Color(0xFF10B981), // Green
      const Color(0xFFF59E0B), // Amber
      const Color(0xFFEF4444), // Red
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFFEC4899), // Pink
      const Color(0xFF06B6D4), // Cyan
      const Color(0xFF84CC16), // Lime
    ];

    final hash = name.codeUnits.fold(0, (prev, code) => prev + code);
    return colors[hash % colors.length];
  }

  _AvatarDimensions _getDimensions(AvatarSize size) {
    switch (size) {
      case AvatarSize.small:
        return _AvatarDimensions(size: 32, fontSize: 12);
      case AvatarSize.medium:
        return _AvatarDimensions(size: 40, fontSize: 14);
      case AvatarSize.large:
        return _AvatarDimensions(size: 56, fontSize: 18);
    }
  }
}

enum AvatarSize {
  small,
  medium,
  large,
}

class _AvatarDimensions {
  final double size;
  final double fontSize;

  _AvatarDimensions({
    required this.size,
    required this.fontSize,
  });
}
