import { bind, derive, Variable } from 'astal'
import { Astal, Gtk } from 'astal/gtk3'
import AstalBluetooth from 'gi://AstalBluetooth?version=0.1'

type BluetoothDeviceProps = {
  device: AstalBluetooth.Device
}
export default function BluetoothDevice({ device }: BluetoothDeviceProps) {
  const connectedBind = bind(device, 'connected')
  const connectingBind = bind(device, 'connecting')
  const pairedBind = bind(device, 'paired')

  const deviceState = derive(
    [connectedBind, connectingBind, pairedBind],
    (isConnected, isConnecting, isPaired) => {
      return { isConnected, isConnecting, isPaired }
    },
  )

  return (
    <button
      className="device"
      valign={Gtk.Align.FILL}
      cursor="pointer"
      onClick={(_, ev) => {
        if (ev.button === Astal.MouseButton.PRIMARY) {
          if (device.connected) {
            device.disconnect_device(() => {})
          } else {
            device.connect_device(() => {})
          }
        }
      }}
    >
      <box
        className="device_content"
        vertical
        valign={Gtk.Align.START}
      >
        <label
          className="device_name"
          label={device.name}
          halign={Gtk.Align.START}
        />
        <label
          className="device_connected-indicator"
          halign={Gtk.Align.START}
          label={deviceState().as(({ isConnected, isConnecting, isPaired }) => {
            return isConnecting
              ? 'Connecting...'
              : isConnected
                ? 'Connected'
                : isPaired
                  ? 'Paired'
                  : 'Not connected'
          })}
        />
      </box>
    </button>
  )
}
