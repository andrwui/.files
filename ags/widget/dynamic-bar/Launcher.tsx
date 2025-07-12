import { createState, With } from 'ags'
import { Gdk, Gtk } from 'ags/gtk3'
import Astal from 'gi://Astal?version=3.0'
import { Durations } from './DynamicBar'
import { timeout } from 'ags/time'
import LauncherStateContext from '../../singleton/app-launcher-state'

export default function Launcher(gdkmonitor: Gdk.Monitor) {
  const launcherState = LauncherStateContext.getInstance()

  launcherState.get().subscribe(() => {
    if (window.visible) {
      setShouldResize(true)
      timeout(Durations.TRANSITION, () => {
        setShouldRender(true)
        setShouldReveal(true)
        launcherState.set(true)
      })
    } else {
      timeout(Durations.TRANSITION, () => {
        setShouldReveal(false)
        setShouldRender(false)
        setShouldResize(false)
        launcherState.set(false)
      })
    }
  })

  function onKey(self: Astal.Window, evt: Gdk.EventKey) {
    launcherState.set(false)
  }

  let entry: Gtk.Entry
  let window: Gtk.Window

  const [shouldReveal, setShouldReveal] = createState(false)
  const [shouldRender, setShouldRender] = createState(false)
  const [shouldResize, setShouldResize] = createState(false)

  const css = 'min-width: 300px; min-height: 600px'

  return (
    <window
      name="app_launcher"
      margin={5}
      gdkmonitor={gdkmonitor}
      class="container dynamicbar"
      anchor={Astal.WindowAnchor.TOP}
      exclusivity={Astal.Exclusivity.IGNORE}
      keymode={Astal.Keymode.ON_DEMAND}
      layer={Astal.Layer.TOP}
      heightRequest={30}
      visible={true}
      onKeyPressEvent={onKey}
      css={'background: transparent;'}
      $={(self) => (window = self)}
    >
      <box
        css={shouldResize((shouldResize) => (shouldResize ? css : ''))}
        class="container"
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
                  <entry
                    sensitive
                    $={(self) => (entry = self)}
                  />
                </box>
              )
            }
          </With>
        </revealer>
      </box>
    </window>
  )
}
