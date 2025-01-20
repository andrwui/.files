import { bind } from 'astal'
import { closeAllOtherWindows } from './helper'
import AstalNetwork from 'gi://AstalNetwork'
import { NetworkWindowNamePrefix } from '../windows/network/NetworkWindow'
import { Gtk } from 'astal/gtk3'

const Network = ({ monitorIndex }: { monitorIndex: number }) => {
  const network = AstalNetwork.get_default()

  const wifi = bind(network, 'wifi')
  const wired = bind(network, 'wired')

  const windowName = `${NetworkWindowNamePrefix}-${monitorIndex}`

  return (
    <eventbox
      halign={Gtk.Align.START}
      css="font-size: 15px;"
      onClick={() => closeAllOtherWindows(windowName)}
      tooltipText={wifi.as((wifi) => {
        return wifi.ssid
      })}
    >
      {wifi.as((wifi) => {
        return (
          <label
            css={'font-weight: 500;'}
            label={wired.as((wired) => {
              if (wired.get_internet() === AstalNetwork.Internet.CONNECTED) {
                console.log(wired.get_internet())
                return '[ethernet]'
              }
              if (wifi.get_internet() === AstalNetwork.Internet.CONNECTED) {
                return '[wifi]'
              }
            })}
          />
        )
      })}
    </eventbox>
  )
}

export default Network
