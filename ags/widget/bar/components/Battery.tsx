import { bind } from 'astal'
import AstalBattery from 'gi://AstalBattery'

const Battery = () => {
  const battery = AstalBattery.get_default()

  return (
    <box spacing={5}>
      <label
        widthRequest={13}
        label={bind(battery, 'charging').as((charging) => {
          return !charging ? '󰚦' : '󱐋'
        })}
      />
      <slider
        sensitive={false}
        widthRequest={45}
        value={bind(battery, 'percentage')}
      />
    </box>
  )
}

export default Battery
