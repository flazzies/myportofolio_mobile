import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/education_form.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/screens/project_list_screen.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:provider/provider.dart';

class ItemCard extends StatelessWidget {
  final ItemHomepage item;

  const ItemCard(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: item.color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () async {
          final messenger = ScaffoldMessenger.of(context);
          final navigator = Navigator.of(context);
          final auth = context.read<AuthState>();
          messenger.hideCurrentSnackBar();

          if (item.name == "Lihat Proyek") {
            // Public: no login required.
            navigator.push(
              MaterialPageRoute(builder: (_) => const ProjectListScreen()),
            );
          } else if (item.name == "Tambah Proyek") {
            // Protected: redirects to LoginScreen when not authenticated.
            final ok = await ensureLoggedIn(context);
            if (!ok || !context.mounted) return;
            navigator.push(
              MaterialPageRoute(builder: (_) => const ProjectFormPage()),
            );
          } else if (item.name == "Logout") {
            if (!auth.isLoggedIn) {
              messenger.showSnackBar(
                const SnackBar(content: Text('You are not logged in.')),
              );
              return;
            }
            try {
              await auth.logout();
            } catch (_) {
              // The local token is already cleared in AuthState.logout().
            }
            messenger.showSnackBar(
              const SnackBar(content: Text('You have been logged out.')),
            );
          } else if (item.name == "Tambah Edukasi") {
            navigator.push(
              MaterialPageRoute(builder: (_) => const EducationFormPage()),
            );
          } else {
            messenger.showSnackBar(
              SnackBar(
                content: Text("Kamu telah menekan tombol ${item.name}!"),
              ),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.icon, color: Colors.white, size: 30.0),
                const Padding(padding: EdgeInsets.all(3)),
                Text(
                  item.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
