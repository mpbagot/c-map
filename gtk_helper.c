#include <gtk/gtk.h>

void g_signal_connect_generic(gpointer instance, const gchar *detailed_signal, GCallback c_handler, gpointer data) {
  g_signal_connect_data (instance, detailed_signal, c_handler, data, NULL, (GConnectFlags) 0);
}

GApplication* g_application_cast(GtkApplication* app) {
  return G_APPLICATION(app);
}

GCallback g_callback_cast(void *activate) {
  return G_CALLBACK (activate);
}

GtkWindow* gtk_window_cast(GtkWidget *window) {
  return GTK_WINDOW (window);
}
