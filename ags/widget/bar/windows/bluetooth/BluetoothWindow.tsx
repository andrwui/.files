import { Gdk, Gtk } from 'astal/gtk3'
import BluetoothDeviceList from './deviceList/BluetoothDeviceList'
import BluetoothNotPowered from './BluetoothNotPowered'
import BluetoothPowerSwitch from './header/BluetoothPowerSwitch'
import BluetoothScanButton from './header/BluetoothScanButton'
import Separator from '../_generic/Separator'
import { useBluetoothIsPowered } from './helper'
import GenericWindow from '../_generic/GenericWindow'

export const BluetoothWindowNamePrefix = 'bluetoothWindow'

const BluetoothWindow = (monitor: Gdk.Monitor, monitorIndex: number) => {
  const windowName = `${BluetoothWindowNamePrefix}-${monitorIndex}`

  return (
    <GenericWindow
      gdkmonitor={monitor}
      name={windowName}
      widthRequest={300}
      marginRight={170}
    >
      <box halign={Gtk.Align.FILL}>
        <box
          hexpand
          halign={Gtk.Align.START}
        >
          <label
            label="bluetooth"
            css={'font-size: 18px;'}
          />
        </box>
        <box
          spacing={20}
          vexpand={false}
        >
          {useBluetoothIsPowered((isPowered) => {
            return isPowered ? <BluetoothScanButton /> : ''
          })}
          <BluetoothPowerSwitch />
        </box>
      </box>
      <Separator />
      {useBluetoothIsPowered((isPowered) => {
        return isPowered ? <BluetoothDeviceList /> : <BluetoothNotPowered />
      })}
    </GenericWindow>
  )
}

export default BluetoothWindow
