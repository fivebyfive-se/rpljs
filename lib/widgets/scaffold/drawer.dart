import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:rpljs/config/constants.dart';

import 'package:rpljs/helpers/text-style-helpers.dart';

import 'package:rpljs/views/base/page-arguments.dart';
import 'package:rpljs/views/settings-page.dart';
import 'package:rpljs/widgets/rpljs-logo.dart';
import 'package:rpljs/widgets/txt.dart';

Drawer scaffoldDrawer<T extends PageArguments>(
  BuildContext context,
  T arguments
) { 
  return Drawer(
    child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Constants.theme.background,
                  Constants.theme.secondaryAccent
                ],
              ),
              image: DecorationImage(
                image: rpljsLogoProvider(),
                alignment: Alignment.center,
                fit: BoxFit.scaleDown,
                scale: 0.5
              )                    
            ),
            child: Text(''),
          ),
          drawerSubheadingTile(title: "Rpljs", icon: Icons.code),
          drawerNavLinkTile(
            title: "Settings",
            subtitle: "Configure JavaScript settings",
            icon: Icons.settings_applications,
            isActive: SettingsPage.route.isActive(context),
            onTap: () => SettingsPage.route.navigateTo(context: context)
          ),
          Divider(height: 48.0),
          drawerSubheadingTile(
            title: "Links",
            icon: LineAwesomeIcons.alternate_external_link,
            color: Constants.theme.secondaryAccent
          ),
          drawerUrlLinkTile(
            icon: LineAwesomeIcons.github,
            title: "Source code",
            subtitle: "github.com/fivebyfive-se/rpljs",
            url: "https://github.com/fivebyfive-se/rpljs"
          ),
        ],
      ),
  );
}


void launchUrl(String url) async {
  try {
    await launch(url);
  } catch(e) {
    print("Couldn't launch $url");
    print(e.toString());
  }
}

Widget drawerUrlLinkTile({
  IconData icon,
  String title,
  String subtitle,
  String url
}) => drawerLinkTile(icon: icon, title: title, subtitle: subtitle,
    onTap: () => launchUrl(url),
  );

Widget drawerNavLinkTile({
  IconData icon,
  String title,
  String subtitle,
  bool isActive,
  Function() onTap
}) => drawerLinkTile(
  icon: icon, title: title, subtitle: subtitle,
  color: isActive 
    ? Constants.theme.primaryAccent
    : Constants.theme.foreground,
  onTap: onTap
);

Widget drawerLinkTile({
  IconData icon,
  String title,
  String subtitle,
  Function() onTap,
  Color iconColor,
  Color color
}) => ListTile(
    leading: Icon(icon, size: Constants.iconSizeXLarge, color: iconColor ?? color),
    title: Txt.h2(title, style: textColor(color)),
    subtitle: subtitle == null  ? null 
      : Txt.light(subtitle, style: textColor(color)),
    onTap: onTap
  );


Widget drawerSubheadingTile({String title, String subtitle, IconData icon, Color color}) {
  return ListTile(
    trailing: icon == null ? null
      : Icon(icon, size: Constants.iconSizeLarge, color: color ?? Constants.theme.primaryAccent),
    title: Txt.h1(title, style: textColor(color ?? Constants.theme.primaryAccent)),
    subtitle: subtitle == null ? null 
      : Txt.light(subtitle),
  );
}