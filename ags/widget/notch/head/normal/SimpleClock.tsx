import { Variable } from 'astal'
import GLib from 'gi://GLib?version=2.0'
import { HeadLayout } from '../NotchHead'
import { Gtk } from 'astal/gtk3'

export default function SimpleClock() {
  const time = Variable<string>('').poll(1000, () => GLib.DateTime.new_now_local().format('%H:%M')!)

  return (
    <box
      name={HeadLayout.NORMAL}
      halign={Gtk.Align.CENTER}
    >
      <label label={time()} />
    </box>
  )
}
