import { bind } from 'astal'
import AstalBluetooth from 'gi://AstalBluetooth?version=0.1'
import BluetoothDevice from './device/BluetoothDevice'
import BluetoothNoDevices from './BluetoothNoDevices'

const BluetoothDeviceList = () => {
  const bt = AstalBluetooth.get_default()

  return (
    <box
      spacing={10}
      vertical={true}
    >
      {bind(bt, 'devices').as((devices) => {
        if (devices.length === 0) {
          return <BluetoothNoDevices />
        }
        return devices
          .filter((device) => device.name !== null)
          .sort((d1, d2) => (d1.connected ? -1 : d2.connected ? 1 : 0))
          .map((device) => <BluetoothDevice device={device} />)
      })}
    </box>
  )
}

export default BluetoothDeviceList
