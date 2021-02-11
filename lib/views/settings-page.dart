import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:rpljs/config/constants.dart';
import 'package:rpljs/state/models/snippet-model.dart';
import 'package:rpljs/theme/text-style-helpers.dart';

import 'package:rpljs/views/base/page-arguments.dart';
import 'package:rpljs/views/base/page-base.dart';
import 'package:rpljs/views/base/page-navigator.dart';
import 'package:rpljs/widgets/builders/app-state-builder.dart';
import 'package:rpljs/widgets/builders/confirm-dialog-builder.dart';
import 'package:rpljs/widgets/buttons.dart';
import 'package:rpljs/widgets/scaffold/page.dart';
import 'package:rpljs/widgets/text-elements.dart';

typedef SnippetCallback = void Function(SnippetModel);

class SettingsPage extends PageBase<SettingsPageArguments> {
  SettingsPage() : super(showDrawer: false);

  static const String title = 'Settings';
  static const String routeName = '/settings';
  static SettingsPageNavigator get route => SettingsPageNavigator();

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Widget _sectionTitle(String title, {IconData icon}) 
    => Expanded(
      flex: 1,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          icon == null 
            ? Spacer(flex: 2) 
            : Expanded(flex: 2, 
                child: Icon(icon, color: Constants.theme.secondaryAccent)
              ),
          Expanded(flex: 10,
            child: Txt.h1(title,
              style: TextStyle(
                color: Constants.theme.secondaryAccent)
              )
          )
        ],
      ),
    );

  Widget _sectionList({List<Widget> children, int flex = 6})
    => Expanded(
      flex: flex,
      child: ListView(
        children: children,
      )
    );

  final Map<String,bool> _editing = <String,bool>{};
  
  bool _isEditing(String id)
    => _editing.containsKey(id) ? _editing[id] : false;

  void _toggleEdit(String id) {
    if (_editing.containsKey(id)) {
      _editing[id] = !_editing[id];
    } else {
      _editing[id] = true;
    }
    setState(() {});
  }

  TextEditingController _controller(String value)
    => TextEditingController.fromValue(
      TextEditingValue(text: value)
    );

  Widget _editSnippet(SnippetModel snippet, {
    SnippetCallback onSave,
    SnippetCallback onDelete
  }) {
    final isEditing = _isEditing(snippet.uuid);
    final labCtrl = _controller(snippet.label);
    final cntCtrl = _controller(snippet.content);

    final btn = (String label, {IconData icon, Color color, Function() onPressed})
      => Expanded(flex: 1,
        child: btnLabelIcon(
          icon: icon,
          backgroundColor: color ?? Constants.theme.primaryAccent,
          label: label,
          onPressed: onPressed,
        )
      );

    return Container(
      height: 130,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 1,
            child: btnIcon(
              icon: snippet.runOnInit ? Icons.favorite : Icons.favorite_border,
              onPressed: () {
                snippet.runOnInit = !snippet.runOnInit;
                setState((){});
              },
            )
          ),
          Expanded(flex: 8,
          child: isEditing ? Column(
            children: [
              Expanded(flex: 1,
                child: TextField(
                  controller: labCtrl,
                  style: textStyleHeading()
                )
              ),
              Expanded(flex: 2,
                child: TextField(
                  controller: cntCtrl,
                  maxLines: 2,
                  style: textStyleCode()
                )
              ),
            ],
            ) : ListTile(
                title: Txt.strong(snippet.label),
                subtitle: Txt.code(snippet.content),
                onTap: () => _toggleEdit(snippet.uuid)
              )
          ),
          Expanded(flex: 2,
            child: isEditing ? Column(
              children: [
                btn("Save", icon: Icons.save, onPressed: () {
                  snippet.label = labCtrl.text;
                  snippet.content = cntCtrl.text;
                  onSave?.call(snippet);
                  _toggleEdit(snippet.uuid);
                }),
                Spacer(flex: 1),
                btn("Cancel",
                  icon: Icons.cancel,
                  color: Constants.theme.secondaryAccent,
                  onPressed: () => _toggleEdit(snippet.uuid)
                ),
              ],
            ) : Column(
              children: [
                Spacer(flex: 2),
                btn("Delete", 
                  color: Constants.theme.error,
                  icon: Icons.delete_forever, 
                  onPressed: () => onDelete?.call(snippet)
                ),
              ],
            )
          ) 
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext rootContext) {
    return AppStateBuilder(
      builder: (context, appState, provider) => scaffoldPage(
        drawer: false,
        context: context,
        builder: (context, arguments) 
          => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle("Snippets", icon: LineAwesomeIcons.javascript__js_),
              _sectionList(
                flex: 8,
                children: <Widget>[
                  ...appState.snippets.map((snippet) 
                    => _editSnippet(
                          snippet,
                          onSave: (sn) => provider.editSnippet(sn),
                          onDelete: (sn) => showDialog(
                            context: context,
                            builder: confirmDialogBuilder(
                              title: "Delete snippet?",
                              textLines: [
                                "Are you sure you want to delete ",
                                "the snippet labeled '${sn.label}'?"
                              ],
                              onConfirm: () => provider.deleteSnippet(sn),
                              onCancel: () => print(sn)
                            )
                          )
                      )
                  ).toList()
                ]
              ),
              Expanded(flex: 1,
                child: Center(
                  child: RaisedButton.icon(
                    icon: Icon(Icons.add),
                    color: Constants.theme.primaryAccent,
                    label: Text("New snippet..."),
                    onPressed: () => provider.addSnippet(),
                  )
                )
              ),
              Divider(),
              _sectionTitle("Input history", icon: Icons.history),
              _sectionList(
                children: <Widget>[
                  ...appState.history.map((h) {
                    return ListTile(
                      title: Text(h.content, style: textStyleCode()),
                      subtitle: Text(
                        h.timestamp.toIso8601String(),
                        style: textStyleBody()
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete_forever),
                        onPressed: () => provider.deleteHistory(h),
                      ),
                    );
                  })
                ],
              ),
            ],
          )
      )
    );
  }
}

class SettingsPageNavigator extends
                            PageNavigator<SettingsPage,SettingsPageArguments> {
    SettingsPageNavigator()
    : super(routeName: SettingsPage.routeName);
}


class SettingsPageArguments extends PageArguments {
  SettingsPageArguments({this.editItem})
    : super(routeName: SettingsPage.routeName);

  final String editItem;
}