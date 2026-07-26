// import 'package:flutter/material.dart';
// import 'package:flutter_practice/features/posts/post_card.dart';
// import 'package:flutter_practice/features/posts/image_preview_row.dart';
// import 'package:flutter_practice/features/posts/comment_section.dart';
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatefulWidget {
//   const MyApp({super.key});
//
//   @override
//   State<MyApp> createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//   // This should mimic file i/o uploads
//   List<String> images = [
//     'https://picsum.photos/id/10/200/200',
//     'https://picsum.photos/id/20/200/200',
//     'https://picsum.photos/id/30/200/200',
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: Scaffold(
//           appBar: AppBar(
//             title: const Text("Forum Feed"),
//             // backgroundColor: Colors.blueAccent
//           ),
//           body: SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Sample PostCard widgets
//                 // I guess we are calling the constructor here
//                 // This Single implementation of the PostCard is meant for when
//                 // you've clicked on a post and are viewing the comments
//                 const PostCard(
//                   postTitle: "How To Learn Flutter",
//                   postAuthor: "Mikel",
//                   postPreviewContent: "This is how you Learn Flutter...",
//                   postCommentCount: 13,
//                 ),
//                 // These additional PostCards are meant for the actual forum feed
//                 // where there are multiple posts
//                 // const PostCard(
//                 //   postTitle: "The Unknown Felines",
//                 //   postAuthor: "Cat Monster",
//                 //   postPreviewContent: "When I first learned about...",
//                 //   postCommentCount: 2342,
//                 // ),
//                 // const PostCard(
//                 //   postTitle: "Debunking Aliens",
//                 //   postAuthor: "Unc",
//                 //   postPreviewContent: "YOU WON'T BELIEVE WHAT I...",
//                 //   postCommentCount: 200,
//                 // ),
//
//                 // Spacer
//                 const SizedBox(height: 12),
//
//                 ImagePreviewRow(
//                   imageUrls: images,
//                   // As per the image_preview_row, we created a callback function
//                   // that takes in index as a parameter
//                   onDelete: (index) {
//                     setState(() {
//                       images.removeAt(index);
//                     });
//                   },
//                 ),
//
//                 const Divider(height: 32),
//
//                 const CommentSection(),
//               ],
//             ),
//           )),
//     );
//   }
//
// //   // This widget is the root of your application.
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       title: 'Flutter Demo',
// //       theme: ThemeData(
// //         // This is the theme of your application.
// //         //
// //         // TRY THIS: Try running your application with "flutter run". You'll see
// //         // the application has a purple toolbar. Then, without quitting the app,
// //         // try changing the seedColor in the colorScheme below to Colors.green
// //         // and then invoke "hot reload" (save your changes or press the "hot
// //         // reload" button in a Flutter-supported IDE, or press "r" if you used
// //         // the command line to start the app).
// //         //
// //         // Notice that the counter didn't reset back to zero; the application
// //         // state is not lost during the reload. To reset the state, use hot
// //         // restart instead.
// //         //
// //         // This works for code too, not just values: Most code changes can be
// //         // tested with just a hot reload.
// //         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
// //         useMaterial3: true,
// //       ),
// //       home: const MyHomePage(title: 'Flutter Demo Home Page'),
// //     );
// //   }
// // }
// //
// // class MyHomePage extends StatefulWidget {
// //   const MyHomePage({super.key, required this.title});
// //
// //   // This widget is the home page of your application. It is stateful, meaning
// //   // that it has a State object (defined below) that contains fields that affect
// //   // how it looks.
// //
// //   // This class is the configuration for the state. It holds the values (in this
// //   // case the title) provided by the parent (in this case the App widget) and
// //   // used by the build method of the State. Fields in a Widget subclass are
// //   // always marked "final".
// //
// //   final String title;
// //
// //   @override
// //   State<MyHomePage> createState() => _MyHomePageState();
// // }
// //
// // class _MyHomePageState extends State<MyHomePage> {
// //   int _counter = 0;
// //
// //   void _incrementCounter() {
// //     setState(() {
// //       // This call to setState tells the Flutter framework that something has
// //       // changed in this State, which causes it to rerun the build method below
// //       // so that the display can reflect the updated values. If we changed
// //       // _counter without calling setState(), then the build method would not be
// //       // called again, and so nothing would appear to happen.
// //       _counter++;
// //     });
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     // This method is rerun every time setState is called, for instance as done
// //     // by the _incrementCounter method above.
// //     //
// //     // The Flutter framework has been optimized to make rerunning build methods
// //     // fast, so that you can just rebuild anything that needs updating rather
// //     // than having to individually change instances of widgets.
// //     return Scaffold(
// //       appBar: AppBar(
// //         // TRY THIS: Try changing the color here to a specific color (to
// //         // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
// //         // change color while the other colors stay the same.
// //         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
// //         // Here we take the value from the MyHomePage object that was created by
// //         // the App.build method, and use it to set our appbar title.
// //         title: Text(widget.title),
// //       ),
// //       body: Center(
// //         // Center is a layout widget. It takes a single child and positions it
// //         // in the middle of the parent.
// //         child: Column(
// //           // Column is also a layout widget. It takes a list of children and
// //           // arranges them vertically. By default, it sizes itself to fit its
// //           // children horizontally, and tries to be as tall as its parent.
// //           //
// //           // Column has various properties to control how it sizes itself and
// //           // how it positions its children. Here we use mainAxisAlignment to
// //           // center the children vertically; the main axis here is the vertical
// //           // axis because Columns are vertical (the cross axis would be
// //           // horizontal).
// //           //
// //           // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
// //           // action in the IDE, or press "p" in the console), to see the
// //           // wireframe for each widget.
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: <Widget>[
// //             const Text(
// //               'You have pushed the button this many times:',
// //             ),
// //             Text(
// //               '$_counter',
// //               style: Theme.of(context).textTheme.headlineMedium,
// //             ),
// //           ],
// //         ),
// //       ),
// //       floatingActionButton: FloatingActionButton(
// //         onPressed: _incrementCounter,
// //         tooltip: 'Increment',
// //         child: const Icon(Icons.add),
// //       ), // This trailing comma makes auto-formatting nicer for build methods.
// //     );
// //   }
// }
