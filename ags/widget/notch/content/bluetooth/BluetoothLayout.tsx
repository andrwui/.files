import { NotchLayoutType } from '@/singleton/notchLayout/NotchLayout'
import LayoutContainer from '../LayoutContainer'
import AstalBluetooth from 'gi://AstalBluetooth?version=0.1'
import { bind } from 'astal'
import { Gtk } from 'astal/gtk3'
import BluetoothDevice from './BluetoothDevice'
import { filterAndSortDevices } from './helper'
import BluetoothHeader from './BluetoothHeader'
import Spacer from '@/widget/generic/Spacer'

export default function BluetoothLayout() {
  const bluetooth = AstalBluetooth.get_default()
  const bluetoothDevicesBind = bind(bluetooth, 'devices')

  return (
    <LayoutContainer
      name={NotchLayoutType.BLUETOOTH}
      className="bluetoothLayout"
    >
      <box
        vertical
        vexpand
        hexpand
        spacing={10}
      >
        <BluetoothHeader />
        <scrollable
          hexpand
          vexpand
        >
          <box
            vertical
            spacing={5}
          >
            {bluetoothDevicesBind.as((devices) => {
              const filteredDevices = filterAndSortDevices(devices)
              if (filteredDevices.length === 0) {
                return (
                  <label
                    halign={Gtk.Align.START}
                    label="No available devices"
                  />
                )
              }
              return filteredDevices.map((device) => {
                return (
                  <>
                    <BluetoothDevice device={device} />
                    <Spacer />
                  </>
                )
              })
            })}
          </box>
        </scrollable>
      </box>
    </LayoutContainer>
  )
}
