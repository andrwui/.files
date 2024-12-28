import network from 'services/network'

const NetworkTrayButton = () => {
  const icon = network.bind("network_info").as((ni) => {
    if (ni.ethernet.isConnected == true) {
      return "󰈀"
    } else if (ni.wifi.isConnected) {
      return "󰖩"
    } else {
      return "󰖪"
    }
  })

  const tooltip = network.bind("network_info").as(ni => ni.wifi.isConnected ? `${ni.wifi.name.trim()}` : '')

  return Widget.Button({
    className: 'indicator-icon',
    label: icon,
    tooltipText: tooltip
  })
}



export default NetworkTrayButton

