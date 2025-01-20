import { bind } from 'astal'
import AstalBluetooth from 'gi://AstalBluetooth?version=0.1'
import BluetoothDevice from './device/BluetoothDevice'
import BluetoothNoDevices from './BluetoothNoDevices'

const BluetoothDeviceList = () => {
  const bt = AstalBluetooth.get_default()

  return (
    <box vertical={true}>
      {bind(bt, 'devices').as((devices) => {
        if (devices.length === 0) {
          return <BluetoothNoDevices />
        }
        return devices
          .filter((device) => device.name !== null)
          .map((device) => <BluetoothDevice device={device} />)
      })}
    </box>
  )
}

export default BluetoothDeviceList
