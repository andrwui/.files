import { bind, Variable } from 'astal'
import AstalNotifd from 'gi://AstalNotifd?version=0.1'

export default function Notification({
  notification,
}: {
  notification: Variable<AstalNotifd.Notification | null>
}) {
  return (
    <box
      name="notification"
      className="notification_container"
    >
      {bind(notification).as((notif) => {
        return (
          <box
            className="layout"
            hexpand
          >
            <box
              className="img"
              hexpand={false}
            />
            <box
              vertical
              className="content"
              hexpand
            >
              <label
                label={notif?.summary}
                className="summary"
              />
              <label
                label={notif?.body}
                className="body"
              />
            </box>
          </box>
        )
      })}
    </box>
  )
}
