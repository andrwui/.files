import { bind } from 'astal'
import AstalBattery from 'gi://AstalBattery'

const Battery = () => {
  const battery = AstalBattery.get_default()

  return (
    <box spacing={2}>
      {bind(battery, 'charging').as((charging) => {
        return charging ? (
          <icon
            widthRequest={13}
            icon="zap"
            css={`
              font-size: 14px;
            `}
          />
        ) : (
          ''
        )
      })}
      <slider
        css={`
          border-radius: 2px;
        `}
        sensitive={false}
        widthRequest={45}
        value={bind(battery, 'percentage')}
      />
    </box>
  )
}

export default Battery
