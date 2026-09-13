import 'package:flutter/material.dart';

import 'theme/theme.dart';

void main() {
  runApp(const EdencrewAssignmentApp());
}

class EdencrewAssignmentApp extends StatelessWidget {
  const EdencrewAssignmentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '이든크루 평가 과제',
      theme: AppTheme.dark,
      home: const StartHereScreen(),
    );
  }
}

/// 과제 시작점입니다. 이 화면은 지우고 직접 구현한 화면으로 바꿔 주세요.
///
/// 디자인 토큰을 어떻게 꺼내 쓰는지 보여주는 예시이기도 합니다.
class StartHereScreen extends StatelessWidget {
  const StartHereScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(dimens.space5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '이든크루 평가 과제',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 24,
                  fontWeight: AppTypography.bold,
                ),
              ),
              SizedBox(height: dimens.space2),
              Text(
                'README.md를 먼저 읽고, 이 화면부터 교체해 주세요.\n'
                '색과 간격은 lib/theme의 토큰을 통해서만 사용해 주세요.',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 14,
                  fontWeight: AppTypography.regular,
                  height: 1.5,
                ),
              ),
              SizedBox(height: dimens.space5),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: dimens.space3,
                  vertical: dimens.space2,
                ),
                decoration: BoxDecoration(
                  color: colors.accentBg,
                  borderRadius: BorderRadius.circular(dimens.radiusMd),
                  border: Border.all(
                    color: colors.borderSubtle,
                    width: dimens.borderHairline,
                  ),
                ),
                child: Text(
                  'context.colors / context.dimens',
                  style: TextStyle(
                    color: colors.accentDefault,
                    fontSize: 13,
                    fontWeight: AppTypography.medium,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
