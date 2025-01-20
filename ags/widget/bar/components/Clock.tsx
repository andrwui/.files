import { GLib, Variable } from 'astal'
import { Gtk } from 'astal/gtk3'

const Clock = () => {
  const format = '%I:%M:%S'

  const time = Variable<string>('').poll(1000, () => GLib.DateTime.new_now_local().format(format)!)

  return (
    <label
      className="clock"
      halign={Gtk.Align.END}
      valign={Gtk.Align.CENTER}
      label={time()}
    />
  )
}

export default Clock
