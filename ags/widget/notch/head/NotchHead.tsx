import { Gtk } from 'astal/gtk3'
import SimpleClock from './normal/SimpleClock'
import AstalBattery from 'gi://AstalBattery?version=0.1'
import { bind, timeout, Variable } from 'astal'
import { Durations } from '@/constants/constants'
import { BatteryConnected, BatteryDisconnected } from './messages/BatteryMessages'
import AstalMpris from 'gi://AstalMpris?version=0.1'
import MusicLayout from './music/MusicLayout'
import AstalIO from 'gi://AstalIO?version=0.1'

export enum HeadLayout {
  NORMAL = 'clock',
  MUSIC = 'music',
  BATTERY_CONNECTED = 'connected',
  BATTERY_DISCONNECTED = 'disconnected',
}

export default function NotchHead() {
  const currentLayout = Variable<HeadLayout>(HeadLayout.NORMAL)
  let prevLayout = HeadLayout.NORMAL

  const battery = AstalBattery.get_default()
  const batChargingBind = bind(battery, 'charging')

  let batTimeout: AstalIO.Time | null = null

  batChargingBind.subscribe((isCharging) => {
    if (
      currentLayout().get() !== HeadLayout.BATTERY_CONNECTED &&
      currentLayout().get() !== HeadLayout.BATTERY_DISCONNECTED
    ) {
      prevLayout = currentLayout().get()
    }

    if (isCharging) {
      currentLayout.set(HeadLayout.BATTERY_CONNECTED)
      batTimeout = timeout(Durations.TEMP_LAYOUT, () => {
        currentLayout.set(prevLayout)
      })
    } else {
      currentLayout.set(HeadLayout.BATTERY_DISCONNECTED)
      timeout(Durations.TEMP_LAYOUT, () => {
        currentLayout.set(prevLayout)
      })
    }
  })

  const spotify = AstalMpris.Player.new('spotify')
  const spotiPlaybackStatusBind = bind(spotify, 'playbackStatus')

  spotiPlaybackStatusBind.subscribe((playbackStatus) => {
    if (playbackStatus === AstalMpris.PlaybackStatus.PLAYING) {
      currentLayout.set(HeadLayout.MUSIC)
    } else {
      currentLayout.set(HeadLayout.NORMAL)
    }
  })

  if (spotify.playbackStatus === AstalMpris.PlaybackStatus.PLAYING) {
    currentLayout.set(HeadLayout.MUSIC)
  }

  return (
    <box
      className={'notch_head'}
      hexpand
      heightRequest={30}
      halign={Gtk.Align.FILL}
      vexpand={false}
      css={spotiPlaybackStatusBind.as((playbackStatus) => {
        return playbackStatus === AstalMpris.PlaybackStatus.PLAYING
          ? 'min-width: 400px;'
          : 'min-width: 300px;'
      })}
    >
      <stack
        transition_type={Gtk.StackTransitionType.SLIDE_DOWN}
        transition_duration={Durations.TRANSITION}
        visibleChildName={currentLayout()}
      >
        <SimpleClock />
        <BatteryConnected />
        <BatteryDisconnected />
        <MusicLayout />
      </stack>
    </box>
  )
}
