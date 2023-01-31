import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kanban/style/borders.dart';
import 'package:kanban/utils/context_ext.dart';

const _googleBlue = Color(0xff4285f4);
const _googleWhite = Color(0xffffffff);
const _googleDark = Color(0xff757575);

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
    required this.onTap,
    this.height = 40,
    this.loading = false,
    super.key,
  });

  final bool loading;
  final double height;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final brightness = theme.brightness;
    final color = brightness == Brightness.light ? _googleWhite : _googleDark;
    final backgroundColor = brightness == Brightness.light ? _googleBlue : _googleWhite;
    final foreground = Positioned.fill(
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: Borders.roundedAll5,
        ),
      ),
    );
    return SizedBox(
      height: height,
      child: Material(
        color: backgroundColor,
        borderRadius: Borders.roundedAll5,
        child: Stack(
          fit: StackFit.expand,
          children: [
            PositionedDirectional(
              start: 0,
              top: 0,
              bottom: 0,
              child: SvgPicture.asset('assets/svg/google_icon.svg', height: height, width: height),
            ),
            Center(
              child: Text(
                context.localizations.signInWithGoogleButtonText,
                style: theme.textTheme.labelLarge?.copyWith(color: color),
              ),
            ),
            foreground,
          ],
        ),
      ),
    );
  }
}
