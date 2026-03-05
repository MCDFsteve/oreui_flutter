import 'package:flutter/material.dart';

import '../theme/ore_theme.dart';
import '../theme/ore_tokens.dart';
import '../widgets/ore_button.dart';
import '../widgets/ore_card.dart';
import '../widgets/ore_checkbox.dart';
import '../widgets/ore_choice_buttons.dart';
import '../widgets/ore_divider.dart';
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
  double _slider = 0.6;
  int _choice = 0;
  final TextEditingController _controller =
      TextEditingController(text: 'Ore UI');

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
                  ],
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
