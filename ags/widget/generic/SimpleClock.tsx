import { Variable } from 'astal'
import GLib from 'gi://GLib?version=2.0'
import { Gtk } from 'astal/gtk3'

export default function SimpleClock({ icon }: { icon?: boolean }) {
  const time = Variable<string>('').poll(1000, () => GLib.DateTime.new_now_local().format('%H:%M')!)

  return (
    <box
      halign={Gtk.Align.CENTER}
      className="container"
      css="padding: 0 5px;"
      spacing={5}
    >
      {icon ? <icon icon="i-clock" /> : ''}
      <label label={time()} />
    </box>
  )
}
