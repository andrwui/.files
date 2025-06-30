import { Gtk } from 'astal/gtk3'
import { HeadLayout } from '../NotchHead'

export function BatteryConnected() {
  return (
    <box
      name={HeadLayout.BATTERY_CONNECTED}
      halign={Gtk.Align.CENTER}
      hexpand
    >
      <label label="Connected to power" />
    </box>
  )
}

export function BatteryDisconnected() {
  return (
    <box
      name={HeadLayout.BATTERY_DISCONNECTED}
      halign={Gtk.Align.CENTER}
      hexpand
    >
      <label label="Disconnected from power" />
    </box>
  )
}

