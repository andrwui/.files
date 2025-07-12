import { bind, derive, timeout, Variable } from 'astal'
import AstalNotifd from 'gi://AstalNotifd?version=0.1'
import ActionBarLayout, { ActionBarLayoutType } from '@/singleton/action_bar_layout/ActionBarLayout'
import { Durations } from '@/constants/constants'
import { Gtk } from 'astal/gtk3'
import { truncateText } from '@/helper/strings'
import AstalBattery from 'gi://AstalBattery?version=0.1'
import { sendNotification } from '@/helper/notifications'
import { getBatteryIcon } from '@/helper/battery'

export default function Notification({ isPrimary }: { isPrimary: boolean }) {
  const actionBarLayout = ActionBarLayout.getInstance()

  const notifd = AstalNotifd.get_default()
  const battery = AstalBattery.get_default()

  const notification = Variable<AstalNotifd.Notification | null>(null)
  const renderNotification = Variable<boolean>(false)

  notifd.connect('notified', (self, notifId) => {
    if (
      actionBarLayout.get().get() === ActionBarLayoutType.POWER_MENU ||
      actionBarLayout.get().get() === ActionBarLayoutType.APP_LAUNCHER
    ) {
      print(actionBarLayout.get().get())
      return
    }
    const notif = self.get_notification(notifId)

    notification.set(notif)

    actionBarLayout.set(ActionBarLayoutType.NOTIFICATION)
    timeout(Durations.TRANSITION, () => {
      renderNotification.set(true)
    })

    const dismissTime = notif.expireTimeout < 0 ? Durations.NOTIFICATION : notif.expireTimeout

    timeout(dismissTime, () => {
      renderNotification.set(false)
      actionBarLayout.set(ActionBarLayoutType.WIDGETS)
      notification.set(null)
      notif.dismiss()
    })
  })

  bind(battery, 'charging').subscribe((charging) => {
    if (charging) {
      sendNotification({
        summary: 'Battery connected',
        body: `${Math.round(battery.percentage * 100)}% charged.`,
        appName: 'System',
        icon: 'i-battery-charging',
        time: 2000,
      })
    } else {
      sendNotification({
        summary: 'Battery disconnected',
        body: `${Math.round(battery.percentage * 100)}% left.`,
        appName: 'System',
        icon: getBatteryIcon(battery.percentage),
        time: 2000,
      })
    }
  })

  bind(battery, 'percentage').subscribe((battery) => {})

  const boxSizing = derive([actionBarLayout.get(), bind(notification)], (layout, notif) => {
    if (!notif || layout !== ActionBarLayoutType.NOTIFICATION || !isPrimary) {
      return ''
    }

    const titleHeight = 27
    const lineHeight = 23

    const baseMinHeight = titleHeight + lineHeight

    const charsPerLine = 55

    const maxLines = 3

    const bodyLines = Math.ceil(notif.body.length / charsPerLine)

    const clampedLines = Math.min(bodyLines, maxLines)

    console.log({
      clampedLines,
      bodyLines,
      calcHeight: baseMinHeight + clampedLines - 1 * lineHeight,
    })

    const totalHeight = Math.max(baseMinHeight + (clampedLines - 1) * lineHeight, baseMinHeight)

    return `min-height: ${totalHeight}px; min-width: 450px; padding: 10px`
  })

  return (
    <box
      className={'notification'}
      name={ActionBarLayoutType.NOTIFICATION}
      css={boxSizing()}
    >
      {renderNotification().as((render) => {
        return render ? (
          <box spacing={isPrimary ? 10 : -999}>
            <icon
              className="app-icon"
              valign={Gtk.Align.START}
              visible={notification().as((n) => Boolean(n?.appIcon || n?.desktopEntry))}
              icon={notification().as((n) => n?.appIcon || n?.desktopEntry)}
              css={renderNotification().as((render) =>
                render && isPrimary ? 'font-size: 3em;' : '',
              )}
            />

            <box
              vertical
              spacing={renderNotification().as((render) => (render && isPrimary ? 0 : -9999))}
            >
              <box spacing={isPrimary ? 5 : -999}>
                <label
                  className="summary"
                  halign={Gtk.Align.START}
                  label={notification().as((notif) => notif?.summary)}
                />
                <label
                  className="app-name"
                  valign={Gtk.Align.CENTER}
                  label={notification().as((notif) => `(${notif?.appName})`)}
                />
                <icon
                  icon="i-x"
                  className="close"
                  hexpand
                  halign={Gtk.Align.END}
                />
              </box>
              <label
                label={notification().as((notif) => `${truncateText(notif!.body, 150)}`)}
                wrap
                maxWidthChars={40}
                halign={Gtk.Align.START}
                valign={Gtk.Align.CENTER}
                hexpand
              />
            </box>
          </box>
        ) : (
          ''
        )
      })}
    </box>
  )
}
