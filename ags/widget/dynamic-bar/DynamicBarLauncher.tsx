import { Gdk, Gtk } from 'ags/gtk3'
import { createState, With } from 'ags'
import DynamicBarStateContext from '../../singleton/dynamic-bar-state-context'
import { timeout } from 'ags/time'
import { Durations, DynamicBarState, IsPrimaryContext } from './DynamicBar'
import AstalHyprland from 'gi://AstalHyprland?version=0.1'

export default function DynamicBarLauncher() {
  let entry: Gtk.Entry

  const css = ''

  const isPrimary = IsPrimaryContext.use()

  const barStateInstance = DynamicBarStateContext.getInstance()
  const barState = barStateInstance.get()
  const setBarState = barStateInstance.set

  const [shouldReveal, setShouldReveal] = createState(false)
  const [shouldRender, setShouldRender] = createState(false)
  const [shouldResize, setShouldResize] = createState(false)

  barState.subscribe(() => {
    if (barState.get() === DynamicBarState.APP_LAUNCHER) {
      setShouldResize(true)
      timeout(Durations.TRANSITION, () => {
        setShouldRender(true)
        setShouldReveal(true)
        entry.set_can_focus(true)
        entry.grab_focus()
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
      $type="named"
      name={DynamicBarState.APP_LAUNCHER}
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
              <box>
                <entry
                  sensitive
                  canFocus
                  isFocus
                  onKeyPressEvent={(_, keyval) => {
                    if (keyval.hardware_keycode === Gdk.KEY_Escape) {
                      console.log('ESCAPE')
                    }
                  }}
                  $={(self) => {
                    entry = self
                  }}
                ></entry>
              </box>
            )
          }
        </With>
      </revealer>
    </box>
  )
}
