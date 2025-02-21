import { Gdk, Gtk } from 'astal/gtk3'
import GenericWindow from '../_generic/GenericWindow'
import { bind, exec, Variable } from 'astal'
import Separator from '../_generic/Separator'

export const HyprWindowNamePrefix = 'hyprWindow'

const HyprWindow = (monitor: Gdk.Monitor, monitorIndex: number) => {
  const windowName = `${HyprWindowNamePrefix}-${monitorIndex}`

  const monitorSetup = Variable<string>('').poll(1000, () =>
    exec(['bun', '/home/andrw/.scripts/get_active_hypr_monitors.ts']),
  )

  return (
    <GenericWindow
      gdkmonitor={monitor}
      name={windowName}
      marginRight={260}
    >
      {bind(monitorSetup).as((monitorSetup) => {
        return (
          <box vertical>
            <eventbox
              widthRequest={120}
              halign={Gtk.Align.START}
              onClick={() => {
                exec(['bun', '/home/andrw/.scripts/select_hypr_monitors.ts', 'home'])
              }}
            >{`Home${monitorSetup === 'home' ? '' : ''}`}</eventbox>
            <Separator />
            <eventbox
              widthRequest={120}
              halign={Gtk.Align.START}
              onClick={() => {
                exec(['bun', '/home/andrw/.scripts/select_hypr_monitors.ts', 'work'])
              }}
            >{`Work${monitorSetup === 'work' ? '' : ''}`}</eventbox>
          </box>
        )
      })}
      <></>
    </GenericWindow>
  )
}

export default HyprWindow
