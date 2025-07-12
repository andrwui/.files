import { subprocess } from 'astal'

export function sendNotification({
  icon,
  summary,
  body,
  appName,
  time,
}: {
  icon: string
  summary: string
  body: string
  appName: string
  time?: number
}) {
  subprocess(
    `notify-send "${summary}" "${body}" -a "${appName}" ${time ? '-t ' + time : ''} -i "${icon}"`,
  )
}
