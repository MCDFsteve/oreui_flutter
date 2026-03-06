import 'package:flutter/material.dart';

import '../theme/ore_theme.dart';
import '../theme/ore_tokens.dart';
import '../widgets/ore_button.dart';
import '../widgets/ore_card.dart';
import '../widgets/ore_checkbox.dart';
import '../widgets/ore_choice_buttons.dart';
import '../widgets/ore_choice_description.dart';
import '../widgets/ore_divider.dart';
import '../widgets/ore_dropdown_button.dart';
import '../widgets/ore_strip.dart';
import '../widgets/ore_slider.dart';
import '../widgets/ore_switch.dart';
import '../widgets/ore_text_field.dart';

class OreShowcaseApp extends StatelessWidget {
  const OreShowcaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ore = OreThemeData.ore();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        extensions: [ore],
      ),
      home: OreTheme(
        data: ore,
        child: const OreShowcasePage(),
      ),
    );
  }
}

class OreShowcasePage extends StatefulWidget {
  const OreShowcasePage({super.key});

  @override
  State<OreShowcasePage> createState() => _OreShowcasePageState();
}

class _OreShowcasePageState extends State<OreShowcasePage> {
  bool _checked = true;
  bool _toggled = true;
  bool? _tri = null;
  int _difficulty = 0;
  double _slider = 0.6;
  int _choice = 0;
  String _dropdownValue = '选项一';
  final TextEditingController _controller =
      TextEditingController(text: 'Ore UI');

  static const List<OreDropdownItem<String>> _dropdownItems = [
    OreDropdownItem(value: '选项一', child: Text('选项一')),
    OreDropdownItem(value: '选项二', child: Text('选项二')),
    OreDropdownItem(value: '选项三', child: Text('选项三')),
  ];
  static const List<Widget> _difficultyItems = [
    Text('和平'),
    Text('简单'),
    Text('一般'),
    Text('困难'),
  ];
  static const List<Widget> _difficultyDescriptions = [
    Text('没有敌对生物，只会生成一些中立生物。饥饿条不会消耗，且生命值会随时间回复。'),
    Text('会生成敌对生物，但其造成的伤害较少。饥饿条会消耗，且生命值降低至5颗心。'),
    Text('会生成敌对生物，造成正常伤害。饥饿条会消耗，且生命值降低至一半颗心。'),
    Text('会生成敌对生物，且其造成的伤害增加。饥饿条会消耗，且生命值降低为零。'),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ore = OreTheme.of(context);
    final colors = ore.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(OreTokens.gapLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ore UI Showcase', style: ore.typography.title),
              const SizedBox(height: OreTokens.gapLg),
              OreCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Buttons', style: ore.typography.label),
                    const SizedBox(height: OreTokens.gapSm),
                    Wrap(
                      spacing: OreTokens.gapSm,
                      runSpacing: OreTokens.gapSm,
                      children: [
                        OreButton(
                          onPressed: () {},
                          child: const Text('Normal'),
                        ),
                        OreButton(
                          variant: OreButtonVariant.primary,
                          onPressed: () {},
                          child: const Text('Confirm'),
                        ),
                        OreButton(
                          variant: OreButtonVariant.danger,
                          onPressed: () {},
                          child: const Text('Delete'),
                        ),
                        const OreButton(
                          onPressed: null,
                          child: Text('Disabled'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: OreTokens.gapLg),
              OreCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Form', style: ore.typography.label),
                    const SizedBox(height: OreTokens.gapSm),
                    OreTextField(
                      controller: _controller,
                      hintText: '输入内容',
                      onChanged: (_) {},
                    ),
                    const SizedBox(height: OreTokens.gapMd),
                    OreTextField(
                      enabled: false,
                      hintText: '禁用输入框',
                    ),
                    const SizedBox(height: OreTokens.gapMd),
                    OreSlider(
                      value: _slider,
                      onChanged: (value) => setState(() => _slider = value),
                    ),
                    const SizedBox(height: OreTokens.gapMd),
                    OreDropdownButton<String>(
                      items: _dropdownItems,
                      value: _dropdownValue,
                      onChanged: (value) =>
                          setState(() => _dropdownValue = value),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: OreTokens.gapLg),
              OreStrip(
                padding:
                    const EdgeInsets.symmetric(vertical: OreTokens.gapSm),
                child: DefaultTextStyle.merge(
                  style: ore.typography.body.copyWith(
                    color: colors.textPrimary,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('难度', style: ore.typography.label),
                      const SizedBox(height: OreTokens.gapSm),
                      OreChoiceButtons(
                        items: _difficultyItems,
                        selectedIndex: _difficulty,
                        onChanged: (value) =>
                            setState(() => _difficulty = value),
                      ),
                      const SizedBox(height: OreTokens.gapSm),
                      OreChoiceDescription(
                        items: _difficultyDescriptions,
                        selectedIndex: _difficulty,
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: OreTokens.gapLg),
              OreCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Toggles', style: ore.typography.label),
                    const SizedBox(height: OreTokens.gapSm),
                    Wrap(
                      spacing: OreTokens.gapLg,
                      runSpacing: OreTokens.gapSm,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        OreChoiceButtons(
                          items: const [
                            Text('选项一'),
                            Text('选项二'),
                            Text('选项三'),
                          ],
                          selectedIndex: _choice,
                          onChanged: (value) => setState(() => _choice = value),
                        ),
                        OreCheckbox(
                          value: _checked,
                          onChanged: (value) =>
                              setState(() => _checked = value ?? false),
                          label: const Text('Checked'),
                        ),
                        OreCheckbox(
                          value: _tri,
                          tristate: true,
                          onChanged: (value) => setState(() => _tri = value),
                          label: const Text('Tri-state'),
                        ),
                        OreSwitch(
                          value: _toggled,
                          onChanged: (value) =>
                              setState(() => _toggled = value),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: OreTokens.gapLg),
              const OreDivider(),
              const SizedBox(height: OreTokens.gapSm),
              Text(
                'Minecraft 风格的基础控件集合演示。',
                style: ore.typography.body.copyWith(color: colors.textInverse),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
