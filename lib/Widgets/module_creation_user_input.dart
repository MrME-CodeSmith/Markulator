import 'package:flutter/material.dart';
import 'package:markulator/Model/module_model.dart';
import 'package:markulator/Providers/system_information_provider.dart';
import 'package:provider/provider.dart';

import '../Providers/module_provider.dart';
import './padded_list_heading_widget.dart';
import './percentage_input_widget.dart';

class ModuleCreationUserInputWidget extends StatefulWidget {
  const ModuleCreationUserInputWidget({super.key, required this.toEdit});

  final MarkItem? toEdit;

  @override
  State<ModuleCreationUserInputWidget> createState() =>
      _ModuleCreationUserInputWidgetState();
}

class _ModuleCreationUserInputWidgetState
    extends State<ModuleCreationUserInputWidget> {
  late final TextEditingController _nameController;
  late final TextEditingController _percentageController;
  late final TextEditingController _creditsController;

  late ModuleProvider moduleProvider;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: (widget.toEdit == null) ? "" : widget.toEdit!.name,
    );

    _percentageController = TextEditingController(
      text: (widget.toEdit == null)
          ? ""
          : (widget.toEdit!.mark * 100).toStringAsFixed(2),
    );

    _creditsController = TextEditingController(
      text: (widget.toEdit == null) ? "" : widget.toEdit!.credits.toString(),
    );
  }

  @override
  void didChangeDependencies() {
    moduleProvider = Provider.of<ModuleProvider>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: getHeight(context),
        maxWidth: double.infinity,
        minHeight: 50,
        minWidth: double.infinity,
      ),
      child: ListView(
        children: [
          ModuleCreationHeadingWidget(toEdit: widget.toEdit),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Provider.of<SystemInformationProvider>(
                    context,
                  ).systemInfo.screenWidth *
                  0.25,
            ),
            child: Divider(
              color: Theme.of(context).colorScheme.secondary,
              thickness: 1.5,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 0.0),
            child: TextField(
              key: const Key("MN"),
              controller: _nameController,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Module name',
                hintText: 'e.g. Calculus',
                contentPadding: EdgeInsets.only(left: 7),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 7, 30, 0),
            child: TextField(
              key: const Key("MC"),
              controller: _creditsController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Credits',
                contentPadding: EdgeInsets.only(left: 7),
              ),
            ),
          ),
          if (widget.toEdit == null ||
              (widget.toEdit != null && widget.toEdit!.contributors.isEmpty))
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 7, 0, 0),
              child: LayoutBuilder(
                builder: ((context, constraints) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: constraints.maxWidth * 0.4,
                        child: PercentageInputWidget(
                          key: const Key("MI"),
                          label: "Mark",
                          readOnly: false,
                          percentageController: _percentageController,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              screenWidth * 0.25,
              21,
              screenWidth * 0.25,
              7,
            ),
            child: SizedBox(
              width: screenWidth,
              child: ElevatedButton(
                style: ButtonStyle(
                  alignment: Alignment.center,
                  padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
                  ),
                ),
                onPressed: () {
                  if (widget.toEdit == null) {
                    moduleProvider.addModule(
                      name: _nameController.text,
                      mark:
                          (double.tryParse(_percentageController.text) != null)
                              ? double.parse(_percentageController.text)
                              : 0,
                      contributors: null,
                      credits:
                          (double.tryParse(_creditsController.text) != null)
                              ? double.parse(_creditsController.text)
                              : 0,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Module added',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    );
                  } else {
                    moduleProvider.updateModule(
                      id: widget.toEdit!.key,
                      name: _nameController.text,
                      mark:
                          (double.tryParse(_percentageController.text) != null)
                              ? double.parse(_percentageController.text)
                              : 0,
                      credits:
                          (double.tryParse(_creditsController.text) != null)
                              ? double.parse(_creditsController.text)
                              : widget.toEdit!.credits,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Module updated',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    );
                  }

                  Navigator.of(context).pop();
                },
                child: widget.toEdit == null
                    ? Text("Add", style: Theme.of(context).textTheme.bodyMedium)
                    : Text(
                        "Update",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
          ),
        ],
      ),
    );
  }

  double getHeight(BuildContext context) {
    double toReturn = MediaQuery.of(context).viewInsets.bottom;
    bool isVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    if (isVisible) {
      if (widget.toEdit != null && widget.toEdit!.contributors.isNotEmpty) {
        toReturn += 150;
      } else if (widget.toEdit != null && widget.toEdit!.contributors.isEmpty) {
        toReturn += 150;
      } else {
        toReturn += 150;
      }
    } else {
      if (widget.toEdit != null && widget.toEdit!.contributors.isNotEmpty) {
        toReturn += 200;
      } else {
        toReturn += 260;
      }
    }
    return toReturn;
  }
}

class ModuleCreationHeadingWidget extends StatelessWidget {
  const ModuleCreationHeadingWidget({super.key, required this.toEdit});

  final MarkItem? toEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: (toEdit == null)
          ? const PaddedListHeadingWidget(headingName: "Add module")
          : const PaddedListHeadingWidget(headingName: "Update module"),
    );
  }
}
