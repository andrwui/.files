import { bind, Variable } from 'astal'
import { closeAllOtherWindows } from './helper'
import AstalNetwork from 'gi://AstalNetwork'
import { NetworkWindowNamePrefix } from '../windows/network/NetworkWindow'
import { Gtk } from 'astal/gtk3'

const Network = ({ monitorIndex }: { monitorIndex: number }) => {
  const network = AstalNetwork.get_default()

  const wifiState = bind(network.wifi, 'state')
  const wiredState = bind(network.wired, 'state')

  const networkStateBinding = Variable<[number, number]>([0, 0])

  Variable.derive([wifiState, wiredState], (wifiState, wiredState) => {
    networkStateBinding.set([wifiState, wiredState])
  })

  const windowName = `${NetworkWindowNamePrefix}-${monitorIndex}`

  const { ACTIVATED } = AstalNetwork.DeviceState

  return (
    <eventbox
      cursor={'pointer'}
      halign={Gtk.Align.START}
      onClick={() => closeAllOtherWindows(windowName)}
      css={' font-size: 200px;'}
    >
      {bind(networkStateBinding).as(([wifiState, wiredState]) => {
        return (
          <icon
            widthRequest={13}
            css={`
              ${wiredState !== ACTIVATED && wifiState !== ACTIVATED ? 'color: #404040;' : ''};
              font-size: 16px;
            `}
            icon={`${wiredState === ACTIVATED ? 'ethernet-port' : wifiState === ACTIVATED ? 'wifi' : 'wifi-off'}`}
          />
        )
      })}
      )
    </eventbox>
  )
}
//
export default Network
