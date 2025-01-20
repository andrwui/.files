import { bind } from 'astal'
import { Gtk } from 'astal/gtk3'
import AstalBluetooth from 'gi://AstalBluetooth?version=0.1'

export const useBluetoothIsPowered = (cb: (isPowered: boolean) => Gtk.Widget | '') => {
  const bluetooth = AstalBluetooth.get_default()
  return bind(bluetooth, 'isPowered').as(cb)
}
