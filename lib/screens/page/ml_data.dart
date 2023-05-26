import 'package:flutter/material.dart';
import 'package:tuchati/constants/app_colors.dart';
import 'package:tuchati/services/collectmsgs.dart';

class MachineLearning extends StatefulWidget {
  const MachineLearning({super.key});

  @override
  State<MachineLearning> createState() => _MachineLearningState();
}

class _MachineLearningState extends State<MachineLearning> {
  Stream<List> _machineData() async* {
    yield* Stream.fromFuture(CollectMessageData().getMachineLearningData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("machine data"),
        backgroundColor: AppColors.appColor,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _machineData(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                       return ListTile(
                        title: Text(snapshot.data![index]["_fieldsProto"]["msg"]['stringValue'].toString()),
                        subtitle: Text(snapshot.data![index]["_fieldsProto"]["created"]['stringValue'].toString()),
                       );
                  },);
                } else if (snapshot.connectionState == ConnectionState.active ||
                    snapshot.connectionState == ConnectionState.done) {
                  return const Text("connection is active can be done any time");
                } else if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: Text("waiting for connection............"));
                } else {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppColors.appColor,
                      strokeWidth: 3,
                    ),
                  );
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
