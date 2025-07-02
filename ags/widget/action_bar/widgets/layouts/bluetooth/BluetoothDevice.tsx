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
  /*@ts-expect-error there's no type for device battery  */
  const batterybind: Binding<number> = bind(device, 'battery_percentage')

  print(device.appearance)

  const deviceSublabel = derive(
    [connectedBind, connectingBind, pairedBind, batterybind],
    (isConnected, isConnecting, isPaired, battery: number) => {
      const connectionText = isConnecting
        ? 'Connecting...'
        : isConnected
          ? 'Connected'
          : isPaired
            ? 'Paired'
            : 'Not connected'

      const batteryLevel = battery < 0 ? null : battery * 100

      return `${connectionText} ${isConnected && batteryLevel ? ' - Battery: ' + batteryLevel + '%' : ''}`
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
            device.disconnect_device(() => { })
          } else {
            device.connect_device(() => { })
          }
        }
      }}
    >
      <box
        className="device_content"
        valign={Gtk.Align.START}
      >
        <box
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
            label={deviceSublabel()}
          />
        </box>
      </box>
    </button>
  )
}
