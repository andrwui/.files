import { bind, derive, Variable } from 'astal'
import ConectivityCard from './ConectivityCard'
import AstalBluetooth from 'gi://AstalBluetooth?version=0.1'
import NotchLayout, { NotchLayoutType } from '@/singleton/notchLayout/NotchLayout'
import Notch from '@/widget/notch/Notch'

export default function BluetoothCard() {
  const notchLayout = NotchLayout.getInstance()

  enum Icons {
    CONNECTED = 'i-bluetooth-connected',
    ON = 'i-bluetooth',
    OFF = 'i-bluetooth-off',
  }

  const bluetooth = AstalBluetooth.get_default()

  const isPoweredBind = bind(bluetooth, 'is_powered')
  const isConnectedBind = bind(bluetooth, 'is_connected')
  const connectedDevice = Variable<AstalBluetooth.Device | undefined>(undefined)

  isConnectedBind.subscribe((isConnected) => {
    if (isConnected) {
      bluetooth.get_devices().forEach((device) => {
        if (device.connected) {
          connectedDevice.set(device)
          return
        }
      })
    } else {
      connectedDevice.set(undefined)
    }
  })

  bluetooth.get_devices().forEach((device) => {
    if (device.connected) {
      connectedDevice.set(device)
      return
    }
  })

  const bluetoothState = derive(
    [isPoweredBind, isConnectedBind, connectedDevice],
    (isPowered, isConnected, connectedDevice) => {
      return {
        isPowered,
        isConnected,
        connectedDevice,
      }
    },
  )

  const currentIcon = bluetoothState().as(({ isPowered, isConnected }) => {
    return isConnected ? Icons.CONNECTED : isPowered ? Icons.ON : Icons.OFF
  })

  const label = bluetoothState().as(({ isPowered, connectedDevice }) => {
    return connectedDevice ? connectedDevice?.name : isPowered ? 'On' : 'Off'
  })

  const showArrows = bluetoothState().as(({ isConnected }): 'black' | 'white' =>
    isConnected ? 'black' : 'white',
  )

  const containerClass = bluetoothState().as(({ isConnected }) => (isConnected ? 'active' : ''))

  const toggleBluetooth = () => {
    bluetooth.adapter?.set_powered(!bluetooth.get_is_powered())
  }

  return (
    <ConectivityCard
      onTextClick={() => {
        notchLayout.set(NotchLayoutType.BLUETOOTH)
        bluetooth.adapter.set_powered(true)
      }}
      icons={Icons}
      currentIcon={currentIcon}
      label={label}
      onButtonClick={toggleBluetooth}
      arrowsIcon={showArrows}
      containerClass={containerClass}
    />
  )
}
