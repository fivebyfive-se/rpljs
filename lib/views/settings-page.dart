import 'dart:html';

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
    => flexp(2,Container(
        decoration: _gradientBox,
        child: 
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,

            children: [
              icon == null 
                ? spex(1) 
                : flexp(1,
                    Icon(icon, color: Constants.theme.secondaryAccent)
                  ),
              flexp(10,
                Txt.h1(
                  title,
                  style: textColor(Constants.theme.secondaryAccent)
                )
              )
            ],
          ),
    ));

  Widget _sectionList({
    List<Widget> children,
    int flex = 6,
    EdgeInsetsGeometry padding = EdgeInsets.zero
  })
    => flexp(flex, ListView(children: children, padding: padding));

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
      => flexp(1,
          btnLabelIcon(
            icon: icon,
            backgroundColor: color ?? Constants.theme.primaryAccent,
            label: label,
            onPressed: onPressed,
          )
        );

    return Container(
      height: 130,
      decoration: BoxDecoration(
        border: BorderDirectional(
          bottom: BorderSide(color: Constants.theme.varBackground)
        )
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          flexp(1,
            btnIcon(
              icon: snippet.runOnInit 
                ? LineAwesomeIcons.toggle_on 
                : LineAwesomeIcons.toggle_off,
              onPressed: () {
                snippet.runOnInit = !snippet.runOnInit;
                onSave?.call(snippet);
              },
              color: snippet.runOnInit 
                ? Constants.theme.primaryAccent
                : Constants.theme.foreground
            )
          ),
          flexp(9,
          isEditing ? Column(
            children: [
              flexp(1,
                TextField(
                  controller: labCtrl,
                  style: textStyleHeading()
                )
              ),
              flexp(2,
                TextField(
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
          flexp(2,
            isEditing ? Column(
              children: [
                btn("Save", icon: LineAwesomeIcons.save, onPressed: () {
                  snippet.label = labCtrl.text;
                  snippet.content = cntCtrl.text;
                  onSave?.call(snippet);
                  _toggleEdit(snippet.uuid, force: false);
                }),
                spex(1),
                btn("Cancel",
                  icon: LineAwesomeIcons.times_circle,
                  color: Constants.theme.secondaryAccent,
                  onPressed: () => _toggleEdit(snippet.uuid, force: false)
                ),
                spex(1),
              ],
            ) : Column(
              children: [
                spex(1),
                btn("Delete", 
                  color: Constants.theme.error,
                  icon: LineAwesomeIcons.backspace, 
                  onPressed: () => onDelete?.call(snippet)
                ),
                spex(2)
              ],
            )
          ) 
        ],
      ),
    );
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

          return Column(children: [
              _sectionTitle("Settings", 
                icon: LineAwesomeIcons.horizontal_sliders
              ),
              flexp(7,
              Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  flexp(6,
                    CheckboxListTile(
                      value: appState.config.hideSuggestions,
                      onChanged: (v) {
                        appState.config.hideSuggestions = v;
                        _saveConfig();
                      },
                      title: Txt.p("Hide suggestions", style: textStyleHeading()),
                      subtitle: Txt.p("Don't show a list of suggestions above code input"),
                      controlAffinity: ListTileControlAffinity.leading,
                    )
                  ),
                  flexp(6,
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      flexp(2,
                        ListTile(
                          title: Txt.h2("Verobsity"),
                          subtitle: Txt.p("How much info to output from JavaScript engine"),
                        )
                      ),
                      flexp(2,
                        ListTile(
                          leading: Icon(
                            appState.config.verbosity == JseVerbosity.quiet
                              ? LineAwesomeIcons.comment_slash
                              : appState.config.verbosity == JseVerbosity.verbose 
                                ? LineAwesomeIcons.comment
                                : LineAwesomeIcons.alternate_comment
                          ),

                          title: DropdownButton<JseVerbosity>(
                            items: [
                              ...JseVerbosity.values.map((v) => DropdownMenuItem(
                                child: Txt.p(v.toString().replaceFirst("JseVerbosity.", "")),
                                value: v
                              ))
                            ],
                            value: appState.config.verbosity,
                            onChanged: _setVerbosity,
                          )
                        )
                      ),
                      spex(1)
                    ]),
                  ),
                  spex(1)
                ],
              )),
              _sectionTitle("Snippets", icon: LineAwesomeIcons.javascript__js_),
              _sectionList(
                flex: 10,
                children: <Widget>[
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
                  ).toList()
                ]
              ),
              flexp(1,
                Center(
                  child: btnLabelIcon(
                    icon: LineAwesomeIcons.plus_circle,
                    backgroundColor: Constants.theme.primaryAccent,
                    label: "New snippet...",
                    onPressed: () => provider.addSnippet(),
                  )
                )
              ),
            Divider(),
              _sectionTitle("Input history",
                icon: LineAwesomeIcons.terminal),
              _sectionList(
                flex: 5,
                children: <Widget>[
                  ...appState.history.map((h) {
                    return ListTile(
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
                    );
                  })
                ],
              ),

        ]);
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