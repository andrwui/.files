import { createBinding, createState, For, With } from 'ags'
import { Astal, Gdk, Gtk } from 'ags/gtk3'
import AstalTray from 'gi://AstalTray?version=0.1'
import Cairo10 from 'gi://cairo'

export default function Tray(gdkmonitor: Gdk.Monitor) {
  const tray = AstalTray.get_default()
  const trayItems = createBinding(tray, 'items')

  return (
    <window
      margin={5}
      class="container tray"
      gdkmonitor={gdkmonitor}
      anchor={Astal.WindowAnchor.TOP | Astal.WindowAnchor.RIGHT}
      exclusivity={Astal.Exclusivity.IGNORE}
      layer={Astal.Layer.TOP}
      visible
      heightRequest={30}
      css={'background: transparent;'}
    >
      <box
        heightRequest={30}
        valign={Gtk.Align.CENTER}
        vertical
        class="container tray"
      >
        <box
          spacing={5}
          valign={Gtk.Align.CENTER}
          hexpand
          halign={Gtk.Align.END}
        >
          <For each={trayItems}>
            {(item) => {
              console.log()
              return (
                <eventbox
                  onClick={(_, evt) => {
                    if (evt.button === Astal.MouseButton.SECONDARY) {
                      const menu = Gtk.Menu.new_from_model(item.menuModel)

                      menu.insert_action_group('dbusmenu', item.actionGroup)

                      menu.popup_at_pointer(null)
                      menu.set_style(new Gtk.Style())
                      return null
                    }
                    if (evt.button === Astal.MouseButton.PRIMARY) {
                      item.activate(0, 0)
                    }
                  }}
                >
                  <icon
                    gicon={createBinding(item, 'gicon')}
                    css="font-size: 18px;"
                  />
                </eventbox>
              )
            }}
          </For>
        </box>
      </box>
    </window>
  )
}
