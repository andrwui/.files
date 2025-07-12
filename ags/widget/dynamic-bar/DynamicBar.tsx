import { Gdk, Astal, Gtk } from 'ags/gtk3'
import { Accessor, createContext } from 'ags'
import DynamicBarStateContext from '../../singleton/dynamic-bar-state-context'
import DynamicBarWidgets from './DynamicBarWidgets'
import DynamicBarLauncher from './DynamicBarLauncher'

export enum DynamicBarState {
  WIDGETS = 'widgets',
  NOTIFICATIONS = 'notifications',
  APP_LAUNCHER = 'app_launcher',
}

export enum Durations {
  TRANSITION = 350,
}

export const IsPrimaryContext = createContext<boolean>(false)

function DynamicBarStack() {
  const barState = DynamicBarStateContext.getInstance()
  const isPrimary = IsPrimaryContext.use()

  return (
    <box class="container">
      {isPrimary ? (
        <stack
          visibleChildName={barState.get()((state) => state)}
          class="container dynamic-bar"
        >
          <DynamicBarWidgets />
          <DynamicBarLauncher />
        </stack>
      ) : (
        <DynamicBarWidgets />
      )}
    </box>
  )
}

export default function DynamicBar(gdkmonitor: Gdk.Monitor, isPrimary: boolean) {
  const barState = DynamicBarStateContext.getInstance()

  let window: Gtk.Window

  barState.get().subscribe(() => {
    window.grab_focus()
  })

  return (
    <window
      margin={5}
      class="container dynamicbar"
      gdkmonitor={gdkmonitor}
      anchor={Astal.WindowAnchor.TOP}
      exclusivity={Astal.Exclusivity.IGNORE}
      keymode={Astal.Keymode.ON_DEMAND}
      layer={Astal.Layer.TOP}
      visible
      heightRequest={30}
      $={(self) => {
        window = self
      }}
      css={'background: transparent;'}
    >
      <IsPrimaryContext value={isPrimary}>{() => <DynamicBarStack />}</IsPrimaryContext>
    </window>
  )
}
