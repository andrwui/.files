import { Gtk } from 'astal/gtk3'
import AstalBluetooth from 'gi://AstalBluetooth?version=0.1'
import { bind, Variable } from 'astal'

const BluetoothDevice = ({ device }: { device: AstalBluetooth.Device }) => {
  const bluetoothBinding = Variable<[boolean, boolean]>([false, false])
  Variable.derive(
    [bind(device, 'connected'), bind(device, 'connecting')],
    (isConnected, isConnecting) => {
      bluetoothBinding.set([isConnected, isConnecting])
    },
  )

  const handleClick = (isConnected: boolean) => {
    if (isConnected) {
      device.disconnect_device(() => null)
    } else {
      device.connect_device(() => null)
    }
  }

  return (
    <box
      halign={Gtk.Align.FILL}
      hexpand
    >
      {bind(bluetoothBinding).as(([isConnected, isConnecting]) => {
        return (
          <eventbox onClick={() => handleClick(isConnected)}>
            <label
              label={`${device.name} ${isConnected ? ' ' : ''}`}
              className={`${isConnecting ? 'text-blink' : ''}`}
            />
          </eventbox>
        )
      })}
    </box>
  )
}

export default BluetoothDevice
