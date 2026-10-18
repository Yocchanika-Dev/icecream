import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(
  MaterialApp(
    theme: ThemeData(colorSchemeSeed: Colors.orange),
    debugShowCheckedModeBanner: false,
    home: IcecreamApp(),
  ),
);
// main()：アプリの実行開始地点
// runApp()：Flutterアプリの画面を起動
// MaterialApp：Material Designを使うアプリの基本設定
// const：実行中に変わらない値を表します

class IcecreamApp extends StatefulWidget {
  // StatefulWidget：画面表示中に変化する値を扱うウィジェット
  const IcecreamApp({super.key});
  @override
  State<IcecreamApp> createState() => _IcecreamAppState();
}

class _IcecreamAppState extends State<IcecreamApp> {
  final drinks = {
    '🧃 ジュース（各種）': 400,
    '🧋 タピオカミルクティ': 750,
    '🍸 カクテル': 800,
    '🍺 生ビール': 700,
    '🍵 玉露': 600,
  };
  late String drink = drinks.keys.first;
  String snack = 'なし';
  final foods = <String>{};
  int snackCount = 1, order = 0;
  bool spoon = false, napkin = false;
  String receipt = '';
  // 変数の初期化を最初に使用するときまで遅らせるキーワード

  Widget choices(
    Iterable<String> items,
    String value,
    void Function(String) change,
  ) => Wrap(
    spacing: 6,
    children: [
      for (final s in items)
        ChoiceChip(
          label: Text(s),
          selected: value == s,
          onSelected: (_) => setState(() => change(s)),
        ),
    ],
  );
  @override
  Widget build(BuildContext context) {
    final photo = SizedBox(
      width: 190,
      height: 145,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                snack == 'なし'
                    ? ''
                    : List.filled(snackCount, snack.characters.first).join(),
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          Center(
            child: Text(
              drink.split(' ').first,
              style: const TextStyle(fontSize: 90),
            ),
          ),
          Positioned(
            top: 35,
            right: 28,
            child: SizedBox(
              width: 78,
              child: Text(
                foods.map((s) => s.characters.first).join(),
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
        ],
      ),
    );
    final subtotal =
        drinks[drink]! +
        foods.length * 800 +
        (snack == 'なし' ? 0 : snackCount * 500);
    final tax = subtotal ~/ 10;
    final total = subtotal + tax;
    final products = choices(
      drinks.keys.map((s) => '$s  ${drinks[s]}円'),
      '$drink  ${drinks[drink]}円',
      (s) => drink = s.substring(0, s.lastIndexOf('  ')),
    );

    final toppings = Wrap(
      spacing: 6,
      children: [
        for (final s in ['🌮タコス', '🍙おにぎり', '🍛カレー', '🥟餃子', '🍝スパゲティ'])
          FilterChip(
            label: Text(s),
            selected: foods.contains(s),
            onSelected: (v) => setState(() {
              if (v) {
                foods.add(s);
              } else {
                foods.remove(s);
              }
            }),
          ),
      ],
    );
    final decorations = Column(
      children: [
        choices(['なし', '🍩ドーナツ', '🍪クッキー', '🍮プリン'], snack, (s) => snack = s),
        if (snack != 'なし')
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('おやつ'),
              IconButton(
                onPressed: snackCount > 0
                    ? () => setState(() => snackCount--)
                    : null,
                icon: const Icon(Icons.remove),
              ),
              Text('$snackCount', style: const TextStyle(fontSize: 22)),
              IconButton(
                onPressed: snackCount < 3
                    ? () => setState(() => snackCount++)
                    : null,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
      ],
    );

    Widget supply(String label, bool value, void Function(bool) change) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: value,
          onChanged: (v) => setState(() => change(v ?? false)),
        ),
        Text(label),
      ],
    );
    final supplies = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        supply('🍴 カトラリー（無料）', spoon, (v) => spoon = v),
        supply('🧻 紙ナプキン（無料）', napkin, (v) => napkin = v),
      ],
    );

    final bill = Column(
      children: [
        Text('税抜 $subtotal 円 / 消費税 $tax 円'),
        Text('合計 $total 円', style: const TextStyle(fontSize: 28)),
      ],
    );

    final submit = Center(
      child: FilledButton(
        onPressed: () => setState(() {
          order = Random().nextInt(999) + 1;
          receipt =
              '$drink  ${drinks[drink]}円\n'
              'ごはんもの: ${foods.isEmpty ? 'なし' : foods.join(' ')}\n'
              'おやつ: ${snack == 'なし' ? 'なし' : '$snack × $snackCount'}\n'
              '🍴 カトラリー: ${spoon ? 'あり' : 'なし'}\n'
              '🧻 紙ナプキン: ${napkin ? 'あり' : 'なし'}\n'
              '税抜: $subtotal 円 / 消費税（10%）: $tax 円\n'
              '合計: $total 円';
        }),
        child: const Text('注文する'),
      ),
    );
    final ticket = order == 0
        ? const SizedBox.shrink()
        : Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('注文番号 #$order', style: const TextStyle(fontSize: 26)),
                  Text(receipt),
                ],
              ),
            ),
          );
    // final：変数への再代入禁止

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 240, 193),
      // Scaffold：アプリバーや本文など、基本的な画面構造を作る
      appBar: AppBar(
        centerTitle: true,
        title: const Text('🍙 ごはんとのみもの 屋台注文アプリ'),
        backgroundColor: const Color.fromARGB(255, 255, 195, 112),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(child: photo),
              const Text('商品を選ぶ'),
              products,
              const Text('ごはんもの（各800円）'),
              toppings,
              const Text('おやつ（各500円）'),
              decorations,
              const Text('無料サービス'),
              supplies,
              const Divider(),
              bill,
              submit,
              ticket,
            ],
          ),
        ),
      ),
      // ListView：画面に収まらない内容を縦にスクロールして表示する
    );
  }
}
