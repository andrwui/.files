import { Notification as TNotification } from "../../types/service/notifications"
import {notifications} from "../../util/services.ts"

function Notification(n: TNotification) {

  Utils.timeout(10000, () => { 
    n.dismiss()
  } )
 

  const title = Widget.Label({
      class_name: "title",
      xalign: 0,
      justification: "left",
      hexpand: true,
      max_width_chars: 24,
      truncate: "end",
      wrap: true,
      label: n.summary,
      use_markup: true,
  })

  const body = Widget.Label({
      class_name: "body",
      hexpand: true,
      use_markup: true,
      xalign: 0,
      justification: "left",
      label: n.body,
      wrap: true,
  })
  const actions = Widget.Box({
      class_name: "actions",
    children: n.actions.map(({ id, label }) => { 
      if (label != "Acknowledge") {
        return Widget.Button({
          class_name: "action-button",
          on_clicked: () => {
            n.invoke(id)
            n.dismiss()
          },
          hexpand: true,
          child: Widget.Label(label),
        })
      } else { 
        return Widget.Label({label: ""})
      } 
      
    }),
  })

  return Widget.EventBox(
      {
          attribute: { id: n.id },
      on_primary_click: n.dismiss,
      },
      Widget.Box(
          {
              class_name: `notification ${n.urgency}`,
              vertical: true,
          },
          Widget.Box([
              Widget.Box(
                  { vertical: true },
                  title,
                  body,
              ),
          ]),
          actions,
      ),
  )
}

export function NotificationPopups(monitor = 0) {
    const list = Widget.Box({
        vertical: true,
        children: notifications.popups.map(Notification),
    })

    function onNotified(_, /** @type {number} */ id) {
        const n = notifications.getNotification(id)
        if (n)
            list.children = [Notification(n), ...list.children]
    }

    function onDismissed(_, /** @type {number} */ id) {
        list.children.find(n => n.attribute.id === id)?.destroy()
    }
  // @ts-ignore
  list.hook(notifications, onNotified, "notified")
    // @ts-ignore
        .hook(notifications, onDismissed, "dismissed")

    return Widget.Window({
        monitor,
        name: `notifications${monitor}`,
        class_name: "notification-popups",
        anchor: ["top", "right"],
        child: Widget.Box({
          css: "min-width: 2px; min-height: 175px;",
            class_name: "notifications",
            vertical: true,
            child: list,
        }),
    })
}