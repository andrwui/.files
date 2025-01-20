import { BluetoothWindowNamePrefix } from '../windows/bluetooth/BluetoothWindow'
import AstalBluetooth from 'gi://AstalBluetooth?version=0.1'
import { bind } from 'astal'
import { closeAllOtherWindows } from './helper'

const Bluetooth = ({ monitorIndex }: { monitorIndex: number }) => {
  const windowName = `${BluetoothWindowNamePrefix}-${monitorIndex}`

  const bt = AstalBluetooth.get_default()

  return (
    <eventbox
      css={'border: 1px solid red'}
      onClick={() => closeAllOtherWindows(windowName)}
    >
      {bind(bt, 'isPowered').as((isPowered) => (isPowered ? '󰂯' : '󰂲'))}
    </eventbox>
  )
}

export default Bluetooth
