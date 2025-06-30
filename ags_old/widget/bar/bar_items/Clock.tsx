import { GLib, Variable } from 'astal'
import { Gtk } from 'astal/gtk3'
import { closeAllOtherWindows } from './helper'
import { CalendarWindowNamePrefix } from '../windows/calendar/CalendarWindow'

const Clock = ({ monitorIndex }: { monitorIndex: number }) => {
  const format = '%I:%M:%S'

  const time = Variable<string>('').poll(1000, () => GLib.DateTime.new_now_local().format(format)!)

  return (
    <eventbox
      cursor={'pointer'}
      className="clock"
      halign={Gtk.Align.END}
      valign={Gtk.Align.START}
      widthRequest={80}
      onClick={() => closeAllOtherWindows(`${CalendarWindowNamePrefix}-${monitorIndex}`)}
    >
      <label
        halign={Gtk.Align.START}
        label={time()}
      ></label>
    </eventbox>
  )
}

export default Clock
