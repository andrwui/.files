import { Gtk } from 'ags/gtk3'
import { createState, With } from 'ags'
import DynamicBarStateContext from '../../singleton/dynamic-bar-state-context'
import { timeout } from 'ags/time'
import { Durations, DynamicBarState, IsPrimaryContext } from './DynamicBar'
import SimpleClock from '../SimpleClock'

export default function DynamicBarWidgets() {
  const css = 'min-width: 200px;'

  const isPrimary = IsPrimaryContext.use()

  const barStateInstance = DynamicBarStateContext.getInstance()
  const barState = barStateInstance.get()

  const [shouldReveal, setShouldReveal] = createState(true)
  const [shouldRender, setShouldRender] = createState(true)
  const [shouldResize, setShouldResize] = createState(true)

  barState.subscribe(() => {
    if (barState.get() === DynamicBarState.WIDGETS) {
      setShouldResize(true)
      timeout(Durations.TRANSITION, () => {
        setShouldRender(true)
        setShouldReveal(true)
      })
    } else {
      timeout(Durations.TRANSITION, () => {
        setShouldReveal(false)
        setShouldRender(false)
        setShouldResize(false)
      })
    }
  })

  return (
    <box
      $type={isPrimary ? 'named' : ''}
      name={DynamicBarState.WIDGETS}
      css={shouldResize((shouldResize) => (shouldResize ? css : ''))}
    >
      <revealer
        revealChild={shouldReveal}
        transitionType={Gtk.RevealerTransitionType.CROSSFADE}
        transitionDuration={Durations.TRANSITION}
      >
        <With value={shouldRender}>
          {(state) =>
            state && (
              <box
                hexpand
                halign={Gtk.Align.CENTER}
              >
                <SimpleClock />
              </box>
            )
          }
        </With>
      </revealer>
    </box>
  )
}
