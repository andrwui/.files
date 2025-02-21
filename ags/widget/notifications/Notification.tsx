import { exec, GLib } from 'astal'
import { Gtk, Astal } from 'astal/gtk3'
import { type EventBox } from 'astal/gtk3/widget'
import Notifd from 'gi://AstalNotifd'
import { wrap } from '../../helper/helper'
import Separator from '../bar/windows/_generic/Separator'

const isIcon = (icon: string) => !!Astal.Icon.lookup_icon(icon)

const fileExists = (path: string) => GLib.file_test(path, GLib.FileTest.EXISTS)

const time = (time: number, format = '%H:%M') =>
  GLib.DateTime.new_from_unix_local(time).format(format)!

const urgency = (n: Notifd.Notification) => {
  const { LOW, NORMAL, CRITICAL } = Notifd.Urgency
  // match operator when?
  switch (n.urgency) {
    case LOW:
      return 'low'
    case CRITICAL:
      return 'critical'
    case NORMAL:
    default:
      return 'normal'
  }
}

type Props = {
  setup(self: EventBox): void
  onHoverLost(self: EventBox): void
  notification: Notifd.Notification
}

export default function Notification(props: Props) {
  const { notification: n, onHoverLost, setup } = props
  const { START, CENTER, END } = Gtk.Align

  console.log(n.appName)

  return (
    <eventbox
      className={`Notification ${urgency(n)} window`}
      setup={setup}
      onHoverLost={onHoverLost}
      css={'border-radius: 3px; padding: 5px'}
      marginBottom={10}
      onClick={() => n.actions[0]}
    >
      <box
        vertical
        css={'padding: 10px;'}
      >
        <box
          className="header"
          spacing={15}
        >
          {(n.appIcon || n.desktopEntry) && (
            <icon
              className="app-icon"
              visible={Boolean(n.appIcon || n.desktopEntry)}
              icon={n.appIcon || n.desktopEntry}
            />
          )}
          <label
            className="app-name"
            halign={START}
            css={'font-size: 24px;'}
            label={n.appName.trim() || 'Unknown'}
          />
          <label
            className="time"
            hexpand
            widthRequest={20}
            css={'font-size: 15px;'}
            halign={END}
            label={''}
          />
          <button onClicked={() => n.dismiss()}>
            <icon
              css={'font-size: 20px'}
              icon="window-close-symbolic"
            />
          </button>
        </box>
        <Separator />
        <box className="content">
          <box
            vertical
            spacing={10}
          >
            <label
              className="summary"
              halign={START}
              xalign={0}
              css={'font-size: 18px;'}
              label={n.summary}
              truncate
            />
            {n.body && (
              <label
                className="body"
                useMarkup
                halign={START}
                xalign={0}
                label={wrap(n.body, 6)}
              />
            )}
          </box>
        </box>
        {n.get_actions().length > 0 && (
          <box className="actions">
            {n.get_actions().map(({ label, id }) => (
              <button
                hexpand
                onClicked={() => n.invoke(id)}
              >
                <label
                  label={label}
                  halign={CENTER}
                  hexpand
                />
              </button>
            ))}
          </box>
        )}
      </box>
    </eventbox>
  )
}
