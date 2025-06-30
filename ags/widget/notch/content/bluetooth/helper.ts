import AstalBluetooth from 'gi://AstalBluetooth?version=0.1'

export function filterAndSortDevices(devices: AstalBluetooth.Device[]) {
  return devices
    .filter((device) => device.name !== null && device !== null)
    .sort((d1, d2) => (d1.connected ? -1 : d2.connected ? 1 : 0))
    .sort((d1, d2) => (d1.trusted ? -1 : d2.trusted ? 1 : 0))
    .sort((d1, d2) => (d1.paired ? -1 : d2.paired ? 1 : 0))
}
