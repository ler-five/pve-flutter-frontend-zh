import 'package:url_launcher/url_launcher.dart';

Future<bool> tryLaunchUrl(Uri url) async {
  if (await canLaunchUrl(url)) {
    return await launchUrl(url);
  } else {
    throw 'Could not launch $url';
  }
}

class Links {
  static final pvePricing =
      Uri.parse('https://www.proxmox.com/en/products/proxmox-virtual-environment/pricing');
  static final proxmoxForum = Uri.parse('https://forum.proxmox.com');
  static final pveUserList =
      Uri.parse('https://lists.proxmox.com/cgi-bin/mailman/listinfo/pve-user');
  static final opaqueApp = Uri.parse(
      'https://play.google.com/store/apps/details?id=com.undatech.opaque');
  static final privacyPolicyUrl = Uri.parse(
      'https://pve.proxmox.com/wiki/Proxmox_VE_Mobile_Companion_Data_Protection');
  static final bugzillaUri =
      Uri.parse('https://bugzilla.proxmox.com/enter_bug.cgi?product=pve');
  static final aSpiceClient = Uri.parse(
    "https://apps.apple.com/app/id1560593107",
  );
}
