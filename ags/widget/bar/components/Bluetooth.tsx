import { BluetoothWindowNamePrefix } from '../windows/bluetooth/BluetoothWindow'
import AstalBluetooth from 'gi://AstalBluetooth?version=0.1'
import { bind, Variable } from 'astal'
import { closeAllOtherWindows } from './helper'

const Bluetooth = ({ monitorIndex }: { monitorIndex: number }) => {
  const windowName = `${BluetoothWindowNamePrefix}-${monitorIndex}`

  const bt = AstalBluetooth.get_default()

  const bluetoothBinding = Variable([false, false])

  Variable.derive([bind(bt, 'isConnected'), bind(bt, 'isPowered')], (connected, powered) => {
    bluetoothBinding.set([connected, powered])
  })

  return (
    <eventbox
      cursor={'pointer'}
      onClick={() => closeAllOtherWindows(windowName)}
    >
      {bind(bluetoothBinding).as(([connected, powered]) => {
        return (
          <label
            widthRequest={13}
            css={`
              ${!powered ? 'color: #404040;' : ''}
            `}
            label={`${!powered ? '󰂲' : !connected ? '󰂯' : '󰂱'}`}
          />
        )
      })}
    </eventbox>
  )
}

export default Bluetooth
