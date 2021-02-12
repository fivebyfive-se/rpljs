import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

import 'package:rpljs/config/constants.dart';

import 'package:rpljs/helpers/index.dart';

import 'package:rpljs/services/app-state.dart';
import 'package:rpljs/services/jse-service.dart';

import 'package:rpljs/views/base/index.dart';

import 'package:rpljs/widgets/builders/app-state-builder.dart';
import 'package:rpljs/widgets/builders/confirm-dialog-builder.dart';
import 'package:rpljs/widgets/scaffold/page.dart';
import 'package:rpljs/widgets/snacky.dart';
import 'package:rpljs/widgets/txt.dart';

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
  BoxDecoration get _gradientBox => BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Constants.theme.background, Colors.transparent]
    )
  );

  Widget _sectionTitle(String title, {IconData icon}) 
    => SizedBox(
        height: size(6.5),
        child: 
          Card(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                icon == null 
                  ? spex(2) 
                  : flexp(2,
                      Icon(icon, color: Constants.theme.secondaryAccent)
                    ),
                flexp(10,
                  Txt.h1(
                    title,
                    style: textColor(Constants.theme.secondaryAccent)
                  )
                )
              ],
          )
        ),
    );

  Map<String,bool> _editing = <String,bool>{};
  
  bool _isEditing(String id)
    => _editing.containsKey(id) ? _editing[id] : false;

  void _toggleEdit(String id, {bool force}) {
    if (force != null) {
      _editing[id] = force;
    } else {
      if (_editing.containsKey(id)) {
        _editing[id] = !_editing[id];
      } else {
        _editing[id] = true;
      }
    }
    setState(() {});
  }

  TextEditingController _controller(String value)
    => TextEditingController.fromValue(
      TextEditingValue(text: value)
    );

  Widget _editSnippet(SnippetModel snippet, {
    bool overrideEditing,
    SnippetCallback onSave,
    SnippetCallback onDelete
  }) {
    final override = (overrideEditing ?? false) && !_editing.containsKey(snippet.uuid);
    final isEditing = override || _isEditing(snippet.uuid);
    final labCtrl = _controller(snippet.label);
    final cntCtrl = _controller(snippet.content);

    final btn = (String label, {IconData icon, Color color, Function() onPressed})
      => btnLabelIcon(
          icon: icon,
          backgroundColor: color ?? Constants.theme.primaryAccent,
          label: label,
          onPressed: onPressed,
        );

    return Column(children:[
      ListTile(
        title: isEditing ? TextField(
              controller: labCtrl,
              style: textStyleHeading()
            ) : Txt.strong(snippet.label),
        subtitle: isEditing ?  TextField(
              controller: cntCtrl,
              maxLines: 2,
              style: textStyleCode()
            ) : Txt.code(snippet.content),
        onTap: isEditing ? null : () => _toggleEdit(snippet.uuid)
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
          children: isEditing ? [
            btn("Save", icon: LineAwesomeIcons.save, onPressed: () {
              snippet.label = labCtrl.text;
              snippet.content = cntCtrl.text;
              onSave?.call(snippet);
              _toggleEdit(snippet.uuid, force: false);
            }),
            btn("Cancel",
              icon: LineAwesomeIcons.times_circle,
              color: Constants.theme.secondaryAccent,
              onPressed: () => _toggleEdit(snippet.uuid, force: false)
            ),
          ] : [
            btn("Autorun",
              color: snippet.runOnInit 
                ? Constants.theme.secondaryAccent
                : Constants.theme.cardBackground,
              icon: snippet.runOnInit
                ? LineAwesomeIcons.toggle_on
                : LineAwesomeIcons.toggle_off,
              onPressed: () {
                snippet.runOnInit = !snippet.runOnInit;
                onSave?.call(snippet);
              }
            ),
            btn("Delete", 
              color: Constants.theme.error,
              icon: LineAwesomeIcons.backspace, 
              onPressed: () => onDelete?.call(snippet)
            )
          ]
        )
    ]);
  }

  @override
  void initState() {
    super.initState();
    _editing = <String,bool>{};
  }

  @override
  Widget build(BuildContext rootContext) {
    final pageArgs = ModalRoute.of(rootContext).settings.arguments as SettingsPageArguments;
    final editItem = pageArgs?.editItem ?? "";
    final snacky = Snacky.of(rootContext);
    final size = MediaQuery.of(context).size;

    return AppStateBuilder(
      builder: (context, appState, provider) => scaffoldPage(
        drawer: false,
        context: context,
        builder: (context, arguments) {
          final _saveConfig = () {
            provider.updateConfig(appState.config);
            setState(() {});
          };
          final _setVerbosity = (JseVerbosity v) {
            appState.config.verbosity = v;
            _saveConfig();
          };

          return ListView(children: [
              _sectionTitle("Settings", icon: LineAwesomeIcons.horizontal_sliders),
              CheckboxListTile(
                value: appState.config.hideSuggestions,
                onChanged: (v) {
                  appState.config.hideSuggestions = v;
                  _saveConfig();
                },
                title: Txt.p("Hide suggestions", style: textStyleHeading()),
                subtitle: Txt.p(
                  "Don't show a list of suggestions above code input",
                  style: textStyleBody().copyWith(fontSize: Constants.fontSizeSmall)
                ),
                controlAffinity: ListTileControlAffinity.trailing,
                dense: true,
              ),
              ListTile(
                title: Txt.p("Engine verbosity", style: textStyleHeading()),
                trailing: DropdownButton<JseVerbosity>(
                  items: [
                    ...JseVerbosity.values.map((v) => DropdownMenuItem(
                      child: Txt.p(v.toString().replaceFirst("JseVerbosity.", "")),
                      value: v
                    ))
                  ],
                  value: appState.config.verbosity,
                  onChanged: _setVerbosity,
                  isDense: true,
                )
              ),
              _sectionTitle("Snippets", icon: LineAwesomeIcons.javascript__js_),
              
              ...appState.snippets.map((snippet) 
                => _editSnippet(
                      snippet,
                      overrideEditing: editItem == snippet.uuid,
                      onSave: (sn) {
                        provider.editSnippet(sn);
                        snacky.showInfo("Snippet saved.");
                      },
                      onDelete: (sn) => showDialog(
                        context: context,
                        builder: confirmDialogBuilder(
                          title: "Delete snippet?",
                          textLines: [
                            "Are you sure you want to delete ",
                            "the snippet labeled '${sn.label}'?"
                          ],
                          onConfirm: () => provider.deleteSnippet(sn),
                          onCancel: () => null
                        )
                      )
                  )
              ).toList(),
              btnLabelIcon(
                icon: LineAwesomeIcons.plus_circle,
                backgroundColor: Constants.theme.primaryAccent,
                label: "New snippet...",
                onPressed: () => provider.addSnippet(),
              ),
              Divider(),
              _sectionTitle("Input history", icon: LineAwesomeIcons.terminal),
              ...appState.history.map((h) => ListTile(
                      title: Txt.p(h.content, style: textStyleCode()),
                      subtitle: Txt.p(
                        h.timestamp.toIso8601String(),
                        style: textStyleBody().copyWith(
                          fontSize: Constants.fontSizeSmall
                        )),
                      trailing: btnIcon(
                        icon: LineAwesomeIcons.backspace,
                        onPressed: () {
                          final copy = h.clone();
                          provider.deleteHistory(h);
                          snacky.showAction(
                            "History item deleted.",
                            actionLabel: "Undo",
                            onAction: () {
                              provider.editHistory(copy);
                              setState((){});
                            }
                          );
                        },
                      ),
                    ))
                ],
              );
      })
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