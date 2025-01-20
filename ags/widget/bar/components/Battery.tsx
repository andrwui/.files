import { bind } from 'astal'
import AstalBattery from 'gi://AstalBattery?version=0.1'

const Battery = () => {
  const battery = AstalBattery.get_default()

  const percentage = bind(battery, 'percentage').as((percentage) => percentage)
  const percentageText = bind(battery, 'percentage').as(
    (percentage) => `${Math.floor(percentage * 100)}%`,
  )

  return (
    <slider
      width_request={40}
      value={percentage}
      sensitive={false}
      tooltipText={percentageText}
      css={'padding: 0, 3px;'}
    />
  )
}

export default Battery
