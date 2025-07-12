import { Durations } from '@/constants/constants'
import { bind, timeout, Variable } from 'astal'
import { Gtk } from 'astal/gtk3'

import AstalBattery from 'gi://AstalBattery?version=0.1'

export default function Battery() {
  const battery = AstalBattery.get_default()
  const isChargingBind = bind(battery, 'charging')
  const percentageBind = bind(battery, 'percentage')

  const shouldReveal = Variable(false)
  const shouldExpand = Variable(false)
  const shouldSpace = Variable(false)

  shouldReveal.set(isChargingBind.get())
  shouldExpand.set(isChargingBind.get())
  shouldSpace.set(isChargingBind.get())

  isChargingBind.subscribe((isCharging) => {
    if (isCharging) {
      shouldExpand.set(isCharging)
      timeout(Durations.TRANSITION, () => {
        shouldReveal.set(isCharging)
        shouldSpace.set(isCharging)
      })
    } else {
      shouldReveal.set(isCharging)
      timeout(Durations.TRANSITION, () => {
        shouldExpand.set(isCharging)
        shouldSpace.set(isCharging)
      })
    }
  })

  return (
    <box
      className="container right battery"
      css={shouldExpand().as((isCharging) => {
        return isCharging ? 'min-width: 49px' : 'min-width: 0px'
      })}
    >
      <box
        name="charging"
        spacing={shouldSpace().as((shouldSpace) => (shouldSpace ? 5 : -15))}
      >
        <label label={percentageBind.as((p) => `${Math.round(p * 100)}%`)} />
        <revealer
          revealChild={shouldReveal()}
          transitionDuration={Durations.TRANSITION}
          transitionType={Gtk.RevealerTransitionType.CROSSFADE}
        >
          <icon icon="i-zap" />
        </revealer>
      </box>
    </box>
  )
}
