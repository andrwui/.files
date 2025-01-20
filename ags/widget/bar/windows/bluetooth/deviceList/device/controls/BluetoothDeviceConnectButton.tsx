import { bind } from 'astal'
import AstalBluetooth from 'gi://AstalBluetooth?version=0.1'
import GenericTextButton from '../../../../_generic/GenericTextButton'

const BluetoothDeviceItemConnectButton = ({ device }: { device: AstalBluetooth.Device }) => {
  const handleClick = (isConnected: boolean) => {
    if (isConnected) {
      device.disconnect_device(() => null)
    } else {
      device.connect_device(() => null)
    }
  }

  return bind(device, 'connected').as((isConnected) => {
    return (
      <GenericTextButton
        className={bind(device, 'connecting').as(
          (isConnecting) => `${isConnecting ? 'text-blink' : ''}`,
        )}
        onClick={() => handleClick(isConnected)}
      >
        {bind(device, 'connecting').as(
          (isConnecting) =>
            `[${isConnecting ? 'connecting' : isConnected ? 'disconnect' : 'connect'}]`,
        )}
      </GenericTextButton>
    )
  })
}

export default BluetoothDeviceItemConnectButton
