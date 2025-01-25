import { GLib, Variable } from 'astal'
import { Gtk } from 'astal/gtk3'
import { closeAllOtherWindows } from './helper'
import { CalendarWindowNamePrefix } from '../windows/calendar/CalendarWindow'

const Clock = ({ monitorIndex }: { monitorIndex: number }) => {
  const format = '%I:%M:%S'

  const time = Variable<string>('').poll(1000, () => GLib.DateTime.new_now_local().format(format)!)

  return (
    <eventbox
      className="clock"
      halign={Gtk.Align.END}
      valign={Gtk.Align.CENTER}
      onClick={() => closeAllOtherWindows(`${CalendarWindowNamePrefix}-${monitorIndex}`)}
    >
      <label label={time()}></label>
    </eventbox>
  )
}

export default Clock
