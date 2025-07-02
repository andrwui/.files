import { bind, derive, timeout, Variable } from 'astal'
import AstalNotifd from 'gi://AstalNotifd?version=0.1'
import ActionBarLayout, { ActionBarLayoutType } from '@/singleton/action_bar_layout/ActionBarLayout'
import { Durations } from '@/constants/constants'
import { Gtk } from 'astal/gtk3'
import { truncateText } from '@/helper/strings'

export default function Notification({ isPrimary }: { isPrimary: boolean }) {
  const actionBarLayout = ActionBarLayout.getInstance()

  const notification = Variable<AstalNotifd.Notification | null>(null)
  const renderNotification = Variable<boolean>(false)

  const notifd = AstalNotifd.get_default()

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

  const boxSizing = derive([actionBarLayout.get(), bind(notification)], (layout, notif) => {
    if (!notif) {
      return ''
    }
    if (layout !== ActionBarLayoutType.NOTIFICATION) {
      return ''
    }
    if (!isPrimary) {
      return ''
    }

    const lineHeight = 30

    const notifBodySize = notif.body.length

    const charsPerLine = 40

    const bodyLines = Math.floor(notifBodySize / charsPerLine)
    const maxLines = 3

    const finalSize = Math.min(maxLines * lineHeight, bodyLines * lineHeight)

    return `min-height: ${finalSize}px; min-width: 450px; padding: 10px;`
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
                  label={notification().as((notif) => `${notif?.appName}`)}
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
