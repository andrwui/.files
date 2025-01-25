import { Astal, Gdk, Gtk } from 'astal/gtk3'
import GenericWindow from '../_generic/GenericWindow'
import Separator from '../_generic/Separator'
import NetworkList from './NetworkList'

export const NetworkWindowNamePrefix = 'networkWindow'

const NetworkWindow = (monitor: Gdk.Monitor, monitorIndex: number) => {
  const windowName = `${NetworkWindowNamePrefix}-${monitorIndex}`

  const { START } = Gtk.Align

  return (
    <GenericWindow
      gdkmonitor={monitor}
      name={windowName}
      widthRequest={300}
      keymode={Astal.Keymode.ON_DEMAND}
    >
      <label
        hexpand
        halign={START}
        label="network"
        css={'font-size: 18px;'}
      />
      <Separator />
      <NetworkList />
    </GenericWindow>
  )
}

export default NetworkWindow
