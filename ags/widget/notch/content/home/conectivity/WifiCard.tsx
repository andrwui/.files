import AstalNetwork from 'gi://AstalNetwork?version=0.1'
import ConectivityCard from './ConectivityCard'
import { bind, derive } from 'astal'

export default function WifiCard() {
  enum Icons {
    WIFI_HI = 'i-wifi-dark',
    WIFI_MED = 'i-wifi-med-dark',
    WIFI_LOW = 'i-wifi-low-dark',
    ETHERNET = 'i-ethernet-dark',
    ON = 'i-wifi',
    OFF = 'i-wifi-off',
  }

  const { ACTIVATED, IP_CONFIG } = AstalNetwork.DeviceState

  const network = AstalNetwork.get_default()
  const wifiStateBind = bind(network.wifi, 'state')
  const wifiStrengthBind = bind(network.wifi, 'strength')
  const wifiAccessPointBind = bind(network.wifi, 'activeAccessPoint')

  const wiredStateBind = bind(network.wired, 'state')

  const networkState = derive(
    [wifiStateBind, wifiStrengthBind, wifiAccessPointBind, wiredStateBind],
    (wifiState, wifiStrength, wifiAccessPoint, wiredState) => {
      return { wifiState, wifiStrength, wifiAccessPoint, wiredState }
    },
  )

  const label = networkState().as(({ wifiState, wifiStrength, wifiAccessPoint, wiredState }) => {
    if (wiredState === ACTIVATED) {
      return 'Ethernet'
    }
    if (wiredState === IP_CONFIG || wifiState === IP_CONFIG) {
      return 'Connecting...'
    }
    if (wifiState === ACTIVATED) {
      return wifiAccessPoint.ssid
    }
    return 'On'
  })

  const containerClass = networkState().as(({ wifiState, wiredState }) => {
    return wifiState === ACTIVATED || wiredState === ACTIVATED ? 'active' : ''
  })

  const icon = networkState().as(({ wifiState, wiredState, wifiStrength }) => {
    if (wiredState === ACTIVATED) {
      return Icons.ETHERNET
    }
    if (wifiState === ACTIVATED) {
      if (wifiStrength < 30) {
        return Icons.WIFI_LOW
      }
      if (wifiStrength < 50) {
        return Icons.WIFI_MED
      }
      return Icons.WIFI_HI
    }
  })

  const arrowsIcon = networkState().as(({ wifiState, wiredState }) => {
    return wifiState === ACTIVATED || wiredState === ACTIVATED ? 'black' : 'white'
  })

  return (
    <ConectivityCard
      containerClass={containerClass}
      arrowsIcon={arrowsIcon}
      icons={Icons}
      currentIcon={icon}
      label={label}
      onButtonClick={() => {
        print(network.wifi.state)
      }}
    />
  )
}
