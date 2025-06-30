import { Astal, Gtk, Gdk, Widget } from 'astal/gtk3'
import AstalTray from 'gi://AstalTray?version=0.1'

export const handleTrayItemClick = (
  self: Widget.EventBox,
  event: Astal.ClickEvent,
  item: AstalTray.TrayItem,
  menu: Gtk.Menu | null,
) => {
  const { SOUTH, NORTH } = Gdk.Gravity

  if (event.button === Astal.MouseButton.PRIMARY) {
    item.activate(0, 0)
  }

  if (event.button === Astal.MouseButton.SECONDARY) {
    if (menu) {
      menu.popup_at_widget(self, SOUTH, NORTH, null)
    }
  }
}
