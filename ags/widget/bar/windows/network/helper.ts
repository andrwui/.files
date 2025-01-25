import AstalNetwork from 'gi://AstalNetwork?version=0.1'
import { password, selectedAp } from './variables'
import { execAsync } from 'astal'

export const filterAps = (aps: AstalNetwork.AccessPoint[]): AstalNetwork.AccessPoint[] => {
  const dedupedAps: Record<string, AstalNetwork.AccessPoint> = {}

  const activeAp = AstalNetwork.get_default().wifi.activeAccessPoint

  aps
    .filter((ap) => ap.ssid != null)
    .filter((ap) => ap.ssid.trim() != '')
    .filter((ap) => !ap.ssid.match(/^\d+$/))
    .sort((a, b) => b.strength - a.strength)
    .sort((a, b) =>
      !activeAp ? 0 : a.ssid === activeAp.ssid ? -1 : b.ssid === activeAp.ssid ? 1 : 0,
    )
    .forEach((ap) => {
      if (ap.ssid !== null && !dedupedAps[ap.ssid]) {
        dedupedAps[ap.ssid] = ap
      }
    })

  return Object.values(dedupedAps)
}

export const areApsSame = <T extends AstalNetwork.AccessPoint>(ap1: T, ap2: T) => {
  return ap1.ssid === ap2.ssid
}

export const connect = () => {
  const pw = password.get()
  execAsync([
    'bash',
    '-c',
    `echo ${pw} | nmcli device wifi connect ${selectedAp.get()?.bssid} --ask`,
  ])
    .then((res) => {
      console.log(res)
      password.set('')
    })
    .catch((err) => console.log(err))
}

export const disconnect = () => {
  execAsync(['bash', '-c', `nmcli connection delete "${selectedAp.get()?.ssid}" --ask`])
    .then((res) => {
      console.log(res)
      password.set('')
    })
    .catch((err) => console.log(err))
}
