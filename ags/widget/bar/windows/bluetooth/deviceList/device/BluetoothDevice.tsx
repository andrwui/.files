import { Gtk } from 'astal/gtk3'
import AstalBluetooth from 'gi://AstalBluetooth?version=0.1'
import BluetoothDeviceItemConnectButton from './controls/BluetoothDeviceConnectButton'
import BluetoothDeviceName from './BluetoothDeviceName'

const BluetoothDevice = ({ device }: { device: AstalBluetooth.Device }) => {
  return (
    <box
      halign={Gtk.Align.FILL}
      hexpand
    >
      <BluetoothDeviceName device={device} />
      <box
        halign={Gtk.Align.END}
        hexpand
        spacing={10}
      >
        {/*@ts-expect-error returns widget that behaves as jsx component lmao*/}
        <BluetoothDeviceItemConnectButton device={device} />
      </box>
    </box>
  )
}

export default BluetoothDevice
