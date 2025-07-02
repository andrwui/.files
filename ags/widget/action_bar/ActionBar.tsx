import { App, Astal, Gdk } from 'astal/gtk3'
import { ActionBarWidgetPanel } from './widgets/Widgets'
import ActionBarLayout, { ActionBarLayoutType } from '@/singleton/action_bar_layout/ActionBarLayout'
import { Gtk } from 'astal/gtk3'
import { Durations } from '@/constants/constants'
import Notification from './notifications/Notification'

export default function ActionBar(gdkmonitor: Gdk.Monitor, isPrimary: boolean) {
  const actionBarLayout = ActionBarLayout.getInstance()

  return (
    <window
      marginTop={5}
      className="ActionBar"
      gdkmonitor={gdkmonitor}
      anchor={Astal.WindowAnchor.TOP}
      exclusivity={Astal.Exclusivity.IGNORE}
      layer={Astal.Layer.TOP}
      application={App}
      visible
      heightRequest={30}
    >
      <box className={`container actionbar`}>
        <stack
          visibleChildName={actionBarLayout
            .get()
            .as((layout) => (isPrimary ? layout : ActionBarLayoutType.WIDGETS))}
          transition_type={Gtk.StackTransitionType.CROSSFADE}
          transition_duration={Durations.TRANSITION}
        >
          <ActionBarWidgetPanel />
          <Notification isPrimary={isPrimary} />
        </stack>
      </box>
    </window>
  )
}
