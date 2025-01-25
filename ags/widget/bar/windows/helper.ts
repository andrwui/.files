import { Astal, Gdk, Gtk } from 'astal/gtk3'

export const handleWindowEsc = (self: Gtk.Window, event: Gdk.Event) => {
  if (event.get_keyval()[1] === Gdk.KEY_Escape) {
    self.hide()
  }
}

export const isPrimaryClick = (event: Astal.ClickEvent) => {
  return event.button === Astal.MouseButton.PRIMARY
}
