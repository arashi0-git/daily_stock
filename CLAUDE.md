現在デプロイ環境でエラーが起きていてデプロイできない状態です
以下にエラー要項を載せます

Run flutter build web --release

Compiling lib/main.dart for the Web...                          
Warning: In index.html:49: Local variable for "serviceWorkerVersion" is deprecated. Use "***flutter_service_worker_version***" template token instead. See https://docs.flutter.dev/platform-integration/web/initialization for more details.
Warning: In index.html:59: "FlutterLoader.loadEntrypoint" is deprecated. Use "FlutterLoader.load" instead. See https://docs.flutter.dev/platform-integration/web/initialization for more details.
Target dart2js failed: ProcessException: Process exited abnormally with exit code 1:
lib/screens/home_screen.dart:739:28:
Error: The getter 'shade25' isn't defined for the class 'MaterialColor'.
 - 'MaterialColor' is from 'package:flutter/src/material/colors.dart' ('/opt/hostedtoolcache/flutter/stable-3.29.3-x64/packages/flutter/lib/src/material/colors.dart').
                Colors.red.shade25,
                           ^^^^^^^
lib/screens/items_screen.dart:157:44:
Error: The getter 'shade25' isn't defined for the class 'MaterialColor'.
 - 'MaterialColor' is from 'package:flutter/src/material/colors.dart' ('/opt/hostedtoolcache/flutter/stable-3.29.3-x64/packages/flutter/lib/src/material/colors.dart').
                                Colors.red.shade25,
                                           ^^^^^^^
Error: Compilation failed.
  Command: /opt/hostedtoolcache/flutter/stable-3.29.3-x64/bin/cache/dart-sdk/bin/dart compile js --platform-binaries=/opt/hostedtoolcache/flutter/stable-3.29.3-x64/bin/cache/flutter_web_sdk/kernel --invoker=flutter_tool -Ddart.vm.product=true -DFLUTTER_WEB_USE_SKIA=true -DFLUTTER_WEB_USE_SKWASM=false -DFLUTTER_WEB_CANVASKIT_URL=https://www.gstatic.com/flutter-canvaskit/cf56914b326edb0ccb123ffdc60f00060bd513fa/ --native-null-assertions --no-source-maps -o /home/runner/work/daily_stock/daily_stock/frontend/.dart_tool/flutter_build/d12e46422de5e2738ca11434eca92746/app.dill --packages=/home/runner/work/daily_stock/daily_stock/frontend/.dart_tool/package_config.json --cfe-only /home/runner/work/daily_stock/daily_stock/frontend/.dart_tool/flutter_build/d12e46422de5e2738ca11434eca92746/main.dart
#0      RunResult.throwException (package:flutter_tools/src/base/process.dart:118:5)
#1      _DefaultProcessUtils.run (package:flutter_tools/src/base/process.dart:344:19)
<asynchronous suspension>
#2      Dart2JSTarget.build (package:flutter_tools/src/build_system/targets/web.dart:201:5)
<asynchronous suspension>
#3      _BuildInstance._invokeInternal (package:flutter_tools/src/build_system/build_system.dart:876:9)
<asynchronous suspension>
#4      Future.wait.<anonymous closure> (dart:async/future.dart:528:21)
<asynchronous suspension>
#5      _BuildInstance.invokeTarget (package:flutter_tools/src/build_system/build_system.dart:814:32)
<asynchronous suspension>
#6      Future.wait.<anonymous closure> (dart:async/future.dart:528:21)
<asynchronous suspension>
#7      _BuildInstance.invokeTarget (package:flutter_tools/src/build_system/build_system.dart:814:32)
<asynchronous suspension>
#8      FlutterBuildSystem.build (package:flutter_tools/src/build_system/build_system.dart:637:16)
<asynchronous suspension>
#9      WebBuilder.buildWeb (package:flutter_tools/src/web/compile.dart:93:34)
<asynchronous suspension>
#10     BuildWebCommand.runCommand (package:flutter_tools/src/commands/build_web.dart:253:5)
<asynchronous suspension>
#11     FlutterCommand.run.<anonymous closure> (package:flutter_tools/src/runner/flutter_command.dart:1558:27)
<asynchronous suspension>
#12     AppContext.run.<anonymous closure> (package:flutter_tools/src/base/context.dart:154:19)
<asynchronous suspension>
#13     CommandRunner.runCommand (package:args/command_runner.dart:212:13)
<asynchronous suspension>
#14     FlutterCommandRunner.runCommand.<anonymous closure> (package:flutter_tools/src/runner/flutter_command_runner.dart:496:9)
<asynchronous suspension>
#15     AppContext.run.<anonymous closure> (package:flutter_tools/src/base/context.dart:154:19)
<asynchronous suspension>
#16     FlutterCommandRunner.runCommand (package:flutter_tools/src/runner/flutter_command_runner.dart:431:5)
<asynchronous suspension>
#17     run.<anonymous closure>.<anonymous closure> (package:flutter_tools/runner.dart:98:11)
<asynchronous suspension>
#18     AppContext.run.<anonymous closure> (package:flutter_tools/src/base/context.dart:154:19)
<asynchronous suspension>
#19     main (package:flutter_tools/executable.dart:99:3)
<asynchronous suspension>

Compiling lib/main.dart for the Web...                              9.0s
Error: Failed to compile application for the Web.
Error: Process completed with exit code 1.

以上

その他修正してほしい部分があります
・現在在庫追加できる機能がありますが追加ボタンを押しても反映されません

ルール
・デプロイ可能か必ず確かめる
・バグやエラーがないか確かめる
