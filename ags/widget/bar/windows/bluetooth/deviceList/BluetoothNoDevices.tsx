import { Gtk } from 'astal/gtk3'

const BluetoothNoDevices = () => {
  return (
    <label
      halign={Gtk.Align.START}
      label="no devices"
    />
  )
}

export default BluetoothNoDevices
