import { Gdk, Gtk } from 'astal/gtk3'
import GenericWindow from '../_generic/GenericWindow'
import Calendar from '../../../shared/Calendar'
import Separator from '../_generic/Separator'
import { Variable } from 'astal'

export const CalendarWindowNamePrefix = 'calendarWindow'

const CalendarWindow = (monitor: Gdk.Monitor, monitorIndex: number) => {
  const windowName = `${CalendarWindowNamePrefix}-${monitorIndex}`

  const date = Variable<string>(new Date().toString()).poll(1000, () =>
    new Date().toLocaleDateString('es-uy', {
      day: '2-digit',
      month: '2-digit',
      year: '2-digit',
    }),
  )

  const { START, END } = Gtk.Align

  return (
    <GenericWindow
      gdkmonitor={monitor}
      name={windowName}
      widthRequest={300}
    >
      <box vertical>
        <box>
          <label
            hexpand
            halign={START}
            label="calendar"
            css={'font-size: 18px;'}
          />
          <label
            hexpand
            halign={END}
            label={date()}
            css={'font-size: 18px;'}
          />
        </box>
        <Separator />
        <Calendar height_request={200} />
      </box>
      <></>
    </GenericWindow>
  )
}

export default CalendarWindow
