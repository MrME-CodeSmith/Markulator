import 'package:flutter/material.dart';
import 'package:markulator/models/module_model.dart';
import 'package:markulator/views/widgets/weight_percentage_input.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/module_repository.dart';
import '../../data/services/system_information_service.dart';
import './padded_list_heading_widget.dart';
import 'percentage_input_widget.dart';

class ContributorCreationUserInputWidget extends StatefulWidget {
  const ContributorCreationUserInputWidget({
    super.key,
    required this.screenHeight,
    required this.screenWidth,
    required this.parent,
    required this.toEdit,
  });

  final double screenHeight;
  final double screenWidth;
  final MarkItem? parent;
  final MarkItem? toEdit;

  @override
  State<ContributorCreationUserInputWidget> createState() =>
      _ContributorCreationUserInputWidgetState();
}

class _ContributorCreationUserInputWidgetState
    extends State<ContributorCreationUserInputWidget> {
  late final TextEditingController _nameController;
  late final TextEditingController _wightController;
  late final TextEditingController _percentageController;
  late bool _checked;

  late ModuleRepository moduleProvider;
  late SystemInformationService systemInformationProvider;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: (widget.toEdit != null) ? widget.toEdit!.name : "",
    );

    _wightController = TextEditingController(
      text: (widget.toEdit != null)
          ? ((widget.toEdit!.weight * 100).toStringAsFixed(2))
          : "",
    );

    _percentageController = TextEditingController(
      text: (widget.toEdit != null)
          ? ((widget.toEdit!.mark * 100).toStringAsFixed(2))
          : "",
    );

    _checked = (widget.toEdit != null) ? widget.toEdit!.autoWeight : false;
  }

  @override
  void didChangeDependencies() {
    moduleProvider = Provider.of<ModuleRepository>(context);
    systemInformationProvider = Provider.of<SystemInformationService>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: (MediaQuery.of(context).viewInsets.bottom > 0)
              ? MediaQuery.of(context).viewInsets.bottom + 150
              : ((widget.toEdit != null &&
                        widget.toEdit!.contributors.isNotEmpty)
                    ? 250
                    : 300),
          maxWidth: double.infinity,
          minHeight: 50,
          minWidth: double.infinity,
        ),
        child: ListView(
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              child: (widget.toEdit == null)
                  ? const PaddedListHeadingWidget(
                      headingName: "Add mark contributor",
                    )
                  : const PaddedListHeadingWidget(
                      headingName: "Update mark contributor",
                    ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: widget.screenWidth * 0.1,
              ),
              child: Divider(
                color: Theme.of(context).colorScheme.secondary,
                thickness: 1.5,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Contributor name',
                  contentPadding: EdgeInsets.only(left: 7),
                  hintText: "Super cool module 01",
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: WeightPercentageInputWidget(
                percentageController: _wightController,
                value: _checked,
                onChanged: (val) {
                  setState(() {
                    _checked = val;
                  });
                },
              ),
            ),
            if (widget.toEdit == null ||
                (widget.toEdit != null && widget.toEdit!.contributors.isEmpty))
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: SizedBox(
                      width: widget.screenWidth * 0.5,
                      child: PercentageInputWidget(
                        label: "Mark",
                        readOnly: false,
                        percentageController: _percentageController,
                      ),
                    ),
                  ),
                ],
              ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                widget.screenWidth * 0.15,
                21,
                widget.screenWidth * 0.15,
                7,
              ),
              child: SizedBox(
                width: widget.screenWidth,
                child: ElevatedButton(
                  style: ButtonStyle(
                    alignment: Alignment.center,
                    padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
                    ),
                  ),
                  onPressed: () {
                    if (widget.toEdit == null) {
                      moduleProvider.addContributor(
                        parent: widget.parent!,
                        contributorName: _nameController.text,
                        weight:
                            (double.tryParse(_wightController.text) != null &&
                                !_checked)
                            ? double.parse(_wightController.text)
                            : 0,
                        mark:
                            (double.tryParse(_percentageController.text) !=
                                null)
                            ? double.parse(_percentageController.text)
                            : 0,
                        autoWeight: _checked,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Contributor added',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      );
                    } else {
                      moduleProvider.updateContributor(
                        key: widget.toEdit!.key,
                        contributorName: _nameController.text,
                        weight:
                            (double.tryParse(_wightController.text) != null &&
                                !_checked)
                            ? double.parse(_wightController.text)
                            : 0,
                        mark:
                            (double.tryParse(_percentageController.text) !=
                                null)
                            ? double.parse(_percentageController.text)
                            : 0,
                        autoWeight: _checked,
                        parent: widget.toEdit!.parent!,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Contributor updated',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      );
                    }

                    Navigator.of(context).pop();
                  },
                  child: (widget.toEdit == null)
                      ? Text(
                          "Add",
                          style: Theme.of(context).textTheme.bodyMedium,
                        )
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
      ),
    );
  }
}
