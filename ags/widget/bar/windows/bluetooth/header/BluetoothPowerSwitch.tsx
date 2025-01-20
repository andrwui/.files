import { Gtk } from 'astal/gtk3'
import AstalBluetooth from 'gi://AstalBluetooth?version=0.1'

const BluetoothPowerSwitch = () => {
  const bt = AstalBluetooth.get_default()

  return (
    <switch
      margin_right={5}
      halign={Gtk.Align.END}
      active={bt.isPowered}
      setup={(self) => {
        self.connect('notify::active', () => {
          bt.adapter?.set_powered(self.active)
        })
      }}
    />
  )
}

export default BluetoothPowerSwitch
