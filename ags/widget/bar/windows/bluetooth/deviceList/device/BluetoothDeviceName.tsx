import { bind } from 'astal'
import AstalBluetooth from 'gi://AstalBluetooth'

const BluetoothDeviceName = ({ device }: { device: AstalBluetooth.Device }) => {
  return (
    <label
      label={bind(device, 'connected').as((connected) =>
        connected ? `${device.name} <-` : `${device.name}`,
      )}
    />
  )
}

export default BluetoothDeviceName
